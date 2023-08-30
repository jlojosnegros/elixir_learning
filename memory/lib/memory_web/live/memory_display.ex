defmodule MemoryWeb.Live.MemoryDisplay do
  use MemoryWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, schedule_tick_and_update_assing(socket)}
  end

  def handle_info(:tick, socket) do
    {:noreply, schedule_tick_and_update_assing(socket)}
  end

  defp schedule_tick_and_update_assing(socket) do
    Process.send_after(self(), :tick, 1000)
    assign(socket, :memory, :erlang.memory())
  end

  def render(assigns) do
    ~L"""
    <table>
      <%= for {name, value } <- assigns.memory do %>
        <tr>
          <th><%= name %></tr>
          <td><%= value %></td>
        </tr>
      <% end %>
    </table>
    """
  end
end
