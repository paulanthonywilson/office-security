defmodule Ds18b20.TemperatureServerTest do
  use ExUnit.Case
  alias Ds18b20.TemperatureServer

  import Ds18b20.DeviceFile

  setup :setup_one_wire_directory

  describe "startup errors" do
    test "returns bad one wire error" do
      assert {:ok, pid} = TemperatureServer.start_link(device_base: "blah", name: generate_name())
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

  describe "subscribe for updates" do
    setup :setup_device

    setup %{device_file: device_file} = ctx do
      write_valid_temperature(device_file, "12345")
      pid = start_server(ctx)
      TemperatureServer.read(pid)
      {:ok, pid: pid}
    end

    test "gets notification with latest temperature on subscription", %{pid: pid} do
      assert :ok = TemperatureServer.subscribe(pid)
      assert_receive {:ds18b20_temperature, {:ok, temp}}
      assert Decimal.equal?("12.345", temp)
    end

    test "gets updates on temperature update", %{pid: pid, device_file: device_file} do
      :ok = TemperatureServer.subscribe(pid)
      assert_receive {:ds18b20_temperature, _}

      write_valid_temperature(device_file, "13321")
      send(pid, :read_temperature)

      assert {:ok, value} = TemperatureServer.read(pid)
      assert Decimal.equal?("13.321", value)
      assert_receive {:ds18b20_temperature, {:ok, temp}}
      assert Decimal.equal?("13.321", temp)
    end
  end

  defp generate_name do
    self() |> inspect() |> String.to_atom()
  end

  defp start_server(%{base_dir: base_dir}) do
    {:ok, pid} = TemperatureServer.start_link(device_base: base_dir, name: generate_name())
    pid
  end
end
