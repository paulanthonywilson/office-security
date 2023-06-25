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

  describe "receiving occupation status from server" do
    setup do
      Movement.subscribe()
      :ok
    end

    test "when when server is unknown, client information is re-set" do
      Movement.set_occupied(false, ~U[2023-07-01 10:00:00Z])

      assert {:noreply, _} =
               ReportSensors.handle_info(
                 {MockFedecksClient, {:message, {:occupation_status, :unknown}}},
                 %{}
               )

      assert {false, ~U[2023-07-01 10:00:00Z]} == Movement.occupation()
      assert_receive {Movement.Sensor, :unoccupied, ~U[2023-07-01 10:00:00Z]}
    end

    test "when server is occupied then client information is overwriten with sever information" do
      Movement.set_occupied(false, ~U[2023-07-01 10:00:00Z])

      assert {:noreply, _} =
               ReportSensors.handle_info(
                 {MockFedecksClient,
                  {:message, {:occupation_status, {:occupied, ~U[2023-07-01 09:59:59Z]}}}},
                 %{}
               )

      assert {true, ~U[2023-07-01 09:59:59Z]} == Movement.occupation()
      assert_receive {Movement.Sensor, :occupied, ~U[2023-07-01 09:59:59Z]}

      assert {:noreply, _} =
               ReportSensors.handle_info(
                 {MockFedecksClient,
                  {:message, {:occupation_status, {:occupied, ~U[2023-07-01 09:58:59Z]}}}},
                 %{}
               )

      assert {true, ~U[2023-07-01 09:58:59Z]} == Movement.occupation()
      assert_receive {Movement.Sensor, :occupied, ~U[2023-07-01 09:58:59Z]}
    end

    test "when client is occupied but the server is not then the client status is re-set" do
      Movement.set_occupied(true, ~U[2023-07-01 10:00:00Z])
      assert_receive {Movement.Sensor, :occupied, ~U[2023-07-01 10:00:00Z]}

      assert {:noreply, _} =
               ReportSensors.handle_info(
                 {MockFedecksClient,
                  {:message, {:occupation_status, {:unoccupied, ~U[2023-07-01 09:59:59Z]}}}},
                 %{}
               )

      assert {true, ~U[2023-07-01 10:00:00Z]} == Movement.occupation()
      assert_receive {Movement.Sensor, :occupied, ~U[2023-07-01 10:00:00Z]}
    end

    test "when both unoccupied  sets occupation status to unoccupied with the server timestamp " do
      Movement.set_occupied(false, ~U[2023-07-01 10:00:00Z])

      assert {:noreply, _} =
               ReportSensors.handle_info(
                 {MockFedecksClient,
                  {:message, {:occupation_status, {:unoccupied, ~U[2023-07-01 09:59:59Z]}}}},
                 %{}
               )

      assert {false, ~U[2023-07-01 09:59:59Z]} == Movement.occupation()
      assert_receive {Movement.Sensor, :unoccupied, ~U[2023-07-01 09:59:59Z]}
    end
  end
end
