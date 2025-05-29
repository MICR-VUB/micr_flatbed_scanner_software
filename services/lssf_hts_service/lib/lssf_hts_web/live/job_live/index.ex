defmodule LssfHtsWeb.JobLive.Index do
  use LssfHtsWeb, :live_view

  alias LssfHts.Scheduler
  alias LssfHts.Scheduler.Job

  def mount(_params, _session, socket) do
    {:ok, stream(socket, :jobs, Scheduler.list_jobs)}
  end

  def handle_event("toggle", %{"id" => id}, socket) do
    job = Scheduler.get_job!(id)
    {:ok, _job} = Scheduler.update_job(job, %{enabled: !job.enabled})

    {:noreply, stream(socket, :jobs, Scheduler.list_jobs)}
  end

  def render(assigns) do
    ~H"""
    <.header class="mb-4">Your Scheduled Jobs</.header>
    <div class="mb-4">
      <.link patch={~p"/jobs/new"} class="btn btn-primary">New Job</.link>
    </div>
    <.table id="jobs" rows={@streams.jobs}>
      <:col :let={{id, job}} label="Name">
        <%= job.name %>
      </:col>
      <:col :let={{id, job}} label="Schedule">
        <%= job.schedule %>
      </:col>
      <:col :let={{id, job}} label="Enabled">
        <.button phx-click="toggle" phx-value-id={job.id} class={if job.enabled, do: "btn btn-success", else: "btn btn-secondary"}>
          <%= if job.enabled, do: "On", else: "Off" %>
        </.button>
      </:col>
    </.table>
    """
  end
end
