# this is the  file where de API resides
defmodule Hangman do
  @moduledoc """
  This is the API for Hangman game
  """

  alias Hangman.Runtime.Server
  alias Hangman.Type

  # NOTE -  We now define the proper type. BUT as we want this to be an implementation detail
  #     we define it in the Impl module, and here we just refer to it to hide that fact outside
  #       Also instead of `type` we use `opaque` to avoid any user to be able to
  #     peak inside our data type and do something with it.
  @opaque game :: Server.t()

  @doc """
  Create a new game.

  Need no params
  Will return a new Hangman game object.
  Should be the first function called for any new game
  """
  @spec new_game() :: game
  def new_game() do
    {:ok, pid} = Server.start_link()
    pid
  end

  # NOTE - We use `defdelegate` to keep API nice and simple without any code.
  # This will work but we can do better
  # def new_game do
  #  Hangman.Impl.Game.new_game()
  # end
  # . create an alias for the module name. (above)
  # this will allow us to call
  # def new_game do
  # Game.new_game()
  # end
  # but this will show Implementation code in the API
  # and Elixir has something to avoid this.
  # and so there is no need for the new_game function anymore
  # defdelegate

  @doc """
  Let the client do a new guess.

  Params:
  - game: Current game state
  - guess: New guess for the game.

  Return:
  - game: New game state after the guess
  - tally: Client side information (turns left, letters used, etc)
  """
  # @spec make_move(game, String.t()) :: {game, Type.tally()}
  @spec make_move(game(), String.t()) :: Type.tally()
  def make_move(game, guess) do
    Server.make_move(game, guess)
  end

  @spec tally(game) :: Type.tally()
  def tally(game) do
    Server.tally(game)
  end
end
