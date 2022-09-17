defmodule Pooly.WorkerSupervisor do
  use Supervisor

  ######
  # API
  ######
  def start_link({_, _, _} = mfa) do
    Supervisor.start_link(__MODULE__, mfa)
  end

  ############
  # Callbacks
  ############
  def init({m, f, a}) do
    worker_opts = [
      # always restart a worker
      restart: :permanent,
      # entry point for worker
      function: f
    ]

    children = [
      # Supervisor.Spec.worker is a helper function
      # to create a worker specification
      worker(m, a, worker_opts)
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
    supervise(children, opts)
  end
end
