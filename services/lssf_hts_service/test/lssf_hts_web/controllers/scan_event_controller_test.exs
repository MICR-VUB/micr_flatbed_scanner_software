defmodule LssfHtsWeb.ScanEventControllerTest do
  use LssfHtsWeb.ConnCase

  import LssfHts.SchedulerFixtures

  @create_attrs %{started_at: ~U[2025-05-28 10:00:00Z], completed_at: ~U[2025-05-28 10:00:00Z], output_path: "some output_path"}
  @update_attrs %{started_at: ~U[2025-05-29 10:00:00Z], completed_at: ~U[2025-05-29 10:00:00Z], output_path: "some updated output_path"}
  @invalid_attrs %{started_at: nil, completed_at: nil, output_path: nil}

  describe "index" do
    test "lists all scan_events", %{conn: conn} do
      conn = get(conn, ~p"/scan_events")
      assert html_response(conn, 200) =~ "Listing Scan events"
    end
  end

  describe "new scan_event" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/scan_events/new")
      assert html_response(conn, 200) =~ "New Scan event"
    end
  end

  describe "create scan_event" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/scan_events", scan_event: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/scan_events/#{id}"

      conn = get(conn, ~p"/scan_events/#{id}")
      assert html_response(conn, 200) =~ "Scan event #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/scan_events", scan_event: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Scan event"
    end
  end

  describe "edit scan_event" do
    setup [:create_scan_event]

    test "renders form for editing chosen scan_event", %{conn: conn, scan_event: scan_event} do
      conn = get(conn, ~p"/scan_events/#{scan_event}/edit")
      assert html_response(conn, 200) =~ "Edit Scan event"
    end
  end

  describe "update scan_event" do
    setup [:create_scan_event]

    test "redirects when data is valid", %{conn: conn, scan_event: scan_event} do
      conn = put(conn, ~p"/scan_events/#{scan_event}", scan_event: @update_attrs)
      assert redirected_to(conn) == ~p"/scan_events/#{scan_event}"

      conn = get(conn, ~p"/scan_events/#{scan_event}")
      assert html_response(conn, 200) =~ "some updated output_path"
    end

    test "renders errors when data is invalid", %{conn: conn, scan_event: scan_event} do
      conn = put(conn, ~p"/scan_events/#{scan_event}", scan_event: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Scan event"
    end
  end

  describe "delete scan_event" do
    setup [:create_scan_event]

    test "deletes chosen scan_event", %{conn: conn, scan_event: scan_event} do
      conn = delete(conn, ~p"/scan_events/#{scan_event}")
      assert redirected_to(conn) == ~p"/scan_events"

      assert_error_sent 404, fn ->
        get(conn, ~p"/scan_events/#{scan_event}")
      end
    end
  end

  defp create_scan_event(_) do
    scan_event = scan_event_fixture()
    %{scan_event: scan_event}
  end
end
