defmodule B2Web.Live.Game do
  use B2Web, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <p>
      Hello Hangman
    </p>
    """
  end
end
