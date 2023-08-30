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

  test "a duplicated letter is reported" do
    game = Game.new_game()
    {game, _tally} = Game.make_move(game, "x")
    assert game.game_state != :already_used

    {game, _tally} = Game.make_move(game, "y")
    assert game.game_state != :already_used

    {game, _tally} = Game.make_move(game, "x")
    assert game.game_state == :already_used
  end

  test "we record lettes used" do
    game = Game.new_game()
    {game, _tally} = Game.make_move(game, "x")
    {game, _tally} = Game.make_move(game, "y")
    {game, _tally} = Game.make_move(game, "x")

    assert MapSet.equal?(game.used, MapSet.new(["x", "y"]))
  end

  test "we recognize a letter in the word" do
    game = Game.new_game("wombat")

    {_game, tally} = Game.make_move(game, "m")
    assert tally.game_state == :good_guess
  end

  test "we recognize letter that is not in the word" do
    game = Game.new_game("wombat")
    {game, tally} = Game.make_move(game, "x")
    assert tally.game_state == :bad_guess

    {game, tally} = Game.make_move(game, "w")
    assert tally.game_state == :good_guess

    {_game, tally} = Game.make_move(game, "y")
    assert tally.game_state == :bad_guess
  end

  test "can handle a sequence of moves " do
    # trying to guess "hello" word
    # each element is a movement with
    # [ "guess", :expected_state_result_from_guess , turns left,  <current word status>, <letters used>]
    [
      ["a", :bad_guess, 6, ["_", "_", "_", "_", "_"], ["a"]],
      ["a", :already_used, 6, ["_", "_", "_", "_", "_"], ["a"]],
      ["e", :good_guess, 6, ["_", "e", "_", "_", "_"], ["a", "e"]],
      ["x", :bad_guess, 5, ["_", "e", "_", "_", "_"], ["a", "e", "x"]]
    ]
    |> test_sequence_of_moves()
  end

  test "can handle a winning game" do
    # trying to guess "hello" word
    # each element is a movement with
    # [ "guess", :expected_state_result_from_guess , turns left,  <current word status>, <letters used>]
    [
      ["a", :bad_guess, 6, ["_", "_", "_", "_", "_"], Enum.sort(["a"])],
      ["a", :already_used, 6, ["_", "_", "_", "_", "_"], Enum.sort(["a"])],
      ["e", :good_guess, 6, ["_", "e", "_", "_", "_"], Enum.sort(["a", "e"])],
      ["x", :bad_guess, 5, ["_", "e", "_", "_", "_"], Enum.sort(["a", "e", "x"])],
      ["l", :good_guess, 5, ["_", "e", "l", "l", "_"], Enum.sort(["a", "e", "x", "l"])],
      ["o", :good_guess, 5, ["_", "e", "l", "l", "o"], Enum.sort(["a", "e", "x", "l", "o"])],
      ["y", :bad_guess, 4, ["_", "e", "l", "l", "o"], Enum.sort(["a", "e", "x", "l", "o", "y"])],
      ["h", :won, 4, ["h", "e", "l", "l", "o"], Enum.sort(["a", "e", "x", "l", "o", "y", "h"])]
    ]
    |> test_sequence_of_moves()
  end

  test "can handle a losing game" do
    # trying to guess "hello" word
    # each element is a movement with
    # [ "guess", :expected_state_result_from_guess , turns left,  <current word status>, <letters used>]
    [
      ["a", :bad_guess, 6, ["_", "_", "_", "_", "_"], Enum.sort(["a"])],
      ["a", :already_used, 6, ["_", "_", "_", "_", "_"], Enum.sort(["a"])],
      ["e", :good_guess, 6, ["_", "e", "_", "_", "_"], Enum.sort(["a", "e"])],
      ["x", :bad_guess, 5, ["_", "e", "_", "_", "_"], Enum.sort(["a", "e", "x"])],
      ["l", :good_guess, 5, ["_", "e", "l", "l", "_"], Enum.sort(["a", "e", "x", "l"])],
      ["o", :good_guess, 5, ["_", "e", "l", "l", "o"], Enum.sort(["a", "e", "x", "l", "o"])],
      ["y", :bad_guess, 4, ["_", "e", "l", "l", "o"], Enum.sort(["a", "e", "x", "l", "o", "y"])],
      [
        "f",
        :bad_guess,
        3,
        ["_", "e", "l", "l", "o"],
        Enum.sort(["a", "e", "x", "l", "o", "y", "f"])
      ],
      [
        "r",
        :bad_guess,
        2,
        ["_", "e", "l", "l", "o"],
        Enum.sort(["a", "e", "x", "l", "o", "y", "f", "r"])
      ],
      [
        "x",
        :already_used,
        2,
        ["_", "e", "l", "l", "o"],
        Enum.sort(["a", "e", "x", "l", "o", "y", "f", "r"])
      ],
      [
        "w",
        :bad_guess,
        1,
        ["_", "e", "l", "l", "o"],
        Enum.sort(["a", "e", "x", "l", "o", "y", "f", "r", "w"])
      ],
      [
        "z",
        :lost,
        0,
        ["h", "e", "l", "l", "o"],
        Enum.sort(["a", "e", "x", "l", "o", "y", "f", "r", "w", "z"])
      ]
    ]
    |> test_sequence_of_moves()
  end

  def test_sequence_of_moves(script) do
    game = Game.new_game("hello")

    # go through all the elements in our "script"
    # make the move, check the results and
    # returns the updated game state ( this is check_one_move)
    Enum.reduce(script, game, &check_one_move/2)
  end

  defp check_one_move([guess, expected_state, turns, letters, used], game) do
    {game, tally} = Game.make_move(game, guess)

    assert tally.game_state == expected_state
    assert tally.turns_left == turns
    # FIXME - This fails because our "tally" function does not
    # handle letters yet
    assert tally.letters == letters
    assert tally.used == used

    game
  end
end
