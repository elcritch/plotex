defmodule Plotter.Config do
  alias Plotter.Axis
  require Logger

  @moduledoc """
  Documentation for Plotter Config.
  """
  defstruct xaxis: %Axis{},
            yaxis: %Axis{},
            title: "Plot"

  @type t :: %Plotter.Config{xaxis: map, yaxis: map, title: String.t() }
end
