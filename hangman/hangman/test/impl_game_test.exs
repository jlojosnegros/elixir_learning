defmodule HangmanImplGameTest do
  use ExUnit.Case

  alias Hangman.Impl.Game

  test "new game returns structure" do
    game = Game.new_game()

    assert game.turns_left == 7
    assert game.game_state == :initializing
    assert length(game.letters) > 0
  end

  test "new game returns correct word" do
    expected = "wombat"
    game = Game.new_game(expected)

    assert game.turns_left == 7
    assert game.game_state == :initializing
    assert game.letters == String.codepoints(expected)
  end

  test "new_game returns a lowecase unicode word" do
    game = Game.new_game()

    assert game.letters
           |> Stream.map(fn letter -> Unicode.downcase?(letter) end)
           |> Enum.all?(),
           "incorrect word '#{game.letters}' should not have uppercase"
  end

  test "state does not change if a game is won" do
    game = Game.new_game("wombat")

    old_game = Map.put(game, :game_state, :won)

    {new_game, _tally} = Game.make_move(old_game, "x")
    assert new_game == old_game
  end

  test "state does not change if a game is lost" do
    game = Game.new_game("wombat")

    old_game = Map.put(game, :game_state, :lost)

    {new_game, _tally} = Game.make_move(old_game, "x")
    assert new_game == old_game
  end
end
