defmodule Dictionary.Runtime.Application do
  # This is the code to start the processes
  # it is a little bit of boiler plate code
  # just to let the client ( and mostly the runtime env)
  # to simply start the needed processes
  use Application

  @spec start(any, any) :: {:error, any} | {:ok, pid}
  def start(_type, _args) do
    Dictionary.Runtime.Server.start_link()
  end
end
