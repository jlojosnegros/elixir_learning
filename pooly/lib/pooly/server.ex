defmodule Pooly.Server do
  @moduledoc """
   We wanna left Supervisor with a minimun amount of code
   the less the coder the better because there are less chances for error
   and as Supervisor main role is to be watcher for other error processes
   it is better to keep them flawless.
   So we need some other element to be the brain of the plan.
   Here is where the "Server" came into play.
   It will communicate with the High-level Supervisor and with the "sibling"
   supervisor, in this case the WorkerSupervisor, and will keep the state
   of the sibling supervisor. In fact, as it will have a reference to the
   High-level supervisor (because it will be his parent) this server will
   ask the High-level supervisor to create the WorkerSupervisor and will
   then provide him with the configuration data to create the workers.
  """
  use GenServer
  import Supervisor.Spec

  defmodule State do
    @doc """
    Struct to maintain the state of the server
    """
    defstruct sup: nil, size: nil, mfa: nil, worker_sup: nil, workers: nil, monitors: nil
  end

  ######
  # API
  ######
  @doc """
  Server needs both
  - sup: Reference to the high-level supervisor
  - pool_config: worker pool configuration.
  """
  def start_link(sup, pool_config) do
    GenServer.start_link(__MODULE__, [sup, pool_config], name: __MODULE__)
  end

  def checkout do
    GenServer.call(__MODULE__, :checkout)
  end

  def checkin(worker_pid) do
    GenServer.cast(__MODULE__, {:checkin, worker_pid})
  end

  ############
  # CallBacks
  ############

  @doc """
  init has  two responsibilities
  - validate the pool_config
  - initialize state ( as all good init/1 callbacks do)

  A valid pool_config look like:
  [mfa: {SampleWorker, :start_link, []}, size: 5]

  that is a keyword list with two keys "mfa" and "size"
  """
  def init([sup, pool_config]) when is_pid(sup) do
    init(pool_config, %State{sup: sup})
  end

  # Note: remember that a keyword list is just syntactic sugar
  # for a list of 2 element tuples where first element is an atom.
  # This way we destruct the pool_config and store it in State
  def init([{:mfa, mfa} | rest], state) do
    init(rest, %{state | mfa: mfa})
  end

  def init([{:size, size} | rest], state) do
    init(rest, %{state | size: size})
  end

  # This clause is to ignore any other element
  # in the keyword list.
  def init([_ | rest], state) do
    init(rest, state)
  end

  def init([], state) do
    # Here we are sure that the State has been built correctly
    # SO we can start the WorkerSupervisor.
    # BUT as init is sync and has to return asap we send a message
    #     to ourselves (send return immediately) to do it later.
    monitors = :ets.new(:monitors, [:private])
    new_state = %{state | monitors: monitors}
    send(self(), :start_worker_supervisor)
    {:ok, new_state}
  end

  def handle_info(:start_worker_supervisor, state = %{sup: sup, mfa: mfa, size: size}) do
    # Ask high-level supervisor to create a child with the given specification
    # supervisor_spec creates a supervisor process spec instead of a worker spec
    {:ok, worker_sup} = Supervisor.start_child(sup, supervisor_spec(mfa))

    # Once we hace WorkerSupervisor up & running we use its pid
    # stored in "worker_sup" to create a "size" number of workers
    workers = prepopulate(size, worker_sup)

    # update state with the WorkerSupervisor pid and the created workers
    {:noreply, %{state | worker_sup: worker_sup, workers: workers}}
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

  ####################
  # Private Functions
  ####################

  defp supervisor_spec(mfa) do
    # This ask to NO restart WorkerSupervisor ever -- WHY?
    # Well because we want to do a little more than just restart
    # the WorkerSupervisor if it fails ... we wanna have some
    # more control over "custom recovery rules" for workers.
    opts = [restart: :temporary]
    supervisor(Pooly.WorkerSupervisor, [mfa], opts)
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
end
