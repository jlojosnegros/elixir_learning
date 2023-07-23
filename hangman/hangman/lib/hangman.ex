# this is the  file where de API resides
defmodule Hangman do
  @moduledoc """
  This is the API for Hangman game
  """

  # NOTE - Elixir does NOT have enums but we can use a list of atoms for that
  #     Here we define the `state` type saying it can be any of the following atoms
  #     as they are linked by OR
  @type state :: :initializing | :won | :lost | :good_guess | :bad_guess | :already_used

  # we define a dummy type for now.
  # to avoid errors in specs
  @type game :: any

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
  Will return a new Hangman game object
  Should be the first function called for any new game
  """
  @spec new_game() :: game
  def new_game do
  end

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
