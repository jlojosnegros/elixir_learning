defmodule Dictionary do
  @opaque t :: Dictionary.Runtime.Server.t()

  @spec start_link :: {:error, any} | {:ok, pid}
  defdelegate start_link(), to: Dictionary.Runtime.Server

  @spec random_word(t()) :: String.t()
  defdelegate random_word(state), to: Dictionary.Runtime.Server
end
