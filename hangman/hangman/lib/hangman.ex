# this is the  file where de API resides
defmodule Hangman do
  @moduledoc """
  This is the API for Hangman game
  """

  alias Hangman.Impl.Game

  # NOTE - Elixir does NOT have enums but we can use a list of atoms for that
  #     Here we define the `state` type saying it can be any of the following atoms
  #     as they are linked by OR
  # FIXME - Right now we have a kind of circular dependency.
  #      Here we have defined the state type and we reference it in the Impl module
  #      And Here we are referencing the `Game.t` type that is declared in the Impl module
  #     Good luck that Elixir is smart enough to handle this, but is still a design failure
  @type state :: :initializing | :won | :lost | :good_guess | :bad_guess | :already_used

  # NOTE -  We now define the proper type. BUT as we want this to be an implementation detail
  #     we define it in the Impl module, and here we just refer to it to hide that fact outside
  #       Also instead of `type` we use `opaque` to avoid any user to be able to
  #     peak inside our data type and do something with it.
  @opaque game :: Game.t()

  # NOTE - Type definition uses a syntax like a variable definition
  #     but using type names instead.
  #     Here, as we nedd `tally`  to be a compound type we use a map
  #     defining each entry as "name": "type name"
  @type tally :: %{
          turns_left: integer,
          # Possible valid game states ... we do not have enum so ...
          game_state: state,
          # Word to be guessed as a list of letters
          letters: list(String.t()),
          # list of letters asked by the user ( should be a set )
          used: list(String.t())
        }

  @doc """
  Create a new game.

  Need no params
  Will return a new Hangman game object.
  Should be the first function called for any new game
  """
  @spec new_game() :: game
  defdelegate new_game, to: Game
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
  @spec make_move(game, String.t()) :: {game, tally}
  def make_move(_game, _guess) do
  end
end
