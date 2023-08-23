defmodule B1Web.HangmanHTML do
  use B1Web, :html

  # needed for Phoenix.HTML.Link.button function
  use Phoenix.HTML

  embed_templates "hangman_html/*"

  def figure_for(0) do
    """
      +---+
      |   |
      O   |
     /|\\  |
     / \\  |
          |
    =========
    """
  end

  def figure_for(1) do
    """
      +---+
      |   |
      O   |
     /|\\  |
     /    |
          |
    =========
    """
  end

  def figure_for(2) do
    """
      +---+
      |   |
      O   |
     /|\\  |
          |
          |
    =========
    """
  end

  def figure_for(3) do
    """
      +---+
      |   |
      O   |
     /|   |
          |
          |
    =========
    """
  end

  def figure_for(4) do
    """
      +---+
      |   |
      O   |
      |   |
          |

    =========
    """
  end

  def figure_for(5) do
    """
      +---+
      |   |
      O   |
          |
          |
          |
    =========
    """
  end

  def figure_for(6) do
    """
      +---+
      |   |
          |
          |
          |
          |
    =========
    """
  end

  def figure_for(7) do
    """
      +---+
          |
          |
          |
          |
          |
    =========
    """
  end
end
