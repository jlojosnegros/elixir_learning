defmodule Hangman.Runtime.Application do
  # This is the code to start the processes
  # it is a little bit of boiler plate code
  # just to let the client ( and mostly the runtime env)
  # to simply start the needed processes
  use Application

  @super_name GameStarter

  @spec start(any, any) :: {:error, any} | {:ok, pid}
  def start(_type, _args) do
    # Here we are gonna use a DynamicSupervisor to create new games
    # on the fly.
    # Let's see what we are gonna have ...
    # Runtime will start the Application ( that is this function)
    # Here we are defining a DynamicSupervisor and passing that
    # to the Supervisor so it is the one who will take care of
    # starting the DinamicSupervisor itself.
    # After that we will ask the DynamicSupervisor to start a new
    # game server (Hangman.Runtime.Server) each time a new client connects
    # using the function start_game
    #
    # Runtime -> Application
    #            -> Supervisor ( main process)
    #               -> DynamicSupervisor ( started by supervisor)
    #                  -> Hangman.Server
    #                  -> Hangman.Server
    #                  -> Hangman.Server

    # This is the DinamycSupervisor spec
    # Here we specify the strategy the Dynamicsupervisor will use
    # to supervise his childs
    supervisor_spec = [
      {DynamicSupervisor, strategy: :one_for_one, name: @super_name}
    ]

    # Here we instruct the root Supervisor to start the DynamicSupervisor
    # and we specify the strategy it will use to supervise de DynamicSupervisor
    Supervisor.start_link(supervisor_spec, strategy: :one_for_one)
  end

  def start_game() do
    DynamicSupervisor.start_child(@super_name, {Hangman.Runtime.Server, nil})
  end
end
