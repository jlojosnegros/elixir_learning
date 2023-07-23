# this is the  file where de API resides
defmodule Hangman do
  @moduledoc """
  This is the API for Hangman game
  """
  @doc """
  Create a new game.

  Need no params
  Will return a new Hangman game object
  Should be the first function called for any new game
  """
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
  def make_move(_game, _guess) do
  end
end
