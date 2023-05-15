defmodule Protohackers.PrimeServer do
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
      reuseaddr: true,
      # need this to be able to write on a closed socket
      exit_on_close: false,
      # this option will make GenTCP to only return one line at a time.
      # "packet" option has multiple possible values to inform GenTCP
      # which type of packet are we dealing with so it could help us
      # with them. ( See documentation for more.)
      packet: :line,
      # We can change the buffer size for the socket.
      buffer: 1024 * 100,
    ]

    # using gen_tcp as tcp library ( from Erlang)
    # If everythin goes ok we get the listen socket
    # and return it in the state
    # Otherwise stop the server with the reason.
    case :gen_tcp.listen(5002, listen_options) do
      {:ok, listen_socket} ->
        # With "packet: :line" option gen_tcp docs inform
        # that all lines with greater length than the socket buffer
        # will be truncated.
        # As we need to protect against this we need to know
        # internal buffer socket size.
        dbg(:inet.getopts(listen_socket, [:buffer]))
        Logger.info("Starting prime server on port 5002")
        state = %__MODULE__{listen_socket: listen_socket}
        # Here we already have the listen socket.
        # But we cannot start accepting connections right here.
        # "init" is run sequentially for all the childs and
        # should be kept as short as possible for Elixir to
        # be reactive.
        # Instead of return just {:ok, state} we are gonna return
        # {:ok, state, {:continue, :accept}} to handle this.
        # [Return type for init](https://hexdocs.pm/elixir/1.12/GenServer.html#c:init/1)
        {:ok, state, {:continue, :accept}}

      {:error, reason} ->
        {:stop, reason}
    end
  end

  @impl true
  def handle_continue(:accept, %__MODULE__{} = state) do
    # Here we are just gonna start accepting connections
    # in the new listen_socket
    # If something wrong happens we just stop the genserver ( fail fast)

    case :gen_tcp.accept(state.listen_socket) do
      {:ok, socket} ->
        handle_connection(socket)
        {:noreply, state, {:continue, :accept}}

      {:error, reason} ->
        {:stop, reason}
    end
  end

  ## Helpers
  defp handle_connection(socket) do
    case echo_lines_until_close(socket) do
      :ok -> :ok

      {:error, reason} ->
        Logger.error("Failed to receive data: #{inspect(reason)}")
    end

    # either way we have finished with the socket
    :gen_tcp.close(socket)
  end

  defp echo_lines_until_close(socket) do
    case :gen_tcp.recv(socket, _nbytes = 0, _timeout = 10_000) do

      {:ok, data} ->
        Logger.debug("Received data: #{inspect(data)}")
        # Now when we have a line we need to return the line.
        # we add a new line cause the gen_tcp does not do it.
        :gen_tcp.send(socket, [data, ?\n])
        echo_lines_until_close(socket)

      {:error, :closed} ->
        # the other side ( the client) has closed its write end of the socket
        # so we have finished with this socket.
        :ok

      {:error, reason} ->
        {:error, reason}
    end
  end
end
