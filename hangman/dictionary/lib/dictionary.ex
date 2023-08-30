defmodule Dictionary do
  @opaque t :: Dictionary.Impl.WordList.t()

  @spec start() :: t()
  defdelegate start(), to: Dictionary.Impl.WordList

  @spec random_word(t()) :: String.t()
  defdelegate random_word(state), to: Dictionary.Impl.WordList
end
