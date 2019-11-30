defmodule AxisTest do
  require Logger
  use ExUnit.Case
  alias Plotex.Axis

  # @default_css

  doctest Plotex

  test "plot limits" do
    xdata = [1.0, 2.0, 3.0, 4.0]
    ydata = [0.10, 0.19, 0.29, 0.44]

    {xrng, yrng} = Plotex.limits([{xdata, ydata}])

    assert xrng == %Plotex.ViewRange{projection: :cartesian, start: 0.85, stop: 4.15}
    assert yrng == %Plotex.ViewRange{projection: :cartesian, start: 0.083, stop: 0.457}
  end


end
