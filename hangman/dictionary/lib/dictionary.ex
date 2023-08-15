defmodule Dictionary do
  @opaque t :: Dictionary.Runtime.Server.t()

  @spec random_word() :: String.t()
  defdelegate random_word(), to: Dictionary.Runtime.Server
end
