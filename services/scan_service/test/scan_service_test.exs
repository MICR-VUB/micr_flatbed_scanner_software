defmodule ScanServiceTest do
  use ExUnit.Case
  doctest ScanService

  test "greets the world" do
    assert ScanService.hello() == :world
  end
end
