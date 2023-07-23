defmodule Hangman.Impl.Game do
  # NOTE - It is a convention to  define the module type as `t`
  #     Syntax is very like the data definition but using type names instead of values
  #     Note that parenthesis after `t` are not required unless you want to parameterize a type
  @type t :: %Hangman.Impl.Game{
          turns_left: integer,
          game_state: Hangman.state(),
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

  def new_game do
    %Hangman.Impl.Game{
      # NOTE - As we are using Dictionary we need to add it to mix.exs
      #     Check that file to see how to add a relative module.
      letters: Dictionary.random_word() |> String.codepoints()
    }
  end
end
