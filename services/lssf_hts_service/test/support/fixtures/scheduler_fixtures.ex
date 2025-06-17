defmodule LssfHts.SchedulerFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `LssfHts.Scheduler` context.
  """

  @doc """
  Generate a job.
  """
  def job_fixture(attrs \\ %{}) do
    {:ok, job} =
      attrs
      |> Enum.into(%{
        enabled: true,
        name: "some name",
        schedule: ~U[2025-05-28 10:00:00Z]
      })
      |> LssfHts.Scheduler.create_job()

    job
  end

  @doc """
  Generate a scan_event.
  """
  def scan_event_fixture(attrs \\ %{}) do
    {:ok, scan_event} =
      attrs
      |> Enum.into(%{
        completed_at: ~U[2025-05-28 10:00:00Z],
        output_path: "some output_path",
        started_at: ~U[2025-05-28 10:00:00Z]
      })
      |> LssfHts.Scheduler.create_scan_event()

    scan_event
  end
end
