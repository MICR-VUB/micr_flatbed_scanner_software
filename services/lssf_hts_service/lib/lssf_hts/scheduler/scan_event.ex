defmodule LssfHts.Scheduler.ScanEvent do
  use Ecto.Schema
  import Ecto.Changeset

  schema "scan_events" do
    field :step_name, :string
    field :output, :string
    field :resolution, :integer, default: 300
    field :mode, :string, default: "Color"
    field :t, :integer, default: 0
    field :l, :integer, default: 0
    field :x, :integer, default: 210
    field :y, :integer, default: 297

    belongs_to :device, LssfHts.Devices.Device
    belongs_to :job, LssfHts.Scheduler.Job

  timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(scan_event, attrs) do
    scan_event
    |> cast(attrs, [:step_name, :device_id, :output, :resolution, :mode, :t, :l, :x, :y])
    |> validate_required([:step_name, :device_id, :output])
  end
end
