defmodule Plotter do
  alias Plotter.ViewRange
  alias Plotter.Axis
  require Logger

  @moduledoc """
  Documentation for Plotter.
  """
  defstruct xaxis: %Axis{},
            yaxis: %Axis{}

  def generate_axis(%Axis{} = axis) do
    a = axis.limits.start
    b = axis.limits.stop
    n = axis.ticks

    data = Plotter.NumberUnits.number_scale(a, b, ticks: n)
    xrng = scale_data(data, axis)

    Stream.zip(data, xrng)
  end

  def scale_data(data, %Axis{} = axis ) do
    m = ( axis.view.stop - axis.view.start )
          / ( axis.limits.stop - axis.limits.start )
    b = axis.view.start
    x! = axis.limits.start

    data
    |> Stream.map(fn x -> m*(x-x!) + b  end)
  end

  def plot_data({xdata, ydata}, %Axis{} = xaxis, %Axis{} = yaxis ) do

    xrng = scale_data(xdata, xaxis)
    yrng = scale_data(ydata, yaxis)

    {xrng, yrng}
  end

  def range_from(data) do
    Enum.min_max_by(data, &Plotter.ViewRange.convert/1)
  end

  def limits(datasets, opts \\ []) do
    Logger.warn("plot: opts: #{inspect opts}")
    proj = Keyword.get(opts, :projection, :cartesian)

    {{xa, xb}, {ya, yb}} =
      datasets
      |> Enum.reduce({nil, nil}, fn {xdata, ydata}, {xlims, ylims} ->
        xlims! = xdata |> Plotter.range_from()
        ylims! = ydata |> Plotter.range_from()

        xlims! = Plotter.ViewRange.min_max(xlims, xlims!)
        ylims! = Plotter.ViewRange.min_max(ylims, ylims!)

        {xlims!, ylims!}
      end)

    {%ViewRange{start: xa, stop: xb, projection: proj},
     %ViewRange{start: ya, stop: yb, projection: proj}}
  end

  def plot(datasets, _opts \\ []) do
    {xlim, ylim} = limits(datasets)

    plt = %Plotter{
      xaxis: %Axis{limits: xlim, },
      yaxis: %Axis{limits: ylim, },
    }

    xticks = generate_axis(plt.xaxis)
    yticks = generate_axis(plt.yaxis)
    Logger.warn("xticks: #{inspect xticks  |> Enum.to_list()}")
    Logger.warn("yticks: #{inspect yticks  |> Enum.to_list()}")

    datasets! =
      for {x,y} = data <- datasets, into: [] do
        {xd, yd} = Plotter.plot_data(data, plt.xaxis, plt.yaxis)
        Logger.warn("xdata #{inspect x |> Enum.to_list()}")
        Logger.warn("xdata! #{inspect xd |> Enum.to_list()}")
        Logger.warn("ydata #{inspect y |> Enum.to_list()}")
        Logger.warn("ydata! #{inspect yd |> Enum.to_list()}")
        {xd, yd}
      end

    %{config: plt,
      xticks: xticks,
      yticks: yticks,
      datasets: datasets!}
  end

end
