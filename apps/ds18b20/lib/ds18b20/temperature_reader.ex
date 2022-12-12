defmodule Ds18b20.TemperatureReader do
  @moduledoc """
  Takes care of reading the temperature via OneWire
  """

  @temperature_regex ~r/crc=\w\w\s*(?<crc>\w+)$.*t=(?<t>-?\d+)$/sm

  @doc """
  Finds the device file
  """
  @spec device_file(base_dir :: String.t()) ::
          {:ok, String.t()} | {:error, :enoent | :no_device | :multiple_devices}
  def device_file(dir) do
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

  @spec read_temperature(String.t()) ::
          {:ok, Decimal.t()} | {:error, :crc_fail | :bad_data | :enoent}
  def read_temperature(device_file) do
    device_file
    |> File.read()
    |> parse_file()
  end

  defp parse_file({:ok, body}) do
    case Regex.named_captures(@temperature_regex, body) do
      %{"t" => t, "crc" => "YES"} ->
        {:ok, to_celsius(t)}

      %{"t" => _} ->
        {:error, :crc_fail}

      _ ->
        {:error, :bad_data}
    end
  end

  defp parse_file(err), do: err

  defp to_celsius(t) do
    t
    |> Decimal.new()
    |> Decimal.div(1000)
  end
end
