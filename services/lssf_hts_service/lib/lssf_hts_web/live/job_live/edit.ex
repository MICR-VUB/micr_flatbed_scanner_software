defmodule LssfHtsWeb.JobLive.Edit do
  use LssfHtsWeb, :live_view
  alias LssfHtsWeb.Utils.TimeUtils
  alias LssfHts.Scheduler.Job
  alias LssfHts.Repo
  alias LssfHts.Devices

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    job = Repo.get!(Job, id) |> Repo.preload(:scan_events)
    form_params = TimeUtils.convert_utc_to_local_form(job, "Europe/Brussels")
    job = Ecto.Changeset.change(job, form_params) |> Ecto.Changeset.apply_changes()
    devices = Devices.list_devices() |> Enum.map(&{&1.name, &1.id})

    {:ok, assign(socket, job: job, devices: devices)}
  end

  @impl true
  def handle_info({:job_saved, _job}, socket) do
    {:noreply,
    socket
    |> put_flash(:info, "Job updated successfully")
    |> push_navigate(to: ~p"/jobs")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.live_component
      module={LssfHtsWeb.JobLive.FormComponent}
      id="job-form"
      job={@job}
      action={:edit}
      devices={@devices}
      current_user={@current_user}
    />
    """
  end
end
