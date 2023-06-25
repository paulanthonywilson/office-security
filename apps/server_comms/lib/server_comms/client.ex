defmodule ServerComms.Client do
  @moduledoc """
  Testing seam for the Fedecks Client
  """

  @implementation if Mix.env() == :test && Mix.target() != :elixir_ls,
                    do: MockFedecksClient,
                    else: ServerComms.RealClient

  defmacro __using__(_) do
    quote location: :keep do
      alias unquote(@implementation), as: Client
    end
  end

  def child_spec(opts), do: ServerComms.RealClient.child_spec(opts)
end
