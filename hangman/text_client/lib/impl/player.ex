defmodule TextClient.Impl.Player do
  @typep game :: Hangman.game()
  @typep tally :: Hangman.tally()
  @typep state :: {game, tally}

  @spec start() :: :ok
  def start() do
    # need to end calling interact
    # so we need a game and a tally

    # game is quite easy to get
    game = Hangman.new_game()

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

  def interact(_state = {_game, tally}) do
    # take current state

    # give feedback about the state
    tally
    |> feedback_for()
    |> IO.puts()

    # display current word

    # get next guess

    # make move

    # loop again
    # interact(state)
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
end