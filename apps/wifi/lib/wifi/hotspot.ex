defmodule Wifi.Hotspot do
  @moduledoc """
  Runs the Wifi wizard, turning the board into a hot spot
  for the duration.
  """

  def start do
    if function_exported?(VintageNetWizard, :run_wizard, 0) do
      apply(VintageNetWizard, :run_wizard, [])
    end
  end

  def start_if_unconfigured do
    if function_exported?(VintageNetWizard, :run_if_unconfigured, 0) do
      apply(VintageNetWizard, :run_if_unconfigured, [])
    end
  end
end
