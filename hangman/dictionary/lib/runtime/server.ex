defmodule Dictionary.Runtime.Server do
  # As we are gonna use a Supervisor to handle this module
  # we need to provide some information to the supervisor.
  # (aka child_spec).
  # We can do it by hand or we can use a `behaviour` like `Agent`
  # here and let it write the proper "child_spec" function
  # Behaviours allow modules to "inherit" some functions and
  # so "behave" as that kind of element.
  use Agent

  @type t :: pid

  @me __MODULE__

  alias Dictionary.Impl.WordList

  # needs a param because the Supervisor calls it with a param
  @spec start_link(any) :: {:error, any} | {:ok, pid}
  def start_link(_init) do
    Agent.start_link(&WordList.start/0, name: @me)
  end

  @spec random_word() :: String.t()
  def random_word() do
    Agent.get(@me, &WordList.random_word/1)
  end
end
