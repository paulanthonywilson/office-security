defmodule Ds18b20.DeviceFile do
  @moduledoc """
  Test support for a real file masquerinding as the "device"
  """

  def setup_one_wire_directory(_ctx) do
    base_dir = Path.join(System.tmp_dir!(), "tmp#{:rand.uniform()}")

    File.mkdir_p!(base_dir)
    base_dir |> Path.join("bystander-file") |> File.touch!()

    ExUnit.Callbacks.on_exit(fn ->
      File.rm_rf!(base_dir)
    end)

    {:ok, base_dir: base_dir}
  end

  def setup_device(%{base_dir: base_dir}) do
    {:ok, device_file: create_device(base_dir, "abc")}
  end

  def create_device(base_dir, suffix) do
    dir = Path.join(base_dir, "28-#{suffix}")
    File.mkdir_p!(dir)

    Path.join(dir, "w1_slave")
  end

  def write_valid_temperature(device_file, temperature_reading) do
    write_temperature(device_file, temperature_reading, "YES")
  end

  def write_crc_fail_temperature(device_file) do
    write_temperature(device_file, "12345", "NO")
  end

  defp write_temperature(device_file, temperature_reading, crc) do
    content = """
    e3 00 4b 46 7f ff 0c 10 7e : crc=7e #{crc}
    e3 00 4b 46 7f ff 0c 10 7e t=#{temperature_reading}
    """

    File.write!(device_file, content)
  end
end
