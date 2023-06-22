defmodule Dictionary do

  # module attribute: Created at compile-time
  # Value is calculated by running this at compile-time
  # so there is no need to release words.txt
  @word_list "assets/words.txt"
    |> File.read!()
    |> String.split(~r/\n/, trim: true)


  def random_word do
    @word_list
    |> Enum.random()
  end
end
