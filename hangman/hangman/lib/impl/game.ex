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
    new_game(Dictionary.random_word())
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
end
