defmodule Plotter do
  alias Plotter.ViewRange
  alias Plotter.Axis
  require Logger

  @moduledoc """
  Documentation for Plotter.
  """
  defstruct [:config, :xticks, :yticks, :datasets, :datasets]

  @type t :: %Plotter{config: Plotter.Config.t(),
                      xticks: Enumerable.t(),
                      yticks: Enumerable.t(),
                      datasets: Enumerable.t()}

  def generate_axis(%Axis{kind: :numeric} = axis) do
    a = axis.limits.start
    b = axis.limits.stop
    n = axis.ticks

    unless a == nil || b == nil do
      data = Plotter.NumberUnits.number_scale(a, b, ticks: n)
      xrng = scale_data(data, axis)

      Stream.zip(data, xrng)
    else
      []
    end
  end

  def generate_axis(%Axis{kind: :datetime} = axis) do
    a = axis.limits.start
    b = axis.limits.stop
    n = axis.ticks

    Logger.warn("AXIS: a, b: #{inspect {a,b}}")
    unless a == nil || b == nil do
      data = Plotter.TimeUnits.time_scale(a, b, ticks: n)
      Logger.warn("AXIS DATA: #{inspect data |> Enum.to_list()}")
      xrng = scale_data(data, axis)

      Stream.zip(data, xrng)
    else
      []
    end
  end

  def scale_data(_data, %Axis{limits: %{start: nil, stop: nil} } = _axis ) do
    []
  end
  def scale_data(data, %Axis{} = axis ) do
    Logger.warn("SCALE_DATA: #{inspect axis}")
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

    {Enum.zip(xdata, xrng), Enum.zip(ydata, yrng)}
  end

  def range_from(data) do
    unless Enum.count(data) == 0 do
      Enum.min_max_by(data, &Plotter.ViewRange.convert/1)
    else
      {nil, nil}
    end
  end

  def limits(datasets, opts \\ []) do
    Logger.warn("plot: opts: #{inspect opts}")
    proj = Keyword.get(opts, :projection, :cartesian)

    {{xa, xb}, {ya, yb}} =
      datasets
      |> Enum.reduce({nil, nil}, fn {xdata, ydata}, {xlims, ylims} ->
        xlims! = xdata |> Plotter.range_from()
        ylims! = ydata |> Plotter.range_from()

        xlims! = ViewRange.min_max(xlims, xlims!)
        ylims! = ViewRange.min_max(ylims, ylims!)

        {xlims!, ylims!}
      end)

    xpad = (opts[:xaxis][:padding] || 0.05) * ViewRange.dist({xa, xb})
    ypad = (opts[:yaxis][:padding] || 0.05) * ViewRange.dist({ya, yb})

    {xa, xb} = ViewRange.pad({xa, xb}, xpad)
    {ya, yb} = ViewRange.pad({ya, yb}, ypad)

    {%ViewRange{start: xa, stop: xb, projection: proj},
     %ViewRange{start: ya, stop: yb, projection: proj}}
  end

  @spec plot([ [{number, number}] ], nil | keyword | map) :: Plotter.t()
  def plot(datasets, opts \\ []) do
    {xlim, ylim} = limits(datasets, opts)

    config = %Plotter.Config{
      xaxis: %Axis{limits: xlim, kind: opts[:xkind] || :numeric},
      yaxis: %Axis{limits: ylim, },
    }

    xticks =
      generate_axis(config.xaxis)
      |> Stream.filter(& elem(&1, 1) >= config.xaxis.view.start)
      |> Stream.filter(& elem(&1, 1) <= config.xaxis.view.stop)

    yticks =
      generate_axis(config.yaxis)
      |> Stream.filter(& elem(&1, 1) >= config.yaxis.view.start )
      |> Stream.filter(& elem(&1, 1) <= config.yaxis.view.stop )

    Logger.warn("xticks: #{inspect xticks  |> Enum.to_list()}")
    Logger.warn("yticks: #{inspect yticks  |> Enum.to_list()}")

    datasets! =
      for {data, idx} <- datasets |> Stream.with_index(), into: [] do
        {xd, yd} = Plotter.plot_data(data, config.xaxis, config.yaxis)
        {Stream.zip(xd, yd), idx}
      end

    Logger.warn  "datasets! => #{inspect datasets! |> Enum.at(0) |> elem(0) |> Enum.to_list()}"

    %Plotter{config: config,
      xticks: xticks,
      yticks: yticks,
      datasets: datasets!}
  end

end
