defmodule Plotter.Config do
  alias Plotter.Axis
  require Logger

  @moduledoc """
  Documentation for Plotter Config.
  """
  defstruct xaxis: %Axis{},
            yaxis: %Axis{}

  @type t :: %Plotter.Config{xaxis: map, yaxis: map}
end
