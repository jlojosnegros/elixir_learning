defmodule Cache do
  use Agent

  def init() do
    Agent.start_link(fn -> %{0 => 0, 1 => 1} end)
  end

  def finish(pid) do
    Agent.stop(pid)
  end

  def lookup(pid, number, if_not_found_fn) do
    Agent.get(pid, fn state -> Map.get(state, number) end)
    |> complete_if_not_found(pid, number, if_not_found_fn)
  end

  defp complete_if_not_found(_value = nil, pid, number, if_not_found_fn) do
    # value not found in the map (aka cache)
    if_not_found_fn.()
    |> set(pid, number)
  end

  defp complete_if_not_found(value, _pid, _number, _if_not_found_fn) do
    value
  end

  defp set(val, pid, key) do
    Agent.get_and_update(pid, fn state -> {val, Map.put(state, key, val)} end)
  end
end
