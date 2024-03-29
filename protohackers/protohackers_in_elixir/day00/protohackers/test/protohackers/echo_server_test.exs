defmodule Protohackers.EchoServerTest do
  use ExUnit.Case

  test "echoes anything back" do
    {:ok, socket} = :gen_tcp.connect(~c"localhost",5001, mode: :binary, active: false)

    assert :gen_tcp.send(socket, "foo") == :ok
    assert :gen_tcp.send(socket, "bar") == :ok

    :gen_tcp.shutdown(socket,:write)
    assert :gen_tcp.recv(socket, 0 , 5000) == {:ok, "foobar"}
  end
end
