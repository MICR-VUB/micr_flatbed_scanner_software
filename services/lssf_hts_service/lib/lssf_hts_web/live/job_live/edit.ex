defmodule LssfHtsWeb.JobLive.Edit do
  use LssfHtsWeb, :live_view

  alias LssfHts.Scheduler.{Job, ScanEvent}
  alias LssfHts.Repo

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    job = Repo.get!(Job, id) |> Repo.preload(:scan_events)
    changeset = Job.changeset(job, %{})
    {:ok, assign(socket, job: job, form: to_form(changeset))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.simple_form for={@form} phx-change="validate" phx-submit="save">
      <.input field={@form[:name]} label="Job Name" />
      <.input field={@form[:schedule]} label="Start Time" type="datetime-local" />
      <.input field={@form[:run_interval_minutes]} label="Run Every (mins)" />
      <.input field={@form[:run_until]} label="Run Until" type="datetime-local" />
      <.input field={@form[:enabled]} label="Enabled" type="checkbox" />

      <h3 class="mt-4 mb-2 text-lg font-semibold">Scan Events</h3>
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

      <.button type="button" phx-click="add_scan_event" class="mb-4">Add Scan Event</.button>

      <:actions>
        <.button>Save Job</.button>
      </:actions>
    </.simple_form>
    """
  end

  @impl true
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
    case Repo.update(Job.changeset(socket.assigns.job, job_params)) do
      {:ok, _job} ->
        {:noreply,
         socket
         |> put_flash(:info, "Job updated successfully.")
         |> push_navigate(to: ~p"/jobs")}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
