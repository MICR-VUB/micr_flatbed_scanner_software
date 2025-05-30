defmodule LssfHts.Repo.Migrations.AddScanEventAndJobFields do
  use Ecto.Migration

  def change do
    alter table(:scan_events) do
      add :step_name, :string
      add :device, :string
      add :output, :string
      add :resolution, :integer, default: 300
      add :mode, :string, default: "Color"
      add :t, :integer, default: 0
      add :l, :integer, default: 0
      add :x, :integer, default: 210
      add :y, :integer, default: 297
    end

    alter table(:jobs) do
      add :job_id, references(:jobs, on_delete: :delete_all)
      add :run_interval_minutes, :integer
      add :run_until, :utc_datetime
    end
  end
end
