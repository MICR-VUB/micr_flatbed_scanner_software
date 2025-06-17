defmodule LssfHts.Scheduler.Job do
  use Ecto.Schema
  import Ecto.Changeset
  alias LssfHts.Scheduler.ScanEvent

  schema "jobs" do
    field :enabled, :boolean, default: false
    field :name, :string
    field :schedule, :utc_datetime
    field :run_interval_minutes, :integer
    field :run_until, :utc_datetime

    belongs_to :user, LssfHts.Accounts.User
    has_many :scan_events, ScanEvent, on_replace: :delete, on_delete: :delete_all

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(job, attrs) do
    job
    |> cast(attrs, [:name, :enabled, :schedule, :user_id, :run_interval_minutes, :run_until])
    |> cast_assoc(:scan_events, with: &ScanEvent.changeset/2, required: true)
    |> validate_required([:name, :enabled, :schedule, :run_interval_minutes])
    |> foreign_key_constraint(:user_id)

  end

  def toggle_enabled_changeset(job, enabled) do
    job
    |> cast(%{enabled: enabled}, [:enabled])
  end

end
