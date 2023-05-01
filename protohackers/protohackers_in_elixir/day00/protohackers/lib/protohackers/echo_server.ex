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

    # Here we need to initialize the echo server ...

    listen_options = [
      mode: :binary,
      active: false,
      reuseaddr: true
    ]

    # using gen_tcp as tcp library ( from Erlang)
    # If everythin goes ok we get the listen socket
    # and return it in the state
    # Otherwise stop the server with the reason.
    case :gen_tcp.listen(5001, listen_options) do
      {:ok, listen_socket} ->
        Logger.info("Starting echo server on port 5001")
        state = %__MODULE__{listen_socket: listen_socket}
        {:ok, state}

      {:error, reason} ->
        {:stop, reason}
    end

    {:ok, %__MODULE__{}}
  end
end
