defmodule Fibcached do
  def fib(n) do
    # fib(n-1) + fib(n-2)
    {:ok, cache} = MyfibCache.init()
    val = MyfibCache.lookup(cache, n)

    MyfibCache.finish(cache)

    val
  end
end
