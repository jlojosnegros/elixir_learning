defmodule B2Web.Live.Game.WordSoFar do
  use B2Web, :live_component

  def mount(socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <p>
      In WordSoFar
    </p>
    """
  end
end
