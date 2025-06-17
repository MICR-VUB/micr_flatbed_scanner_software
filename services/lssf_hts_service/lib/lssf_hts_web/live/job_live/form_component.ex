defmodule LssfHtsWeb.JobLive.FormComponent do
  use LssfHtsWeb, :live_component

  alias LssfHts.Scheduler.{Job, ScanEvent}
  alias LssfHtsWeb.Utils.TimeUtils
  alias LssfHts.Repo

  def update(assigns, socket) do
    changeset = Job.changeset(assigns.job, %{})
    {:ok,
    socket
    |> assign(assigns)
    |> assign(form: to_form(changeset))
    |> assign_new(:devices, fn -> [] end)}
  end


  def render(assigns) do
    ~H"""
    <div>
      <.simple_form for={@form} id="job-form" phx-change="validate" phx-submit="save" phx-target={@myself}>
        <.input field={@form[:name]} label="Job Name" />
        <.input field={@form[:schedule]} label="Start Time" type="datetime-local" />
        <.input field={@form[:run_interval_minutes]} label="Run Every (mins)" />
        <.input field={@form[:run_until]} label="Run Until" type="datetime-local" />
        <.input field={@form[:enabled]} label="Enabled" type="checkbox" />

        <h3 class="mt-4 mb-2 text-lg font-semibold">Scan Events</h3>
        <.inputs_for :let={scan_event_form} field={@form[:scan_events]}>
          <div class="mb-4 border rounded p-4">
            <.input field={scan_event_form[:step_name]} label="Step Name" />
            <.input type="select" field={scan_event_form[:device_id]} label="Device" options={@devices} />
            <.input
              field={scan_event_form[:output]}
              label="Output Path"
              placeholder="/home/scanners/piet/scan.tiff"
              help="Absolute file path on the machine where output files should be saved. For example: /home/scanners/piet/scan.tiff"
            />
            <.input field={scan_event_form[:resolution]} label="Resolution (dpi)" type="number" />
            <.input field={scan_event_form[:mode]} label="Mode" />
            <.input field={scan_event_form[:t]} label="Top (mm)" type="number" />
            <.input field={scan_event_form[:l]} label="Left (mm)" type="number" />
            <.input field={scan_event_form[:x]} label="Width (mm)" type="number" />
            <.input field={scan_event_form[:y]} label="Height (mm)" type="number" />
            <.button type="button" phx-click="remove_scan_event" phx-target={@myself} phx-value-index={scan_event_form.index} class="mt-2">Remove</.button>
          </div>
        </.inputs_for>

        <.button type="button" phx-click="add_scan_event" phx-target={@myself} class="mb-4">Add Scan Event</.button>

        <:actions>
          <.button>Save Job</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def handle_event("validate", %{"job" => job_params}, socket) do
    changeset =
      socket.assigns.job
      |> Job.changeset(job_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  def handle_event("add_scan_event", _params, socket) do
    scan_events =
      Ecto.Changeset.get_field(socket.assigns.form.source, :scan_events) ++ [%ScanEvent{}]

    changeset =
      socket.assigns.job
      |> Job.changeset(%{})
      |> Ecto.Changeset.put_assoc(:scan_events, scan_events)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  def handle_event("remove_scan_event", %{"index" => index_str}, socket) do
    index = String.to_integer(index_str)

    scan_events =
      Ecto.Changeset.get_field(socket.assigns.form.source, :scan_events)

    updated_scan_events = List.delete_at(scan_events, index)

    changeset =
      socket.assigns.job
      |> Job.changeset(%{})
      |> Ecto.Changeset.put_assoc(:scan_events, updated_scan_events)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  def handle_event("save", %{"job" => job_params}, socket) do
    user_tz = "Europe/Brussels"
    job_params = TimeUtils.convert_local_to_utc!(job_params, user_tz)
    current_user = socket.assigns.current_user

    case socket.assigns.action do
      :new ->
        job_params = Map.put(job_params, "user_id", current_user.id)
        case Repo.insert(Job.changeset(%Job{}, job_params)) do
          {:ok, job} ->
            send(self(), {:job_saved, job})
            {:noreply, socket}
          {:error, changeset} ->
            {:noreply, assign(socket, form: to_form(changeset))}
        end

      :edit ->
        job = socket.assigns.job

        # Authorization: only allow if user is owner or admin
        if job.user_id == current_user.id or current_user.admin do
          case Repo.update(Job.changeset(job, job_params)) do
            {:ok, job} ->
              send(self(), {:job_saved, job})
              {:noreply, socket}
            {:error, changeset} ->
              {:noreply, assign(socket, form: to_form(changeset))}
          end
        else
          {:noreply,
            socket
            |> put_flash(:error, "You are not authorised to perform this action.")
            |> redirect(to: "/")}
        end
    end
  end
end
