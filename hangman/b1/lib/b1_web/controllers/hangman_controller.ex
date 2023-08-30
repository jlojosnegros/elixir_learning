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

    # NOTE - "conn" is unmutable, we need to capture
    # the new conn
    conn
    |> put_session(:game, game)
    # here we use again the PRG to avoid duplicated
    # modifications.
    |> redirect(to: ~p"/hangman/current")
  end

  def update(conn, params) do
    # The guess comes in the params from the form.
    # In the template we have instructed Elixir to
    # save the form data into an structure(map) call
    # "make_move", and the "guess" letter in a field
    # called "guess" ... so here we can read it.
    guess = params["make_move"]["guess"]

    # We need to clean the input parameter to improve UX
    put_in(conn.params["make_move"]["guess"], "")
    # We can get the game from the session as we have
    # stored it earlier in the new method.
    |> get_session(:game)
    # Then we just need to call the Hangman server
    # to make the move with the readed data.
    # NOTE - This fails because "game" is nil **WHY**??
    # Game was nil because "put_session" does not modify
    # the actual "conn", as it is unmutable, but returns
    # a new one that we need to capture.
    |> Hangman.make_move(guess)

    # Here we just do not render any page.
    # instead we are using redirection.
    # This technique is called PRG for
    # POST-REDIRECT-GET
    # Whenever you hit reload in a browser it resend
    # the last request. If the last request is a POST/PUT
    # the request to change the server status will be sent again
    # and that could cause problems.
    # TO avoid that servers *DO NOT RENDER PAGES ON PUT/POST*
    # instead they redirect the browser to another page where
    # the result of the change is showed. This way the browser
    # send a GET request as the last one and any RELOAD will only
    # ask for the same status not triggering any duplicated change.
    redirect(conn, to: ~p"/hangman/current")
  end

  def show(conn, _params) do
    tally =
      conn
      |> get_session(:game)
      |> Hangman.tally()

    render(conn, "game.html", tally: tally)
  end
end
