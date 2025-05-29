defmodule LssfHts.Repo.Migrations.CreateScanEvents do
  use Ecto.Migration

  def change do
    create table(:scan_events) do
      add :started_at, :utc_datetime
      add :completed_at, :utc_datetime
      add :output_path, :string
      add :job_id, references(:jobs, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:scan_events, [:job_id])
  end
end
