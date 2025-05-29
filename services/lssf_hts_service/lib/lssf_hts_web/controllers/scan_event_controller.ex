defmodule LssfHtsWeb.ScanEventController do
  use LssfHtsWeb, :controller

  alias LssfHts.Scheduler
  alias LssfHts.Scheduler.ScanEvent

  def index(conn, _params) do
    scan_events = Scheduler.list_scan_events()
    render(conn, :index, scan_events: scan_events)
  end

  def new(conn, _params) do
    changeset = Scheduler.change_scan_event(%ScanEvent{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"scan_event" => scan_event_params}) do
    case Scheduler.create_scan_event(scan_event_params) do
      {:ok, scan_event} ->
        conn
        |> put_flash(:info, "Scan event created successfully.")
        |> redirect(to: ~p"/scan_events/#{scan_event}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    scan_event = Scheduler.get_scan_event!(id)
    render(conn, :show, scan_event: scan_event)
  end

  def edit(conn, %{"id" => id}) do
    scan_event = Scheduler.get_scan_event!(id)
    changeset = Scheduler.change_scan_event(scan_event)
    render(conn, :edit, scan_event: scan_event, changeset: changeset)
  end

  def update(conn, %{"id" => id, "scan_event" => scan_event_params}) do
    scan_event = Scheduler.get_scan_event!(id)

    case Scheduler.update_scan_event(scan_event, scan_event_params) do
      {:ok, scan_event} ->
        conn
        |> put_flash(:info, "Scan event updated successfully.")
        |> redirect(to: ~p"/scan_events/#{scan_event}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, scan_event: scan_event, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    scan_event = Scheduler.get_scan_event!(id)
    {:ok, _scan_event} = Scheduler.delete_scan_event(scan_event)

    conn
    |> put_flash(:info, "Scan event deleted successfully.")
    |> redirect(to: ~p"/scan_events")
  end
end
