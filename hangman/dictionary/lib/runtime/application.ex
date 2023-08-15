defmodule Dictionary.Runtime.Application do
  # This is the code to start the processes
  # it is a little bit of boiler plate code
  # just to let the client ( and mostly the runtime env)
  # to simply start the needed processes
  use Application

  @spec start(any, any) :: {:error, any} | {:ok, pid}
  def start(_type, _args) do
    # start the supervisor

    children = [
      # module (with start_link function), parameters
      {Dictionary.Runtime.Server, []}
    ]

    options = [
      # name of the supervisor
      name: Dictionary.Runtime.Supervisor,

      # strategy: one_for_one | :one_for_all | :rest_for_one | :simple_one_for_one
      strategy: :one_for_one

      # if more than "n" restarts occur in "s" seconds
      # the Supervisor shuts down all supervised processes and
      # *terminates itself*
      # max_restarts: n, # default: 1
      # max_seconds: s, # default: 5
    ]

    Supervisor.start_link(children, options)
  end
end
