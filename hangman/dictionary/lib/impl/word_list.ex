defmodule Dictionary.Impl.WordList do
  @type t :: %__MODULE__{
          word_list: list(String.t())
        }
  defstruct(word_list: [])
  @spec start() :: t()
  def start() do
    %__MODULE__{
      word_list: read_words_from_file("../../assets/words.txt")
    }
  end

  @spec random_word(t()) :: String.t()
  def random_word(state) do
    state.word_list
    |> Enum.random()
  end

  @spec read_words_from_file(String.t()) :: list(String.t())
  defp read_words_from_file(filename) do
    filename
    |> Path.expand(__DIR__)
    |> File.read!()
    |> String.split(~r/\n/, trim: true)
  end
end
