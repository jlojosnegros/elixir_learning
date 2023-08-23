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

  @status_fields %{
    initializing: {"initializing", "guess the word, a letter at a time"},
    good_guess: {"good-guess", "Good guess"},
    bad_guess: {"bad-guess", "Sorry, that is a bad guess"},
    won: {"won", "You won!"},
    lost: {"lost", "Sorry you lost!"},
    already_used: {"already-used", "You already used that letter"}
  }
  def move_status(status) do
    {class, message} = @status_fields[status]
    ~s(<div class="status #{class}">#{message}</div>)
  end

  def continue_or_try_again(_conn, status) when status in [:won, :lost] do
    button("Try again", to: ~p"/hangman")
  end

  def continue_or_try_again(conn, _status) do
    form_for(
      conn,
      ~p"/hangman",
      [as: "make_move", method: :put],
      fn f ->
        [text_input(f, :guess), " ", submit("Make next guess")]
      end
    )
  end
end
