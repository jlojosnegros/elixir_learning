defmodule Tuples do
  def swap({a, b}) do
    {b, a}
  end

  def mirror({a, a}), do: true
  def mirror({_, _}), do: false
end
