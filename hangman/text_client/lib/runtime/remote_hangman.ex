defmodule TextClient.Runtime.RemoteHangman do

  @remote_server :hangman@wherever

  def connect() do
    :rpc.call(@remote_server, Hangman, :new_game, [])
  end
end
