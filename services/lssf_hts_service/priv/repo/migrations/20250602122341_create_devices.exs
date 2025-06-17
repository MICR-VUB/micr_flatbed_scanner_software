defmodule LssfHts.Repo.Migrations.CreateDevices do
  use Ecto.Migration

  def change do
    create table(:devices) do
      add :name, :string
      add :udev_name, :string
      add :connected, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
