defmodule Hangman.Runtime.Server do
  use GenServer

  alias Hangman.Impl.Game

  @type t :: pid()

  ##########
  ### API (client process)
  ##########
  def start_link() do
    GenServer.start_link(__MODULE__, _args = nil)
  end

  @spec make_move(pid(), String.t()) :: Hangman.Type.tally()
  def make_move(pid, guess) do
    GenServer.call(pid, {:make_move, guess})
  end

  @spec tally(pid()) :: Hangman.Type.tally()
  def tally(pid) do
    GenServer.call(pid, {:tally})
  end

  ##########
  ### Callbacks (server)
  ##########
  def init(_init_arg) do
    {:ok, Game.new_game()}
  end

  def handle_call({:make_move, guess}, _from, game) do
    {updated_game, tally} = Game.make_move(game, guess)
    {:reply, tally, updated_game}
  end

  def handle_call({:tally}, _from, game) do
    {:reply, Game.tally(game), game}
  end
end
