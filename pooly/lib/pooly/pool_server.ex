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
              mfa: nil
  end

  ######
  # API
  ######
  def start_link(pool_sup, pool_config) do
    GenServer.start_link(__MODULE__, [pool_sup, pool_config], name: name(pool_config[:name]))
  end

  def check_out(pool_name) do
    GenServer.call(name(pool_name), :checkout)
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

  def init([_ | rest], state) do
    # This clause ignores any element in the keyword list
    # that it is not a known parameter
    init(rest, state)
  end

  def init([], state) do
    monitors = :ets.new(:monitors, [:private])
    send(self(), :start_worker_supervisor)
    {:ok, %{state | monitors: monitors}}
  end

  def handle_call(:checkout, {from_pid, _ref}, %{workers: workers, monitors: monitors} = state) do
    case workers do
      [worker | rest] ->
        ref = Process.monitor(from_pid)
        true = :ets.insert(monitors, {worker, ref})
        {:reply, worker, %{state | workers: rest}}

      [] ->
        {:reply, :noproc, state}
    end
  end

  def handle_call(:status, _from, %{workers: workers, monitors: monitors} = state) do
    {:reply, {length(workers), :ets.info(monitors, :size)}, state}
  end

  def handle_cast({:checkin, worker_pid}, %{workers: workers, monitors: monitors} = state) do
    # look for the worker in database
    case :ets.lookup(monitors, worker_pid) do
      [{pid, ref}] ->
        # if found ...
        # ... do not monitor caller process anymore ...
        true = Process.demonitor(ref)

        # ... delete monitor from database table ...
        true = :ets.delete(monitors, pid)

        # ... and just return adding the worker to the pool
        {:noreply, %{state | workers: [pid | workers]}}

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
        state = %{monitors: monitors, workers: workers, pool_sup: pool_sup}
      ) do
    # here we handle the crash of a worker process
    case :ets.lookup(monitors, pid) do
      [{pid, ref}] ->
        true = Process.demonitor(ref)
        true = :ets.delete(monitors, pid)
        new_state = %{state | workers: [new_worker(pool_sup) | workers]}
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
end
