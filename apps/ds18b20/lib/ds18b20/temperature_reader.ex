defmodule Ds18b20.TemperatureReader do
  @moduledoc """
  Takes care of reading the temperature via OneWire
  """

  @devices_base "/sys/bus/w1/devices/"

  @doc """
  Finds the device file
  """
  @spec device_file() :: {:ok, String.t()} | {:error, :enoent | :no_device | :multiple_devices}
  def device_file(dir \\ @devices_base) do
    with {:ok, candidate_devices} <- File.ls(dir) do
      find_device(dir, candidate_devices)
    end
  end

  defp find_device(base_dir, candidate_devices) do
    candidate_devices
    |> Enum.filter(&String.starts_with?(&1, "28-"))
    |> case do
      [] -> {:error, :no_device}
      [dir] -> {:ok, Path.join([base_dir, dir, "w1_slave"])}
      _ -> {:error, :multiple_devices}
    end
  end
end
