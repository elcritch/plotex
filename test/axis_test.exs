defmodule AxisTest do
  require Logger
  use ExUnit.Case
  alias Plotex.Axis

  # @default_css

  doctest Plotex

  test "data plots" do
    xdata = 1..4 |> Enum.map(& &1)
    ydata = xdata |> Enum.map(&:math.sin(&1 / 10.0))

    xlims = Plotex.Axis.Units.Numeric.range_from(xdata) |> Plotex.ViewRange.new(:horiz)
    xaxis = %Axis{limits: xlims}
    # Logger.warn("xlims: #{inspect xlims}")
    # Logger.warn("xaxis: #{inspect xaxis}")

    ylims = Plotex.Axis.Units.Numeric.range_from(ydata) |> Plotex.ViewRange.new(:vert)
    yaxis = %Axis{limits: ylims}
    # Logger.warn("ylims: #{inspect ylims}")
    # Logger.warn("yaxis: #{inspect yaxis}")

    {xrng, yrng} = Plotex.plot_data({xdata, ydata}, xaxis, yaxis)
    # Logger.warn("xrng: #{inspect xrng |> Enum.to_list()}")
    # Logger.warn("yrng: #{inspect yrng |> Enum.to_list()}")

    xs = [{1, 10.0}, {2, 36.66666666666667}, {3, 63.333333333333336}, {4, 90.0}]
    assert xs == Enum.to_list(xrng)

    ys = [
      {0.09983341664682815, 10.0},
      {0.19866933079506122, 37.30415995856187},
      {0.29552020666133955, 64.05993825604988},
      {0.3894183423086505, 90.0}
    ]

    assert ys == Enum.to_list(yrng)
  end

  test "plot limits" do
    xdata = 1..4 |> Enum.map(& &1)
    ydata = xdata |> Enum.map(&:math.sin(&1 / 10.0))

    # xlims = Plotex.Axis.Units.Numeric.range_from(xdata) |> Plotex.ViewRange.new()
    # xaxis = %Axis{limits: xlims}

    # _ylims = Plotex.Axis.Units.Numeric.range_from(ydata) |> Plotex.ViewRange.new()
    # yaxis = %Axis{limits: ylims}

    {xrng, yrng} = Plotex.limits([{xdata, ydata}])

    assert xrng == %Plotex.ViewRange{projection: :cartesian, start: 0.85, stop: 4.15}

    assert yrng == %Plotex.ViewRange{
             projection: :cartesian,
             start: 0.08535417036373703,
             stop: 0.40389758859174163
           }
  end
end
