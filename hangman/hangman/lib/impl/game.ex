defmodule Hangman.Impl.Game do
  alias Hangman.Type

  # NOTE - It is a convention to  define the module type as `t`
  #     Syntax is very like the data definition but using type names instead of values
  #     Note that parenthesis after `t` are not required unless you want to parameterize a type
  # NOTE - Structs are named always after the module.
  #     Elixir declares __MODULE__ as the name of the module
  #     so this is a way to avoid typing and errors if the name of the module changes.
  @type t :: %__MODULE__{
          turns_left: integer,
          game_state: Type.state(),
          letters: list(String.t()),
          used: MapSet.t(String.t())
        }

  # NOTE - defstruct allow us to define a "supermap" type of struct.
  #     Each field can have a initial value
  #     The name of the struct is the same as the name of the Module where it is defined.
  defstruct(
    turns_left: 7,
    game_state: :initializing,
    letters: [],
    used: MapSet.new()
  )

  @spec new_game :: t()
  def new_game do
    Dictionary.random_word()
    |> new_game()
  end

  @spec new_game(String.t()) :: t()
  def new_game(word) do
    # NOTE - Structs are named always after the module.
    #     Elixir declares __MODULE__ as the name of the module
    #     so this is a way to avoid typing and errors if the name of the module changes.
    %__MODULE__{
      # NOTE - As we are using Dictionary we need to add it to mix.exs
      #     Check that file to see how to add a relative module.
      letters: word |> String.codepoints()
    }

    # NOTE - To improve testing we need to be able to check for the proper word
    #     *BUT* we cannot do it if the word is random.
    #     To solve this situation we create this new function where the word is
    #     choosen by the incoming parameter
    #     *BUT* as it is not part of the API it cannot be use by clients
    #     **AND** as the new_game used by clients depends on this implementation
    #     everythin is coherent
  end

  #####################################################################################
  @spec make_move(t, String.t()) :: {t, Type.tally()}
  def make_move(game = %{game_state: state}, _guess)
      when state in [:won, :lost] do
    game
    |> return_with_tally()
  end

  def make_move(game, guess) do
    # we need to know if the guess has been alredy used.
    # if so we will not penalize the user, just return a warning
    # we need to change make_move behaviour if the guess has been already used
    # For that we need a call to MapSet.member?() but we cannot do that in
    # a guard clause cause MapSet is not a basic member.
    # So we create a new private function `accept_guess` and use pattern matching
    accept_guess(game, guess, MapSet.member?(game.used, guess))
    |> return_with_tally()
  end

  #####################################################################################

  # We need to return a tally from a game.
  def tally(game) do
    %{
      turns_left: game.turns_left,
      game_state: game.game_state,
      letters: game |> reveal_guessed_letters(),
      used: game.used |> MapSet.to_list() |> Enum.sort()
    }
  end

  # NOTE - This is just a "comodity" function right now.
  #     We need to return a tuple {game, tally} from make_move
  #     We have created accept_guess that returns an updated game
  #     and we need to create a tally from that updated game.
  #     we could have done
  #     ```
  #     game = accept_guess(game, guess, already_used)
  #     {game, tally(game)}
  #     ```
  #     But that does not seems like Elixir.
  #     Also with this function we can have some kind of homogeneous
  #     way to handle return values in all the make_move variants
  @spec return_with_tally(t) :: {t, Type.tally()}
  defp return_with_tally(game) do
    {game, tally(game)}
  end

  #####################################################################################
  # Get a game and a guess and return a new game
  @spec accept_guess(t, String.t(), bool) :: t
  defp accept_guess(game, _guess, _guess_already_used = true) do
    %{game | game_state: :already_used}
  end

  defp accept_guess(game, guess, _guess_already_used) do
    # Here we know the guess is a new one
    # now we need to know if is correct or not
    # and score it
    # we need to know if the guess is one of the
    # letters
    # Enum.member?(game.letters, guess)
    # would do it.
    #
    # This could be a way, but this is not the Elixir way
    # updated_game = %{game | used: MapSet.put(game.used, guess)}
    # is_ok = Enum.member?(updated_game.letters, guess)
    # if ...

    # here we have the updated game
    %{game | used: MapSet.put(game.used, guess)}
    |> score_guess(Enum.member?(game.letters, guess))
  end

  #####################################################################################
  @spec score_guess(t, boolean) :: t
  defp score_guess(game, _good_guess = true) do
    # TLDR:  guessed all letters? -> :won | :good_guess
    #
    # if all the letters has been guessed then we :won
    # otherwise is just a :good_guess

    # We know we have guessed all the letters if all letters in
    # the word we wanna guess are in the used set, meaning that
    # the user has tryied them all.

    new_state = maybe_won(MapSet.subset?(MapSet.new(game.letters), game.used))
    %{game | game_state: new_state}
  end

  @spec score_guess(t, boolean) :: t
  defp score_guess(game = %{turns_left: 1}, _bad_guess) do
    # TLDR: turns_left == 1 ? -> :lost | :bad_guess
    # this is turns_left == 1 -> :lost
    %{game | game_state: :lost, turns_left: 0}
  end

  @spec score_guess(t, boolean) :: t
  defp score_guess(game, _bad_guess) do
    # TLDR: turns_left == 1 ? -> :lost | :bad_guess
    # this is turns_left != 1 -> :bad_guess
    %{game | game_state: :bad_guess, turns_left: game.turns_left - 1}
  end

  #####################################################################################
  defp maybe_won(true), do: :won
  defp maybe_won(_), do: :good_guess
  #####################################################################################
  defp reveal_guessed_letters(game = %{game_state: :lost}) do
    game.letters
  end

  defp reveal_guessed_letters(game) do
    game.letters
    |> Enum.map(fn letter -> MapSet.member?(game.used, letter) |> maybe_reveal(letter) end)
  end

  #####################################################################################
  defp maybe_reveal(_is_member = true, letter), do: letter
  defp maybe_reveal(_is_member, _letter), do: "_"
end
