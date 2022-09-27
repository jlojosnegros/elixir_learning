defmodule Pooly.WorkerSupervisor do
  use Supervisor

  ######
  # API
  ######
  def start_link(pool_server, {_, _, _} = mfa) do
    Supervisor.start_link(__MODULE__, [pool_server, mfa])
  end

  ############
  # Callbacks
  ############
  def init([pool_server, {m, f, a}]) do
    # This WorkerSupervisor is linked with its Pooly.PoolServer
    # if any crashes the other one should be taken down.
    Process.link(pool_server)

    worker_opts = [
      # never restart a worker ?!?!?!
      restart: :temporary,
      shutdown: 5000
    ]

    children = [
      Pooly.Specs.worker_spec(m, f, a, worker_opts)
    ]

    opts = [
      # strategy marks how a single process failure
      # will affect the rest of the supervised processes.
      # :simple_one_for_one is SPECIAL.
      # it is used when childs are not specified in the
      # child_spec but will be created dinamically.
      # Usually this is used when the Supervisor is going
      # to work as a Factory, and so there is only one
      # child process specification and all the processes are
      # created from that specification (like a prototype)
      strategy: :simple_one_for_one,
      max_restarts: 5,
      max_seconds: 5
    ]

    # init return must be a supervisor specification.
    # Supervisor.Spec.supervise return this.
    Supervisor.init(children, opts)
  end
end
