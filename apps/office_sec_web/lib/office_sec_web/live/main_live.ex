defmodule OfficeSecWeb.MainLive do
  @moduledoc """
  Main local page.
  """

  use OfficeSecWeb, :live_view

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Ds18b20.subscribe()
    end

    {:ok, assign(socket, temperature: "starting ...", last_update: "")}
  end

  def render(assigns) do
    ~H"""
    <div class="flex flex-row mx-auto">
      <div class="basis-1/3"></div>
      <div class="basis-1/6">Current temperature:</div>
      <div class="basis-1/6"><%= format_temperature(@temperature) %> ℃   </div>
    </div>
    <div class="flex flex-row mx-auto">
      <div class="basis-1/2"></div>
      <div class="basis-1/5"><%= format_time(@last_update) %></div>
    </div>

    """
  end

  defp format_temperature({:ok, %Decimal{} = temp}) do
    temp
    |> Decimal.round(1)
    |> Decimal.to_string()
  end

  defp format_temperature({:error, reason}) do
    inspect(reason)
  end

  defp format_temperature(message) when is_binary(message) do
    message
  end

  defp format_time(""), do: ""

  defp format_time(datetime) do
    Calendar.strftime(datetime, "%H:%M:%S")
  end

  def handle_info({:ds18b20_temperature, temperature}, socket) do
    {:noreply, assign(socket, temperature: temperature, last_update: DateTime.utc_now())}
  end

  def handle_info(event, socket) do
    IO.inspect(event, label: :handle_info)
    {:noreply, socket}
  end
end
