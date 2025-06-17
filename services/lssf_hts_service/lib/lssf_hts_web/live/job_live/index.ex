defmodule LssfHtsWeb.JobLive.Index do
  use LssfHtsWeb, :live_view

  alias LssfHts.Scheduler
  alias LssfHtsWeb.Utils.TimeUtils

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
  def handle_event("run_now", %{"id" => id}, socket) do
    job = LssfHts.Scheduler.get_job!(id)
    |> LssfHts.Repo.preload(scan_events: :device)

    case LssfHts.Scheduler.run_job_once(job) do
      :ok ->
        {:noreply, put_flash(socket, :info, "Job #{job.name} executed successfully.")}
      {:error, reason} ->
        {:noreply, put_flash(socket, :error, "Job failed: #{inspect(reason)}")}
    end
  end


  @impl true
  def render(assigns) do
    ~H"""
    <.header>All Scheduled Jobs
      <:actions>
        <.link patch={~p"/jobs/new"} class="btn btn-primary">
          <.button class="mb-4">
            Create Job
          </.button>
        </.link>
      </:actions>
    </.header>
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
        <:col :let={{_id, job}} label="Starts">
          <%= Timex.format!(TimeUtils.convert_utc_to_local_form(job.schedule), "{0D}/{0M}/{YYYY} {h24}:{m}") %>
        </:col>
        <:col :let={{_id, job}} label="Finishes">
          <%= Timex.format!(TimeUtils.convert_utc_to_local_form(job.run_until), "{0D}/{0M}/{YYYY} {h24}:{m}") %>
        </:col>
        <:col :let={{_id, job}} label="Runs every (minutes)">
          <%= job.run_interval_minutes %>
        </:col>
        <:action :let={{_id, job}}>
          <.link patch={~p"/jobs/#{job.id}/edit"} class="underline">Edit</.link>
          <.warning_button phx-click="delete" phx-value-id={job.id} data-confirm="Are you sure?" class="ml-2">
            <.icon name="hero-trash-solid" class="w-6 h-6" />
          </.warning_button>
          <.button
            class="ml-2"
            phx-click="run_now"
            data-confirm="Are you sure?"
            phx-value-id={job.id}
          >
            Run Now
          </.button>
        </:action>
      </.table>
    """
  end
end
