defmodule LssfHtsWeb.JobLive.New do
  use LssfHtsWeb, :live_view

  alias LssfHts.Scheduler.{Job, ScanEvent}
  alias LssfHts.Repo

  use Timex

  @impl true
def render(assigns) do
  ~H"""
    <.simple_form for={@form} phx-change="validate" phx-submit="save">
      <.input field={@form[:name]} label="Job Name" />
      <.input field={@form[:schedule]} label="Start Time" type="datetime-local" />
      <.input field={@form[:run_interval_minutes]} label="Run Every (mins)" />
      <.input field={@form[:run_until]} label="Run Until" type="datetime-local" />
      <.input field={@form[:enabled]} label="Enabled" type="checkbox" />

      <h3 class="mt-4 mb-2 text-lg font-semibold">Events</h3>
      <.inputs_for :let={scan_event_form} field={@form[:scan_events]}>
        <div class="mb-4 border rounded p-4">
          <.input field={scan_event_form[:step_name]} label="Step Name" />
          <.input field={scan_event_form[:device]} label="Device" />
          <.input field={scan_event_form[:output]} label="Output Path" />
          <.input field={scan_event_form[:resolution]} label="Resolution (dpi)" type="number" />
          <.input field={scan_event_form[:mode]} label="Mode" />
          <.input field={scan_event_form[:t]} label="Top (mm)" type="number" />
          <.input field={scan_event_form[:l]} label="Left (mm)" type="number" />
          <.input field={scan_event_form[:x]} label="Width (mm)" type="number" />
          <.input field={scan_event_form[:y]} label="Height (mm)" type="number" />
          <.button type="button" phx-click="remove_scan_event" phx-value-index={scan_event_form.index} class="mt-2">Remove</.button>
        </div>
      </.inputs_for>

      <.button type="button" phx-click="add_event" class="mb-4">Add Event</.button>

      <:actions>
        <.button>Save Job</.button>
      </:actions>
    </.simple_form>
  """
end


  @impl true
  def mount(_params, _session, socket) do
    job = %Job{
      scan_events: [
        %ScanEvent{}
      ]
    }

    changeset = Job.changeset(job, %{})
    {:ok, assign(socket, form: to_form(changeset))}
  end

  @impl true
  def handle_event("validate", %{"job" => job_params}, socket) do
    changeset =
      %Job{}
      |> Job.changeset(job_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  def handle_event("add_event", _params, socket) do
    scan_events = Ecto.Changeset.get_field(socket.assigns.form.source, :scan_events) ++ [%ScanEvent{}]
    changeset = Job.changeset(%Job{scan_events: scan_events}, %{})
    {:noreply, assign(socket, form: to_form(changeset))}
  end

  def handle_event("remove_scan_event", %{"index" => index_str}, socket) do
    index = String.to_integer(index_str)
    scan_events = Ecto.Changeset.get_field(socket.assigns.form.source, :scan_events)
    updated_scan_events = List.delete_at(scan_events, index)
    changeset = Job.changeset(%Job{scan_events: updated_scan_events}, %{})
    {:noreply, assign(socket, form: to_form(changeset))}
  end

  defp convert_local_to_utc!(%{"schedule" => schedule, "run_until" => run_until} = params, user_tz) do

    format = "{YYYY}-{0M}-{0D}T{h24}:{m}"

    [schedule_utc, until_utc] =
      [schedule, run_until]
      |> Enum.map(fn time_str ->
        time_str
        |> Timex.parse!(format)
        |> Timex.to_datetime(user_tz)
        |> Timex.Timezone.convert("UTC")
      end)

    params
    |> Map.put("schedule", schedule_utc)
    |> Map.put("run_until", until_utc)
  end



  def handle_event("save", %{"job" => job_params}, socket) do
    user_tz = "Europe/Brussels"

    job_params =
      try do
        convert_local_to_utc!(job_params, user_tz)
      rescue
        _ -> job_params
      end

    case Repo.insert(Job.changeset(%Job{}, job_params)) do
      {:ok, _job} ->
        {:noreply,
          socket
          |> put_flash(:info, "Job created")
          |> push_navigate( to: ~p"/jobs")}
      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
