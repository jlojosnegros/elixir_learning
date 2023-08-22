defmodule B1Web.HangmanController do
  alias Phoenix.Router
  use B1Web, :controller

  def index(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :index, layout: false)
  end

  def new(conn, _params) do
    # here is where we need to create a new game
    game = Hangman.new_game()

    # we need some way to keep track of the game
    # for each user.
    # Here is where user sessions come in handy
    # We can create a key-value map that phoenix
    # will keep for us and that will let us keep
    # track of the status between calls
    # notice that html calls are stateless otherwise
    #
    # Out "game" variable is a token the server has
    # given us to identify a game so that is what we
    # are going to save
    put_session(conn, :game, game)


    # At last ... we need to show something to the user.
    # So we need to "render" some web page and show
    # some game information on it.
    # Hangman server provides a way to get information
    # from a particular game, the "tally" function
    tally = Hangman.tally(game)

    # And here we use the "assign feature" from phoenix
    # to make the "tally" variable available in the
    # view ( and template ) under the name "tally"
    # note: in the template we can refer to it inside the
    # elixir code blocks (<% %>) as "@tally"
    render(conn, "game.html", tally: tally)
  end
end
