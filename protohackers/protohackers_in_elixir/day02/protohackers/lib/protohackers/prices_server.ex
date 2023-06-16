defmodule Protohackers.PricesServer do
  use GenServer

  require Logger

  alias Protohackers.PricesServer.Db

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
    # Here we need to initialize the prices server ...

    listen_options = [
      mode: :binary,
      active: false,
      reuseaddr: true,
      # need this to be able to write on a closed socket
      exit_on_close: false
    ]

    # using gen_tcp as tcp library ( from Erlang)
    # If everythin goes ok we get the listen socket
    # and return it in the state
    # Otherwise stop the server with the reason.
    case :gen_tcp.listen(5003, listen_options) do
      {:ok, listen_socket} ->
        Logger.info("Starting prices server on port 5003")
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
    case handle_requests(socket, Db.new()) do
      :ok ->
        :ok

      {:error, reason} ->
        Logger.error("Failed to receive data: #{inspect(reason)}")
    end

    # either way we have finished with the socket
    :gen_tcp.close(socket)
  end

  defp handle_requests(socket, db) do
    case :gen_tcp.recv(socket, _nbytes = 9, _timeout = 10_000) do
      {:ok, data} when byte_size(data) == 9 ->
        case handle_request(data, db) do
          {nil, db} ->
            handle_requests(socket, db)

          {response, db} ->
            :gen_tcp.send(socket, response)
            handle_requests(socket, db)

          :error ->
            {:error, :invalid_request}
        end

      {:error, :timeout} ->
        handle_requests(socket, db)

      {:error, :closed} ->
        # the other side ( the client) has closed its write end of the socket
        # so we have finished with this socket.
        :ok

      {:error, reason} ->
        {:error, reason}
    end
  end

  # ?I -> ascii for 'I'
  defp handle_request(<<?I, timestamp::32-signed-big, price::32-signed-big>>, db) do
    {nil, Db.add(db, timestamp, price)}
  end
  defp handle_request(<<?Q, mintime::32-signed-big, maxtime::32-signed-big>>, db) do
    avg = Db.query(db, mintime, maxtime)
    {<<avg::32-signed-big>>, db}
  end
  defp handle_request(_other, _db) do
    :error
  end
end
