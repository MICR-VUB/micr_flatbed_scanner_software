defmodule LssfHts.Repo.Migrations.ReplaceDeviceWithDeviceIdInScanEvents do
  use Ecto.Migration

  def change do
    alter table(:scan_events) do
      remove :device
      add :device_id, references(:devices, on_delete: :nothing)
    end

    create index(:scan_events, [:device_id])
  end
end
