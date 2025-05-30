defmodule LssfHtsWeb.JobLive.Index do
  use LssfHtsWeb, :live_view

  alias LssfHts.Scheduler

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :jobs, Scheduler.list_jobs())}
  end

  @impl true
  def handle_event("toggle", %{"id" => id}, socket) do
    job = Scheduler.get_job!(id)

    case Scheduler.toggle_job_enabled(job, !job.enabled) do
      {:ok, updated_job} ->
        if !job.enabled do
          Scheduler.start_job(job)
        end
        {:noreply, stream_insert(socket, :jobs, updated_job)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to toggle job.")}
    end
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    job = Scheduler.get_job!(id)
    {:ok, _} = Scheduler.delete_job(job)
    {:noreply, stream_delete(socket, :jobs, job)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.header class="mb-4">All Scheduled Jobs</.header>
    <.button class="mb-4">
      <.link patch={~p"/jobs/new"} class="btn btn-primary">Create Job</.link>
    </.button>
    <.table id="jobs" rows={@streams.jobs}>
    <:col :let={{_id, job}} label="Active">
        <.input
          type="checkbox"
          name="enabled_toggle"
          checked={job.enabled}
          phx-click="toggle"
          phx-value-id={job.id}
        />
      </:col>
      <:col :let={{_id, job}} label="Name">
        <%= job.name %>
      </:col>
      <:col :let={{_id, job}} label="Actions">
        <.link patch={~p"/jobs/#{job.id}/edit"} class="btn btn-sm btn-outline">Edit</.link>
        <.button phx-click="delete" phx-value-id={job.id} data-confirm="Are you sure?" class=" bg-red-300 ml-2">
          <.icon name="hero-trash-solid" class="w-6 h-6 bg-black" />
        </.button>
      </:col>
    </.table>
    """
  end
end
