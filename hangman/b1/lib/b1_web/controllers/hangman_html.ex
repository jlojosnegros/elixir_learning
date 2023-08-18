defmodule B1Web.HangmanHTML do
  use B1Web, :html

  # needed for Phoenix.HTML.Link.button function
  use Phoenix.HTML

  embed_templates "hangman_html/*"
end
