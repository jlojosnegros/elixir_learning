defmodule Pooly.PoolServer do
  use GenServer
  import Supervisor.Spec

  defmodule State do
    defstruct pool_sup: nil,
              worker_sup: nil,
              monitors: nil,
              size: nil,
              workers: nil,
              name: nil,
              mfa: nil,
              overflow: nil,
              max_overflow: nil,
              waiting: nil
  end

  ######
  # API
  ######
  def start_link(pool_sup, pool_config) do
    GenServer.start_link(__MODULE__, [pool_sup, pool_config], name: name(pool_config[:name]))
  end

  def checkout(pool_name, block, timeout) do
    GenServer.call(name(pool_name), {:checkout, block}, timeout)
  end

  def checkin(pool_name, worker_pid) do
    GenServer.cast(name(pool_name), {:checkin, worker_pid})
  end

  def status(pool_name) do
    GenServer.call(name(pool_name), :status)
  end

  ############
  # Callbacks
  ############

  def init([pool_sup, pool_config]) when is_pid(pool_sup) do
    # Set the server process to trap exists =>
    # When a linked process crashed Server does NOT crash
    # but receives a message.
    Process.flag(:trap_exit, true)
    init(pool_config, %State{pool_sup: pool_sup})
  end

  def init([{:name, name} | rest], state) do
    init(rest, %{state | name: name})
  end

  def init([{:mfa, mfa} | rest], state) do
    init(rest, %{state | mfa: mfa})
  end

  def init([{:size, size} | rest], state) do
    init(rest, %{state | size: size})
  end

  def init([{:max_overflow, max_overflow} | rest], state) do
    init(rest, %{state | max_overflow: max_overflow})
  end

  def init([_ | rest], state) do
    # This clause ignores any element in the keyword list
    # that it is not a known parameter
    init(rest, state)
  end

  def init([], state) do
    monitors = :ets.new(:monitors, [:private])
    waiting = :queue.new()
    send(self(), :start_worker_supervisor)
    {:ok, %{state | monitors: monitors, waiting: waiting, overflow: 0}}
  end

  def handle_call({:checkout, block}, {from_pid, _ref} = from, state) do
    %{
      worker_sup: worker_sup,
      workers: workers,
      monitors: monitors,
      overflow: overflow,
      max_overflow: max_overflow,
      waiting: waiting
    } = state

    case workers do
      [worker | rest] ->
        ref = Process.monitor(from_pid)
        true = :ets.insert(monitors, {worker, ref})
        {:reply, worker, %{state | workers: rest}}

      [] when max_overflow > 0 and overflow < max_overflow ->
        # if there are no more workers available
        # *BUT* we still have some room to overflow
        # we need to create a new worker, monitor it
        # and count it against the overflow limit
        {worker, ref} = new_worker(worker_sup, from_pid)
        true = :ets.insert(monitors, {worker, ref})
        {:reply, worker, %{state | overflow: overflow + 1}}

      [] when block == true ->
        ref = Process.monitor(from_pid)
        waiting = :queue.in({from, ref}, waiting)
        {:noreply, %{state | waiting: waiting}, :infinity}

      [] ->
        # if there is no more room even counting overflow
        # we cannot do anything else.
        {:reply, :full, state}
    end
  end

  def handle_call(:status, _from, %{workers: workers, monitors: monitors} = state) do
    {:reply, {state_name(state), length(workers), :ets.info(monitors, :size)}, state}
  end

  def handle_cast({:checkin, worker_pid}, %{workers: _workers, monitors: monitors} = state) do
    # look for the worker in database
    case :ets.lookup(monitors, worker_pid) do
      [{pid, ref}] ->
        # if found ...
        # ... do not monitor caller process anymore ...
        true = Process.demonitor(ref)

        # ... delete monitor from database table ...
        true = :ets.delete(monitors, pid)

        # as we now handle overflow we have to differenciate
        # when a checked in worker is a "normal" one
        # or an overflow surge.
        new_state = handle_checkin(pid, state)
        {:noreply, new_state}

      [] ->
        # ... if not found there is nothing to be done
        {:noreply, state}
    end
  end

  def handle_info(
        :start_worker_supervisor,
        state = %{pool_sup: pool_sup, name: name, mfa: mfa, size: size}
      ) do
    {:ok, worker_sup} = Supervisor.start_child(pool_sup, supervisor_spec(name, mfa))
    workers = prepopulate(size, worker_sup)
    {:noreply, %{state | worker_sup: worker_sup, workers: workers}}
  end

  def handle_info({:DOWN, ref, _, _, _}, state = %{monitors: monitors, workers: workers}) do
    # Need to handle the message sent to us by monitors when a
    # consumer process who checked out a worker crashes.
    case :ets.match(monitors, {:"$1", ref}) do
      [[pid]] ->
        true = :ets.delete(monitors, pid)
        new_state = %{state | workers: [pid | workers]}
        {:noreply, new_state}

      [[]] ->
        {:noreply, state}
    end
  end

  def handle_info({:EXIT, worker_sup, reason}, state = %{worker_sup: worker_sup}) do
    # We are linked to our sibling Pooly.WorkerSupervisor
    # *BUT* as we are trapping exits we receive a message when the WorkerSupervisor crashes
    # instead of been stopped
    # *BUT* as we wanna be stopped just return :stop
    {:stop, reason, state}
  end

  def handle_info(
        {:EXIT, pid, _reason},
        state = %{
          monitors: monitors
        }
      ) do
    # here we handle the crash of a worker process
    case :ets.lookup(monitors, pid) do
      [{pid, ref}] ->
        true = Process.demonitor(ref)
        true = :ets.delete(monitors, pid)
        # Before handling overload we just return
        # the workers to the list now we have to check
        # if the crashed worker was a "normal" or
        # an overflow surge one
        # *WARN*: We were using pool_sup here but `handle_worker_exit` uses worker_pool
        new_state = handle_worker_exit(pid, state)
        {:noreply, new_state}

      _ ->
        {:noreply, state}
    end
  end

  def terminate(_reason, _state) do
    :ok
  end

  ####################
  # Private Functions
  ####################

  defp name(pool_name) do
    :"#{pool_name}Server"
  end

  defp prepopulate(size, sup) do
    prepopulate(size, sup, [])
  end

  defp prepopulate(size, _sup, workers) when size < 1 do
    workers
  end

  defp prepopulate(size, sup, workers) do
    prepopulate(size - 1, sup, [new_worker(sup) | workers])
  end

  defp new_worker(sup) do
    # Dynamically creates a worker and attach it to supervisor
    # Note: "[[]]" its what make this call dynamic
    # "[[]]" is a list of aditional arguments and as WorkerSupervisor
    # is using a :simple_one_to_one strategy and the child_spec has
    # been defined we can use this method.
    # @warning DEPRECATED
    {:ok, worker} = Supervisor.start_child(sup, [[]])
    worker
  end

  defp new_worker(worker_sup, client_pid) do
    # This is an entirely made-up function.
    # I **SUPPOSE**, based on the `new_worker/1` function and
    # in the calling code to `new_worker/2`, that
    # what is it expectec from this function is to create a new
    # worker and monitor the client_pid returning both
    # the worker pid and the monitor reference
    mon_ref = Process.monitor(client_pid)

    case Supervisor.start_child(worker_sup, [[]]) do
      {:ok, worker} ->
        {worker, mon_ref}

      _ ->
        Process.demonitor(mon_ref)
        :error
    end
  end

  defp supervisor_spec(name, mfa) do
    # This ask to NO restart WorkerSupervisor ever -- WHY?
    # Well because we want to do a little more than just restart
    # the WorkerSupervisor if it fails ... we wanna have some
    # more control over "custom recovery rules" for workers.
    opts = [
      id: name <> "WorkerSupervisor",
      restart: :temporary
    ]

    supervisor(Pooly.WorkerSupervisor, [self(), mfa], opts)
  end

  defp handle_checkin(pid, state) do
    %{
      worker_sup: worker_sup,
      workers: workers,
      monitors: monitors,
      waiting: waiting,
      overflow: overflow
    } = state

    case :queue.out(waiting) do
      {{:value, {from, ref}}, left} ->
        true = :ets.insert(monitors, {pid, ref})
        GenServer.reply(from, pid)
        %{state | waiting: left}

      {:empty, _} when overflow > 0 ->
        :ok = dismiss_worker(worker_sup, pid)
        %{state | overflow: overflow - 1}

      {:empty, _} ->
        %{state | workers: [pid | workers], overflow: 0}
    end
  end

  defp dismiss_worker(sup, pid) do
    true = Process.unlink(pid)
    Supervisor.terminate_child(sup, pid)
  end

  defp handle_worker_exit(_pid, state) do
    %{
      worker_sup: worker_sup,
      workers: workers,
      monitors: monitors,
      waiting: waiting,
      overflow: overflow
    } = state

    case :queue.out(waiting) do
      {{:value, {from, ref}}, left} ->
        new_worker = new_worker(worker_sup)
        true = :ets.insert(monitors, {new_worker, ref})
        GenServer.reply(from, new_worker)
        %{state | waiting: left}

      {:empty, _} when overflow > 0 ->
        %{state | overflow: overflow - 1}

      {:empty, _} ->
        workers = [new_worker(worker_sup) | workers]
        %{state | workers: workers, overflow: 0}
    end
  end

  defp state_name(%State{overflow: overflow, max_overflow: max_overflow, workers: workers})
       when overflow < 1 do
    case length(workers) == 0 do
      true ->
        if max_overflow < 1 do
          :full
        else
          :overflow
        end

      false ->
        :ready
    end
  end

  defp state_name(%State{overflow: max_overflow, max_overflow: max_overflow}) do
    :full
  end

  defp state_name(_state) do
    :overflow
  end
end
