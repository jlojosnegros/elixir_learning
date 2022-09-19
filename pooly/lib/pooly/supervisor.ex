defmodule Pooly.Supervisor do
  @moduledoc """
  This is the TOP level supervisor.
  Supervisor is in charge of kick-starting:

  - Pooly.Server
  - Pooly.PoolsSuvervisor (note the plural)

  When Pooly.PoolsSupervisor starts, it starts up individual Pooly.PoolSupervisors
  that in turn will start their own Pooly.Server and Pooly.WorkerSupervisor

  Brief:
  - Pooly.Supervisor
    - Pooly.Server
    - Pooly.PoolsSupervisor
      - Pooly.Supervisor
        - Pooly.PoolServer
        - Pooly.WorkerSupervisor
          - Worker
          - Worker
          - ...
      - Pooly.Supervisor
        - Pooly.PoolServer
        - Pooly.WorkerSupervisor
          - Worker
          - Worker
          - ...
      - ...
  """
  use Supervisor

  def start_link(pools_config) do
    # Supervisor is now a named process ... we only need one.
    Supervisor.start_link(__MODULE__, pools_config, name: __MODULE__)
  end

  def init(pools_config) do
    children = [
      supervisor(Pooly.PoolsSupervisor, []),
      # No need to pass "self" as Supervisor is now a named process
      worker(Pooly.Server, [pools_config])
    ]

    # Still the server stores the state of the supervisor
    # so both are linked and need to be restarted if any
    # of them crash
    opts = [strategy: :one_for_all]

    supervise(children, opts)
  end
end
