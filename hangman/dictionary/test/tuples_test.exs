defmodule TuplesTest do
  use ExUnit.Case

  test "swapping" do
    assert Tuples.swap({1, 2}) == {2, 1}
  end

  test "mirror" do
    assert Tuples.mirror({3, 3}) == true
    assert Tuples.mirror({2, 3}) == false
  end
end
