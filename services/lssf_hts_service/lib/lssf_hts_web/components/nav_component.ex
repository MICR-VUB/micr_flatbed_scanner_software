defmodule LssfHtsWeb.NavComponent do
  use LssfHtsWeb, :live_component

  def render(assigns) do
    ~H"""
    <nav class="flex w-full items-center gap-4 justify-between">
      <%!-- Logo --%>
      <a class="flex flex-row gap-4 items-center" href="/">
        <img src={~p"/images/logo.svg"} width="36" />
        <span class="font-bold">HYPHERGRAPH</span>
      </a>
      <%!-- Version Pill --%>
      <p class="bg-brand/5 text-brand rounded-full px-2 font-medium leading-6 ml-4">
        v<%= Application.spec(:lssf_hts, :vsn) |> to_string() %>
      </p>
      <%!-- Navigation Links --%>
      <.nav_link to={~p"/jobs"} is_active={@view in [LssfHtsWeb.JobLive.Index, LssfHtsWeb.JobLive.New, LssfHtsWeb.JobLive.Edit]}>Home</.nav_link>
      <.nav_link to={~p"/devices"} is_active={@view == LssfHtsWeb.DeviceLive.Index}>Devices</.nav_link>

      <%!-- Clock widget --%>
      <.live_component module={LssfHtsWeb.ClockComponent} id="live-clock" class="ml-auto"/>
    </nav>
    """
  end
end
