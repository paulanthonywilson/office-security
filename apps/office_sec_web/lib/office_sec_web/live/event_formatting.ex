defmodule OfficeSecWeb.EventFormatting do
  @moduledoc """
  Formats event output for the live view
  """

  @doc """
  Format the temperature output as received from Ds18b20
  events

  Error events show the reason
  eg
  iex> format_temperature({:error, :no_device})
  ":no_device"

  Strings are shown as-is
  iex> format_temperature("discount tents")
  "discount tents"

  Ok tuples with Decimal, show to two decimal places
  iex> format_temperature({:ok, Decimal.new("1.239")})
  "1.24"

  """
  def format_temperature({:error, reason}) do
    inspect(reason)
  end

  def format_temperature(message) when is_binary(message) do
    message
  end

  def format_temperature({:ok, %Decimal{} = temp}) do
    temp
    |> Decimal.round(2)
    |> Decimal.to_string()
  end

  @doc """
  Strings as strings (for an initial reading) and DateTimes
  to just the time part in hour:minute:second format
  eg
  iex> format_time("winter has been")
  "winter has been"

  iex> format_time(~U[2029-11-01 01:02:03Z])
  "01:02:03"
  """
  @spec format_time(String.t() | DateTime.t()) :: String.t()
  def format_time(t) when is_binary(t), do: t

  def format_time(datetime) do
    Calendar.strftime(datetime, "%H:%M:%S")
  end

  @doc """
  Formats datetimes to a time and date
  eg

  Strings (for when no event received yet), as-iss

  iex> format_date_time("But oh! that dark romantic chasm")
  "But oh! that dark romantic chasm"

  Shows time then date if provided
  iex> format_date_time(~U[2011-10-09 03:04:05Z])
  "03:04:05 on 2011-10-09 (UTC)"
  """
  def format_date_time(text) when is_binary(text) do
    text
  end

  def format_date_time(datetime) do
    Calendar.strftime(datetime, "%H:%M:%S on %Y-%m-%d (UTC)")
  end
end
