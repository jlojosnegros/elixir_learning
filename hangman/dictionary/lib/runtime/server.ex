defmodule Dictionary.Runtime.Server do
  @type t :: pid

  alias Dictionary.Impl.WordList

  @spec start_link() :: {:error, any} | {:ok, pid}
  def start_link() do
    Agent.start_link(&WordList.start/0)
  end

  @spec random_word(pid()) :: String.t()
  def random_word(pid) do
    Agent.get(pid, &WordList.random_word/1)
  end
end
