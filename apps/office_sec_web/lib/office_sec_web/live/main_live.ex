defmodule OfficeSecWeb.MainLive do
  @moduledoc """
  Main local page.
  """

  use OfficeSecWeb, :live_view

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Ds18b20.subscribe()
      Movement.movement_subscribe()
    end

    {:ok, assign(socket, temperature: "starting ...", last_update: "", last_movement: "-")}
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
    <div class="flex flex-row mx-auto py-5"></div>
    <div class="flex flex-row mx-auto">
      <div class="basis-1/3"></div>
      <div class="basis-1/6">Last movement</div>
      <div class="basis-1/5"><%= format_date_time(@last_movement) %></div>
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



  defp format_time(t) when is_binary(t), do: t
  defp format_time(datetime) do
    Calendar.strftime(datetime, "%H:%M:%S")
  end


  defp format_date_time(t) when is_binary(t), do: t
  defp format_date_time(datetime) do
    Calendar.strftime(datetime, "%H:%M:%S %d/%m/%Y")
  end

  def handle_info({:ds18b20_temperature, temperature}, socket) do
    {:noreply, assign(socket, temperature: temperature, last_update: DateTime.utc_now())}
  end

  def handle_info({:movement, :movement_detected}, socket) do
    {:noreply, assign(socket, last_movement: DateTime.utc_now())}
  end

  def handle_info(event, socket) do
    IO.inspect(event, label: :handle_info)
    {:noreply, socket}
  end
end
