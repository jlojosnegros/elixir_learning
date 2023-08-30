defmodule Hangman.Runtime.Server do
  use GenServer

  alias Hangman.Runtime.Watchdog
  alias Hangman.Impl.Game

  @type t :: pid()

  # 1 hour
  @idle_timeout 1 * 60 * 60 * 1000

  ##########
  ### API (client process)
  ##########
  # As now Hangman.Runtime.Server will be started by a Supervisor
  # (in fact by a DynamicSupervisor) we need to handle the initial
  # parameter ( just ignoring is ok)
  def start_link(_init) do
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
    watcher = Watchdog.start(@idle_timeout)
    {:ok, {Game.new_game(), watcher}}
  end

  def handle_call({:make_move, guess}, _from, {game, watcher}) do
    Watchdog.im_alive(watcher)
    {updated_game, tally} = Game.make_move(game, guess)
    {:reply, tally, {updated_game, watcher}}
  end

  def handle_call({:tally}, _from, {game, watcher}) do
    Watchdog.im_alive(watcher)
    {:reply, Game.tally(game), {game, watcher}}
  end
end
