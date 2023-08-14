defmodule MyfibCacheTest do
  use ExUnit.Case
  doctest MyfibCache

  test "greets the world" do
    assert MyfibCache.hello() == :world
  end
end
