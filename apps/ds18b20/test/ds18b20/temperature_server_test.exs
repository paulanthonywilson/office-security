defmodule Ds18b20.TemperatureServerTest do
  use ExUnit.Case
  alias Ds18b20.TemperatureServer

  import Ds18b20.DeviceFile

  setup :setup_one_wire_directory

  describe "startup errors" do
    test "returns bad one wire error" do
      assert {:ok, pid} = TemperatureServer.start_link(device_base: "blah", use_name?: false)
      assert {:error, :bad_one_wire} == TemperatureServer.read(pid)
    end

    test "no device found", ctx do
      pid = start_server(ctx)
      assert {:error, :no_device} == TemperatureServer.read(pid)
    end

    test "multiple devices found", %{base_dir: base_dir} = ctx do
      base_dir |> Path.join("28-a") |> File.mkdir!()
      base_dir |> Path.join("28-b") |> File.mkdir!()
      pid = start_server(ctx)
      assert {:error, :multiple_devices} == TemperatureServer.read(pid)
    end
  end

  describe "with one wire" do
    setup :setup_device

    test "reads initially", %{device_file: device_file} = ctx do
      write_valid_temperature(device_file, "13000")

      pid = start_server(ctx)
      assert {:ok, value} = TemperatureServer.read(pid)
      assert Decimal.equal?("13", value)
    end

    test "reads again", %{device_file: device_file} = ctx do
      pid = start_server(ctx)
      write_valid_temperature(device_file, "11500")
      send(pid, :read_temperature)
      assert {:ok, value} = TemperatureServer.read(pid)
      assert Decimal.equal?("11.5", value)
    end
  end

  defp start_server(%{base_dir: base_dir}) do
    {:ok, pid} = TemperatureServer.start_link(device_base: base_dir, use_name?: false)
    pid
  end
end
