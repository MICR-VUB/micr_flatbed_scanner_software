defmodule LssfHts.DevicesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `LssfHts.Devices` context.
  """

  @doc """
  Generate a device.
  """
  def device_fixture(attrs \\ %{}) do
    {:ok, device} =
      attrs
      |> Enum.into(%{
        connected: true,
        name: "some name",
        udev_name: "some udev_name"
      })
      |> LssfHts.Devices.create_device()

    device
  end
end
