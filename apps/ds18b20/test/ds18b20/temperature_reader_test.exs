defmodule Ds18b20.TemperatureReaderTest do
  use ExUnit.Case
  alias Ds18b20.TemperatureReader

  import Ds18b20.DeviceFile

  setup :setup_one_wire_directory

  describe "find the device file" do
    test "error if the base directory is totally missing" do
      assert {:error, :enoent} == TemperatureReader.device_file("blahblah")
    end

    test "error if the base directory does not contain a matching 28-* dir", %{base_dir: base_dir} do
      assert {:error, :no_device} = TemperatureReader.device_file(base_dir)
    end

    test "error if the base directory contains multiple 28-* dirs", %{base_dir: base_dir} do
      create_device(base_dir, "abc")
      create_device(base_dir, "def")
      assert {:error, :multiple_devices} = TemperatureReader.device_file(base_dir)
    end

    test "return full device file path if found", %{base_dir: base_dir} do
      base_dir |> Path.join("28-abc") |> File.mkdir!()

      assert {:ok, Path.join([base_dir, "28-abc", "w1_slave"])} ==
               TemperatureReader.device_file(base_dir)
    end
  end

  describe "reading the device file" do
    setup :setup_device

    test "error if the file does not exist", %{device_file: device_file} do
      assert {:error, :enoent} == TemperatureReader.read_temperature(device_file)
    end

    test "error if the file is nonsense", %{device_file: device_file} do
      File.write!(device_file, "blah de blah")
      assert {:error, :bad_data} == TemperatureReader.read_temperature(device_file)
    end

    test "gets temperature from valid file", %{device_file: device_file} do
      write_valid_temperature(device_file, "14188")

      assert {:ok, %Decimal{} = temperature} = TemperatureReader.read_temperature(device_file)
      assert Decimal.equal?("14.188", temperature)
    end

    test "deals with below freezing temperatures", %{device_file: device_file} do
      write_valid_temperature(device_file, "-5562")
      assert {:ok, %Decimal{} = temperature} = TemperatureReader.read_temperature(device_file)
      assert Decimal.equal?("-5.562", temperature)
    end

    test "error if crc is not valid", %{device_file: device_file} do
      write_crc_fail_temperature(device_file)

      assert {:error, :crc_fail} = TemperatureReader.read_temperature(device_file)
    end
  end
end
