defmodule LssfHtsWeb.JobLive.New do
  use LssfHtsWeb, :live_view

  alias LssfHtsWeb.Utils.TimeUtils
  alias LssfHts.Scheduler.{Job, ScanEvent}
  alias LssfHts.Repo
  alias LssfHts.Devices

  use Timex

  @impl true
  def mount(_params, _session, socket) do
    devices = Devices.list_devices() |> Enum.map(&{&1.name, &1.id})
    job = %Job{scan_events: [%ScanEvent{}]}

    {:ok, assign(socket, job: job, devices: devices)}
  end

  def handle_info({:job_saved, _job}, socket) do
    {:noreply,
    socket
    |> put_flash(:info, "Job created")
    |> push_navigate(to: ~p"/jobs")}
  end

  def render(assigns) do
    ~H"""
    <.live_component
      module={LssfHtsWeb.JobLive.FormComponent}
      id="job-form"
      job={@job}
      action={:new}
      devices={@devices}
    />
    """
  end
end
