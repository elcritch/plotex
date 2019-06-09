defmodule PlotEx.Config do
  alias PlotEx.Axis
  require Logger

  @moduledoc """
  Documentation for PlotEx Config.
  """
  defstruct xaxis: %Axis{},
            yaxis: %Axis{},
            title: "Plot"

  @type t :: %PlotEx.Config{xaxis: map, yaxis: map, title: String.t() }
end
