defmodule TextClient.Impl.Player do
  @typep game :: Hangman.game()
  @typep tally :: Hangman.tally()
  @typep state :: {game, tally}

  @spec start(game()) :: :ok
  def start(game) do
    # need to end calling interact
    # so we need a game and a tally

    # to get a game from the remote server
    # we need to call connect... but
    # that seems to be off limits from
    # the implementation and more related
    # with the networking and runtime.
    # That is why we have created a new
    # runtime module (RemoteHangman) to
    # handle that implementation details.
    #
    # We can change the line and call "connect" from here
    # but that would mean the implementention depends on
    # the runtime ... which is not a good thing.
    # For that reason we are gonna change the start
    # function to accept a game  instead of creating it
    # internally

    # but there is no way to get a tally
    # in the Hangman API ( so lets create it)
    tally = Hangman.tally(game)

    interact({game, tally})
  end

  @spec interact(state) :: :ok

  def interact({_game, _tally = %{game_state: :won}}) do
    IO.puts("Congratulations. You Won!")
  end

  def interact({_game, tally = %{game_state: :lost}}) do
    IO.puts("Sorry, you lost... the word was #{tally.letters}")
  end

  def interact(_state = {game, tally}) do
    tally
    |> feedback_for()
    |> IO.puts()

    tally
    |> current_word()
    |> IO.puts()

    tally = Hangman.make_move(game, get_guess())
    interact({game, tally})
  end

  # @type state :: :initializing | :won | :lost | :good_guess | :bad_guess | :already_used

  defp feedback_for(tally = %{game_state: :initializing}) do
    "Welcome! I am thinking of a #{tally.letters |> length} letters word"
  end

  defp feedback_for(_tally = %{game_state: :good_guess}), do: "Good guess!"

  defp feedback_for(_tally = %{game_state: :bad_guess}),
    do: "Sorry, that letter is not in the word"

  defp feedback_for(_tally = %{game_state: :already_used}),
    do: "Please Focus! You already used that letter!"

  defp current_word(tally) do
    # IO.puts can handle a string or a chardata() type
    # A possible definition of chardata is "a list of
    # writeable items that is writeable itself" and it cames
    # from the old good times when Erlang needed to
    # handle big lists of data from different sources
    # Thats the reason why we return a list here
    # TODO - Investigate about chardata type
    [
      "Word so far ",
      tally.letters |> Enum.join(" "),
      "    turns left: ",
      tally.turns_left |> to_string,
      "    used so far: ",
      tally.used |> Enum.join(",")
    ]
  end

  defp get_guess() do
    # this code isn't perfect by any means
    # because it does not do any validation
    # about the user input, but for now
    # it should do it.
    IO.gets("Next letter: ")
    # IO.gets return a complete line including linefeed
    # So we use trim to eliminate it
    |> String.trim()
    |> String.downcase()
  end
end
