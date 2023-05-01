defmodule Protohackers.EchoServer do
  use GenServer

  require Logger

  # We do not need to pass params or state to init -> :no_state
  # we use `[] = _opts` because we do not need to pass ops to `start_link`
  # but also DO NOT WANT to accept any options by mistake.
  def start_link([] = _opts) do
    GenServer.start_link(__MODULE__, :no_state)
  end

  # We do not need an initial state for this server
  # But we are gonna need a state from call to call
  # It is a good idea to always use an struct for this
  # ( but he does not explain why exactly.)
  defstruct [:listen_socket]

  @impl true
  def init(:no_state) do
    Logger.info("Starting echo server")
    # Here we need to initialize the echo server ...
    # but lets return an empty state right now.
    {:ok, %__MODULE__{}}
  end
end
