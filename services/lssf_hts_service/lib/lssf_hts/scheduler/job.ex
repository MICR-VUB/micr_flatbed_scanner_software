defmodule LssfHts.Scheduler.Job do
  use Ecto.Schema
  import Ecto.Changeset

  schema "jobs" do
    field :enabled, :boolean, default: false
    field :name, :string
    field :schedule, :utc_datetime
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(job, attrs) do
    job
    |> cast(attrs, [:name, :enabled, :schedule])
    |> validate_required([:name, :enabled, :schedule])
  end
end
