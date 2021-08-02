defmodule Plotex.Config do
  alias Plotex.Axis
  require Logger

  @moduledoc """
  Documentation for Plotex Config.
  """
  defstruct xaxis: %Axis{},
            yaxis: %Axis{},
            title: "Plot"

  @type t :: %Plotex.Config{xaxis: map, yaxis: map, title: String.t()}
end
