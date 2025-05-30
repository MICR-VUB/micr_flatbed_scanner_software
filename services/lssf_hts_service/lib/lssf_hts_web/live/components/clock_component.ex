defmodule LssfHtsWeb.ClockComponent do
  use Phoenix.LiveComponent

  def mount(socket) do
    socket =
      socket
      |> assign(id: "live-clock")
    {:ok, socket}
  end

  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id} phx-hook="ClockHook" class="font-mono text-xs text-zinc-600">
      <span>Current Time: </span>
      <p class="inline" id={"#{@id}-time"}></p>
    </div>
    """
  end
end
