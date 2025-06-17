defmodule LssfHts.Devices.Device do
  use Ecto.Schema
  import Ecto.Changeset

  schema "devices" do
    field :connected, :boolean, default: false
    field :name, :string
    field :udev_name, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(device, attrs) do
    device
    |> cast(attrs, [:name, :udev_name, :connected])
    |> validate_required([:name, :udev_name, :connected])
  end
end
