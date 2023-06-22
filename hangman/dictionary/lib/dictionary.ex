defmodule Dictionary do
  def word_list do
    words = File.read!("assets/words.txt")
    # Split by new-line and trim resulting strings
    String.split(words, ~r/\n/, trim: true)
  end

  def random_word do
    Enum.random(word_list())
  end
end
