defmodule LssfHtsWeb.JobController do
  use LssfHtsWeb, :controller

  alias LssfHts.Scheduler
  alias LssfHts.Scheduler.Job

  def index(conn, _params) do
    jobs = Scheduler.list_jobs()
    render(conn, :index, jobs: jobs)
  end

  def new(conn, _params) do
    changeset = Scheduler.change_job(%Job{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"job" => job_params}) do
    case Scheduler.create_job(job_params) do
      {:ok, job} ->
        conn
        |> put_flash(:info, "Job created successfully.")
        |> redirect(to: ~p"/jobs/#{job}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    job = Scheduler.get_job!(id)
    render(conn, :show, job: job)
  end

  def edit(conn, %{"id" => id}) do
    job = Scheduler.get_job!(id)
    changeset = Scheduler.change_job(job)
    render(conn, :edit, job: job, changeset: changeset)
  end

  def update(conn, %{"id" => id, "job" => job_params}) do
    job = Scheduler.get_job!(id)

    case Scheduler.update_job(job, job_params) do
      {:ok, job} ->
        conn
        |> put_flash(:info, "Job updated successfully.")
        |> redirect(to: ~p"/jobs/#{job}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, job: job, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    job = Scheduler.get_job!(id)
    {:ok, _job} = Scheduler.delete_job(job)

    conn
    |> put_flash(:info, "Job deleted successfully.")
    |> redirect(to: ~p"/jobs")
  end
end
