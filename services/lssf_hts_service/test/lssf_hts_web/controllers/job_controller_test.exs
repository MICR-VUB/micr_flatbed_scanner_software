defmodule LssfHtsWeb.JobControllerTest do
  use LssfHtsWeb.ConnCase

  import LssfHts.SchedulerFixtures

  @create_attrs %{enabled: true, name: "some name", schedule: ~U[2025-05-28 10:00:00Z]}
  @update_attrs %{enabled: false, name: "some updated name", schedule: ~U[2025-05-29 10:00:00Z]}
  @invalid_attrs %{enabled: nil, name: nil, schedule: nil}

  describe "index" do
    test "lists all jobs", %{conn: conn} do
      conn = get(conn, ~p"/jobs")
      assert html_response(conn, 200) =~ "Listing Jobs"
    end
  end

  describe "new job" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/jobs/new")
      assert html_response(conn, 200) =~ "New Job"
    end
  end

  describe "create job" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/jobs", job: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/jobs/#{id}"

      conn = get(conn, ~p"/jobs/#{id}")
      assert html_response(conn, 200) =~ "Job #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/jobs", job: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Job"
    end
  end

  describe "edit job" do
    setup [:create_job]

    test "renders form for editing chosen job", %{conn: conn, job: job} do
      conn = get(conn, ~p"/jobs/#{job}/edit")
      assert html_response(conn, 200) =~ "Edit Job"
    end
  end

  describe "update job" do
    setup [:create_job]

    test "redirects when data is valid", %{conn: conn, job: job} do
      conn = put(conn, ~p"/jobs/#{job}", job: @update_attrs)
      assert redirected_to(conn) == ~p"/jobs/#{job}"

      conn = get(conn, ~p"/jobs/#{job}")
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, job: job} do
      conn = put(conn, ~p"/jobs/#{job}", job: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Job"
    end
  end

  describe "delete job" do
    setup [:create_job]

    test "deletes chosen job", %{conn: conn, job: job} do
      conn = delete(conn, ~p"/jobs/#{job}")
      assert redirected_to(conn) == ~p"/jobs"

      assert_error_sent 404, fn ->
        get(conn, ~p"/jobs/#{job}")
      end
    end
  end

  defp create_job(_) do
    job = job_fixture()
    %{job: job}
  end
end
