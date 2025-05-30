defmodule LssfHts.Scheduler do
  @moduledoc """
  The Scheduler context.
  """

  import Ecto.Query, warn: false
  alias LssfHts.Repo

  alias LssfHts.Scheduler.Job

  @doc """
  Returns the list of jobs.

  ## Examples

      iex> list_jobs()
      [%Job{}, ...]

  """
  def list_jobs do
    Repo.all(Job)
  end

  @doc """
  Gets a single job.

  Raises `Ecto.NoResultsError` if the Job does not exist.

  ## Examples

      iex> get_job!(123)
      %Job{}

      iex> get_job!(456)
      ** (Ecto.NoResultsError)

  """
  def get_job!(id), do: Repo.get!(Job, id)

  @doc """
  Creates a job.

  ## Examples

      iex> create_job(%{field: value})
      {:ok, %Job{}}

      iex> create_job(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_job(attrs \\ %{}) do
    %Job{}
    |> Job.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a job.

  ## Examples

      iex> update_job(job, %{field: new_value})
      {:ok, %Job{}}

      iex> update_job(job, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_job(%Job{} = job, attrs) do
    job
    |> Job.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a job.

  ## Examples

      iex> delete_job(job)
      {:ok, %Job{}}

      iex> delete_job(job)
      {:error, %Ecto.Changeset{}}

  """
  def delete_job(%Job{} = job) do
    Repo.delete(job)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking job changes.

  ## Examples

      iex> change_job(job)
      %Ecto.Changeset{data: %Job{}}

  """
  def change_job(%Job{} = job, attrs \\ %{}) do
    Job.changeset(job, attrs)
  end

  def toggle_job_enabled(%Job{} = job, enabled) do
    job
    |> Job.toggle_enabled_changeset(enabled)
    |> Repo.update()
  end

  alias LssfHts.Scheduler.ScanEvent

  @doc """
  Returns the list of scan_events.

  ## Examples

      iex> list_scan_events()
      [%ScanEvent{}, ...]

  """
  def list_scan_events do
    Repo.all(ScanEvent)
  end

  @doc """
  Gets a single scan_event.

  Raises `Ecto.NoResultsError` if the Scan event does not exist.

  ## Examples

      iex> get_scan_event!(123)
      %ScanEvent{}

      iex> get_scan_event!(456)
      ** (Ecto.NoResultsError)

  """
  def get_scan_event!(id), do: Repo.get!(ScanEvent, id)

  @doc """
  Creates a scan_event.

  ## Examples

      iex> create_scan_event(%{field: value})
      {:ok, %ScanEvent{}}

      iex> create_scan_event(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_scan_event(attrs \\ %{}) do
    %ScanEvent{}
    |> ScanEvent.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a scan_event.

  ## Examples

      iex> update_scan_event(scan_event, %{field: new_value})
      {:ok, %ScanEvent{}}

      iex> update_scan_event(scan_event, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_scan_event(%ScanEvent{} = scan_event, attrs) do
    scan_event
    |> ScanEvent.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a scan_event.

  ## Examples

      iex> delete_scan_event(scan_event)
      {:ok, %ScanEvent{}}

      iex> delete_scan_event(scan_event)
      {:error, %Ecto.Changeset{}}

  """
  def delete_scan_event(%ScanEvent{} = scan_event) do
    Repo.delete(scan_event)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking scan_event changes.

  ## Examples

      iex> change_scan_event(scan_event)
      %Ecto.Changeset{data: %ScanEvent{}}

  """
  def change_scan_event(%ScanEvent{} = scan_event, attrs \\ %{}) do
    ScanEvent.changeset(scan_event, attrs)
  end

  alias LssfHts.Scheduler.ScanWorker
  def start_job(%Job{} = job) do
    IO.inspect(job, label: "job info")
    %{job_id: job.id}
    |> ScanWorker.new(schedule_in: _seconds = 5)
    |> Oban.insert()
  end

end
