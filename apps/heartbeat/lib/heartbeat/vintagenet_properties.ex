defmodule Heartbeat.VintageNetProperties do
  @moduledoc """
  Indirection layer for `VintageNet` so we can test etc... off
  the hardware. Usage

  ```
  use Heartbeat.VintageNetProperties
  ```

  The appropriate module will be aliased as `VintageNetProperties`
  """

  @doc """
  Indirection for `VintageNet.get/1` (no default)
  """
  @callback get([String.t()]) :: any()
  @callback kick :: :ok

  @mix_target Mix.target()

  def mix_target, do: @mix_target

  defmacro __using__(_) do
    mod =
      if :host == apply(__MODULE__, :mix_target, []) do
        Heartbeat.FakeVintageNetProperties
      else
        Heartbeat.RealVintageNetProperties
      end

    quote do
      alias unquote(mod), as: VintageNetProperties
    end
  end
end
