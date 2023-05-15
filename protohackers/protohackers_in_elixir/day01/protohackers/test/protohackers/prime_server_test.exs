defmodule Protohackers.PrimeServerTest do
  use ExUnit.Case

  test "echoes back Json" do
    # open a socket to the server
    {:ok, socket} = :gen_tcp.connect(~c"localhost", 5002, mode: :binary, active: false)
    # send a json data with a line end
    :gen_tcp.send(socket, Jason.encode!(%{"foo" => 1}) <> "\n")

    # Ensure we receive data back
    assert {:ok, data} = :gen_tcp.recv(socket, 0 , 10_000)

    # Ensure data has a line end
    assert String.ends_with?(data, "\n")

    # Ensure it is a valid Json and the same we send before.
    assert Jason.decode!(data) == %{"foo" => 1}
  end

end
