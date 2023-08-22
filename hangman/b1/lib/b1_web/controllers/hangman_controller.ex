defmodule B1Web.HangmanController do
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

  def update(conn, params) do
    # We can get the game from the session as we have
    # stored it earlier in the new method.
    game = get_session(conn, :game)

    # The guess comes in the params from the form.
    # In the template we have instructed Elixir to
    # save the form data into an structure(map) call
    # "make_move", and the "guess" letter in a field
    # called "guess" ... so here we can read it.
    guess = params["make_move"]["guess"]

    # Then we just need to call the Hangman server
    # to make the move with the readed data.
    tally = Hangman.make_move(game,guess)

    # And render again the same template with the
    # new tally information returned by server
    render(conn, "game.html", tally: tally)
  end
end
