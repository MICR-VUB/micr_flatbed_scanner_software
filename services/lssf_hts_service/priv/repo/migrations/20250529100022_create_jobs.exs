defmodule LssfHts.Repo.Migrations.CreateJobs do
  use Ecto.Migration

  def change do
    create table(:jobs) do
      add :name, :string
      add :enabled, :boolean, default: false, null: false
      add :schedule, :utc_datetime
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:jobs, [:user_id])
  end
end
