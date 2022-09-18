defmodule Pooly.Supervisor do
  use Supervisor

  def start_link(pool_config) do
    Supervisor.start_link(__MODULE__, pool_config)
  end

  def init(pool_config) do
    # We only add Server here because Server starts
    # WorkerSupervisor and it starts it by usin the
    # high-level supervisor it receives by config here.
    # So in the end both processes are supervised by
    # this supervisor as siblings.
    # ----------------------------------------------------
    # Warning This is what I thought it would happen
    # **BUT**
    # despite the fact that Server uses the this Supervisor
    # to start WorkerSupervisor
    # **AND**
    # that this supervisor
    # would have the `:one_for_all strategy`
    # Seems that dynamically started childs do NOT obey the
    # same strategy
    # **BECAUSE**
    # when I have killed WorkerSupervisor nothing happens
    # but if I kill Server everything (Server and WorkerSupervisor)
    # is restarted.
    # ----------------------------------------------------
    children = [
      worker(Pooly.Server, [self(), pool_config])
    ]

    # As both Server and WorkerSupervisor are linked
    # and if one of them restarts its state will be
    # incoherent with the other one we need to restart
    # both of them if one crashes.
    # So we use :one_for_all instead :one_for_one
    opts = [strategy: :one_for_all]

    supervise(children, opts)
  end
end
