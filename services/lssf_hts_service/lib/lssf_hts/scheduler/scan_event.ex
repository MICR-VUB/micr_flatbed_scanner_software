defmodule LssfHts.Scheduler.ScanEvent do
  use Ecto.Schema
  import Ecto.Changeset

  schema "scan_events" do
    field :started_at, :utc_datetime
    field :completed_at, :utc_datetime
    field :output_path, :string
    field :job_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(scan_event, attrs) do
    scan_event
    |> cast(attrs, [:started_at, :completed_at, :output_path])
    |> validate_required([:started_at, :completed_at, :output_path])
  end
end
