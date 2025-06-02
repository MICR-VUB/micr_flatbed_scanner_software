defmodule LssfHts.Scheduler.ScanWorker do
  use Oban.Worker,
    queue: :default,
    max_attempts: 5,
    worker: __MODULE__

  alias LssfHts.Repo
  alias LssfHts.Scheduler.Job

  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"job_id" => job_id}}) do
    Logger.info("Oban ScanWorker started for job_id=#{job_id}")

    job = Repo.get!(Job, job_id)
    |> Repo.preload(scan_events: :device)

    Logger.debug("Loaded job: #{inspect(job)}")

    current_time = DateTime.utc_now()

    if job.enabled and DateTime.compare(current_time, job.run_until) == :lt do
      Enum.each(job.scan_events, fn event ->
        case execute_http_request(event) do
          {:ok, result} ->
            Logger.info("Job execution request successful with code #{result.status_code}")
            schedule_next_run(job)

          {:error, reason} ->
            Logger.error("ScanEvent #{event.id} failed with: #{inspect(reason)}. Disabling job #{job.id}")
            disable_job(job)
        end

      end)


    else
      Logger.error("Job end time: #{job.run_until} is before current time: #{current_time}. Job is expired")
      disable_job(job)
    end

    :ok
  end

  defp disable_job(job) do
    job
    |> Ecto.Changeset.change(enabled: false)
    |> Repo.update()

    {:error, "Job #{job.id} disabled due to failure or expiration"}
  end

  defp execute_http_request(event) do
    payload = %{
      device: event.device.udev_name,
      output: event.output,
      resolution: event.resolution,
      mode: event.mode,
      t: event.t,
      l: event.l,
      x: event.x,
      y: event.y
    }

    headers = [
      {"Content-Type", "application/json"}
    ]

    server_address = "localhost:4001/scan"

    case Jason.encode(payload) do
      {:ok, json} ->
        Logger.info("Request to server: #{server_address} sent")
        case HTTPoison.post(
          server_address,
          json,
          headers,
          timeout: 60_000, # 1 min connect timeout
          recv_timeout: 1_000 * 60 * 16 # 16 minutes receive timeout
        ) do
          {:ok, %HTTPoison.Response{status_code: code, body: body}} when code in 200..299 ->
            Logger.info("Scan request succeeded with status #{code}")
            {:ok, body}
          {:ok, %HTTPoison.Response{status_code: code, body: body}} ->
            Logger.error("Scan request failed with status #{code}: #{inspect(body)}")
            {:error, {:http_error, code, body}}
          {:error, %HTTPoison.Error{reason: reason}} ->
            Logger.error("Scan request errored: #{inspect(reason)}")
            {:error, {:request_failed, reason}}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp schedule_next_run(%Job{} = job) do
    next_run = DateTime.add(DateTime.utc_now(), job.run_interval_minutes * 60, :second)
    if job.enabled and DateTime.compare(next_run, job.run_until) == :lt do
      Logger.info("Scheduling next run for #{next_run}")
      %{job_id: job.id}
      |> LssfHts.Scheduler.ScanWorker.new(schedule_in: job.run_interval_minutes * 60)
      |> Oban.insert()
    else
      :ok
    end
  end
end
