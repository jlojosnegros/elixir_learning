defmodule FibCache do
  def fib(n) do
    {:ok, cache} = Cache.init()
    val = Cache.lookup(cache, n, calc_fib(n, cache))
    Cache.finish(cache)
    val
  end

  defp calc_fib(n, cache) do
    Cache.lookup(cache, n, fn ->
      calc_fib(n - 1, cache) + calc_fib(n - 2, cache)
    end)
  end
end
