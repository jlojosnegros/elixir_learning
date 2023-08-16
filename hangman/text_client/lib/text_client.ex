defmodule TextClient do
  @spec start() :: :ok
  def start() do
    # this way we first connect to the remote server
    # and then pass the ID to the player implementation
    # The most beautiful is that no one has to depend on the other.
    TextClient.Runtime.RemoteHangman.connect()
    |> TextClient.Impl.Player.start()
  end
end
