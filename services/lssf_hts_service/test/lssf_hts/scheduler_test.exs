defmodule LssfHts.SchedulerTest do
  use LssfHts.DataCase

  alias LssfHts.Scheduler

  describe "jobs" do
    alias LssfHts.Scheduler.Job

    import LssfHts.SchedulerFixtures

    @invalid_attrs %{enabled: nil, name: nil, schedule: nil}

    test "list_jobs/0 returns all jobs" do
      job = job_fixture()
      assert Scheduler.list_jobs() == [job]
    end

    test "get_job!/1 returns the job with given id" do
      job = job_fixture()
      assert Scheduler.get_job!(job.id) == job
    end

    test "create_job/1 with valid data creates a job" do
      valid_attrs = %{enabled: true, name: "some name", schedule: ~U[2025-05-28 10:00:00Z]}

      assert {:ok, %Job{} = job} = Scheduler.create_job(valid_attrs)
      assert job.enabled == true
      assert job.name == "some name"
      assert job.schedule == ~U[2025-05-28 10:00:00Z]
    end

    test "create_job/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Scheduler.create_job(@invalid_attrs)
    end

    test "update_job/2 with valid data updates the job" do
      job = job_fixture()
      update_attrs = %{enabled: false, name: "some updated name", schedule: ~U[2025-05-29 10:00:00Z]}

      assert {:ok, %Job{} = job} = Scheduler.update_job(job, update_attrs)
      assert job.enabled == false
      assert job.name == "some updated name"
      assert job.schedule == ~U[2025-05-29 10:00:00Z]
    end

    test "update_job/2 with invalid data returns error changeset" do
      job = job_fixture()
      assert {:error, %Ecto.Changeset{}} = Scheduler.update_job(job, @invalid_attrs)
      assert job == Scheduler.get_job!(job.id)
    end

    test "delete_job/1 deletes the job" do
      job = job_fixture()
      assert {:ok, %Job{}} = Scheduler.delete_job(job)
      assert_raise Ecto.NoResultsError, fn -> Scheduler.get_job!(job.id) end
    end

    test "change_job/1 returns a job changeset" do
      job = job_fixture()
      assert %Ecto.Changeset{} = Scheduler.change_job(job)
    end
  end

  describe "scan_events" do
    alias LssfHts.Scheduler.ScanEvent

    import LssfHts.SchedulerFixtures

    @invalid_attrs %{started_at: nil, completed_at: nil, output_path: nil}

    test "list_scan_events/0 returns all scan_events" do
      scan_event = scan_event_fixture()
      assert Scheduler.list_scan_events() == [scan_event]
    end

    test "get_scan_event!/1 returns the scan_event with given id" do
      scan_event = scan_event_fixture()
      assert Scheduler.get_scan_event!(scan_event.id) == scan_event
    end

    test "create_scan_event/1 with valid data creates a scan_event" do
      valid_attrs = %{started_at: ~U[2025-05-28 10:00:00Z], completed_at: ~U[2025-05-28 10:00:00Z], output_path: "some output_path"}

      assert {:ok, %ScanEvent{} = scan_event} = Scheduler.create_scan_event(valid_attrs)
      assert scan_event.started_at == ~U[2025-05-28 10:00:00Z]
      assert scan_event.completed_at == ~U[2025-05-28 10:00:00Z]
      assert scan_event.output_path == "some output_path"
    end

    test "create_scan_event/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Scheduler.create_scan_event(@invalid_attrs)
    end

    test "update_scan_event/2 with valid data updates the scan_event" do
      scan_event = scan_event_fixture()
      update_attrs = %{started_at: ~U[2025-05-29 10:00:00Z], completed_at: ~U[2025-05-29 10:00:00Z], output_path: "some updated output_path"}

      assert {:ok, %ScanEvent{} = scan_event} = Scheduler.update_scan_event(scan_event, update_attrs)
      assert scan_event.started_at == ~U[2025-05-29 10:00:00Z]
      assert scan_event.completed_at == ~U[2025-05-29 10:00:00Z]
      assert scan_event.output_path == "some updated output_path"
    end

    test "update_scan_event/2 with invalid data returns error changeset" do
      scan_event = scan_event_fixture()
      assert {:error, %Ecto.Changeset{}} = Scheduler.update_scan_event(scan_event, @invalid_attrs)
      assert scan_event == Scheduler.get_scan_event!(scan_event.id)
    end

    test "delete_scan_event/1 deletes the scan_event" do
      scan_event = scan_event_fixture()
      assert {:ok, %ScanEvent{}} = Scheduler.delete_scan_event(scan_event)
      assert_raise Ecto.NoResultsError, fn -> Scheduler.get_scan_event!(scan_event.id) end
    end

    test "change_scan_event/1 returns a scan_event changeset" do
      scan_event = scan_event_fixture()
      assert %Ecto.Changeset{} = Scheduler.change_scan_event(scan_event)
    end
  end
end
