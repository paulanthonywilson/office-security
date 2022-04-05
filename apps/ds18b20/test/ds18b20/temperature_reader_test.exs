defmodule Ds18b20.TemperatureReaderTest do
  use ExUnit.Case
  alias Ds18b20.TemperatureReader

  setup do
    base_dir = Path.join(System.tmp_dir!(), "tmp#{:rand.uniform()}")

    File.mkdir_p!(base_dir)
    base_dir |> Path.join("bystander-file") |> File.touch!()

    on_exit(fn ->
      File.rm_rf!(base_dir)
    end)

    {:ok, base_dir: base_dir}
  end

  describe "find the device file" do
    test "error if the base directory is totally missing" do
      assert {:error, :enoent} == TemperatureReader.device_file("blahblah")
    end

    test "error if the base directory does not contain a matching 28-* dir", %{base_dir: base_dir} do
      assert {:error, :no_device} = TemperatureReader.device_file(base_dir)
    end

    test "error if the base directory contains multiple 28-* dirs", %{base_dir: base_dir} do
      base_dir |> Path.join("28-abc") |> File.mkdir!()
      base_dir |> Path.join("28-def") |> File.mkdir!()
      assert {:error, :multiple_devices} = TemperatureReader.device_file(base_dir)
    end

    test "return full device file path if found", %{base_dir: base_dir} do
      base_dir |> Path.join("28-abc") |> File.mkdir!()

      assert {:ok, Path.join([base_dir, "28-abc", "w1_slave"])} ==
               TemperatureReader.device_file(base_dir)
    end
  end
end
