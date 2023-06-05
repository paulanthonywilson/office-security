defmodule ServerComms.ReportSensorsTest do
  use ExUnit.Case
  alias ServerComms.ReportSensors
  import Mox

  setup :verify_on_exit!

  describe "reports from sensors" do
    test "temperature" do
      expect(MockFedecksClient, :send, fn %{"temperature" => temperature} ->
        assert Decimal.eq?("12.22", temperature)
      end)

      assert {:noreply, _} =
               ReportSensors.handle_info({:ds18b20_temperature, {:ok, Decimal.new("12.22")}}, %{})
    end

    Enum.each(
      %{
        movement_detected: "movement",
        movement_stopped: "movement_stop",
        occupied: "occupied",
        unoccupied: "unoccupied"
      },
      fn {event_key, message_key} ->
        test to_string(event_key) do
          expect(MockFedecksClient, :send, fn message ->
            assert %{unquote(message_key) => ~U[2023-05-28 17:33:11Z]} = message
          end)

          assert {:noreply, _} =
                   ReportSensors.handle_info(
                     {Movement.Sensor, unquote(event_key), ~U[2023-05-28 17:33:11Z]},
                     %{}
                   )
        end
      end
    )
  end
end
