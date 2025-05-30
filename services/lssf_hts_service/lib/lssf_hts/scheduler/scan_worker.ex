defmodule LssfHts.Scheduler.ScanWorker do
  use Oban.Worker,
    queue: :default,
    max_attempts: 5,
    worker: __MODULE__

  alias LssfHts.Repo
  alias LssfHts.Scheduler.{Job, ScanEvent}

  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"job_id" => job_id}}) do
    Logger.info("Oban ScanWorker started for job_id=#{job_id}")

    job = Repo.get!(Job, job_id)
    |> Repo.preload(:scan_events)

    Logger.debug("Loaded job: #{inspect(job)}")

    current_time = DateTime.utc_now()

    if job.enabled and DateTime.compare(current_time, job.run_until) == :lt do
      Enum.each(job.scan_events, fn event ->
        IO.inspect(event, label: "event struct")
        result = execute_http_request(event)
        Logger.info("ScanEvent #{event.id} result: #{inspect(result)}")
      end)

      schedule_next_run(job)
    end

    :ok
  end

  defp execute_http_request(event) do
    payload = %{
      device: event.device,
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

    case Jason.encode(payload) do
      {:ok, json} ->
        HTTPoison.post(
          System.get_env("SCANNER_SERVER_URL"),
          json,
          headers,
          timeout: 60_000, # 1 min connect timeout
          recv_timeout: 1_000 * 60 * 16 # 16 minutes receive timeout
          )

      {:error, reason} ->
        Logger.error("Failed to encode payload for ScanEvent #{event.id}: #{inspect(reason)}")
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
