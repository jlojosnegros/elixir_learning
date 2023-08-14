defmodule MyfibCache do
  use Agent

  def init() do
    IO.puts("init")
    Agent.start_link(fn -> %{0 => 1, 1 => 1} end)
  end

  def finish(pid) do
    IO.puts("finish")
    Agent.stop(pid)
  end

  def lookup(cache, n) do
    IO.puts("lookup n: #{n}")

    Agent.get(cache, fn state -> Map.get(state, n) end)
    |> calc_if_do_not_exist(n, cache)
  end

  defp calc_if_do_not_exist(_value = nil, n, cache) do
    IO.puts("nil n: #{n}")
    val = lookup(cache, n - 1) + lookup(cache, n - 2)
    Agent.update(cache, fn state -> Map.put(state, n, val) end)

    val
  end

  defp calc_if_do_not_exist(value, n, _cache) do
    IO.puts("value: #{value} n: #{n}")
    value
  end
end
