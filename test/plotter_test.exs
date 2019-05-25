defmodule PlotterTest do
  require Logger
  use ExUnit.Case
  alias Plotter.Axis
  alias Plotter.ViewRange

  doctest Plotter

  test "data plots" do

    xdata = 1..4 |> Enum.map(& &1 )
    ydata = xdata |> Enum.map(& :math.sin(&1/10.0) )


    xlims = Plotter.NumberUnits.range_from(xdata) |> Plotter.ViewRange.new(:horiz)
    xaxis = %Axis{limits: xlims}
    # Logger.warn("xlims: #{inspect xlims}")
    # Logger.warn("xaxis: #{inspect xaxis}")

    ylims = Plotter.NumberUnits.range_from(ydata) |> Plotter.ViewRange.new(:vert)
    yaxis = %Axis{limits: ylims}
    # Logger.warn("ylims: #{inspect ylims}")
    # Logger.warn("yaxis: #{inspect yaxis}")

    {xrng, yrng} = Plotter.plot_data({xdata, ydata}, xaxis, yaxis)
    # Logger.warn("xrng: #{inspect xrng |> Enum.to_list()}")
    # Logger.warn("yrng: #{inspect yrng |> Enum.to_list()}")

    xs = [{1, 0.1}, {2, 0.3666666666666667}, {3, 0.6333333333333333}, {4, 0.9}]
    assert xs == Enum.to_list(xrng)
    ys = [{0.09983341664682815, 0.1}, {0.19866933079506122, 0.37304159958561867}, {0.29552020666133955, 0.6405993825604989}, {0.3894183423086505, 0.9}]
    assert ys == Enum.to_list(yrng)
  end

  test "plot limits" do

    xdata = 1..4 |> Enum.map(& &1 )
    ydata = xdata |> Enum.map(& :math.sin(&1/10.0) )

    xlims = Plotter.NumberUnits.range_from(xdata) |> Plotter.ViewRange.new()
    xaxis = %Axis{limits: xlims}

    ylims = Plotter.NumberUnits.range_from(ydata) |> Plotter.ViewRange.new()
    yaxis = %Axis{limits: ylims}

    {xrng, yrng} = Plotter.limits([{xdata, ydata}])

    assert %ViewRange{start: 1, stop: 4} == xrng
    assert %ViewRange{start: 0.09983341664682815, stop: 0.3894183423086505} == yrng
  end

  test "simple plot" do
    xdata = 1..4 |> Enum.map(& &1 )
    ydata = xdata |> Enum.map(& :math.sin(&1/10.0) )

    plt = Plotter.plot([{xdata, ydata}])
    Logger.warn("plotter cfg: #{inspect plt }")
  end

  test "nil plot" do
    xdata = []
    ydata = []

    plt = Plotter.plot([{xdata, ydata}])
    Logger.warn("plotter cfg: #{inspect plt }")
  end

  test "nil date plot" do
    xdata = []
    ydata = []

    plt = Plotter.plot([{xdata, ydata}], xkind: :datetime)
    Logger.warn("plotter cfg: #{inspect plt }")
  end

end
