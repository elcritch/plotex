defmodule Plotex do
  alias Plotex.ViewRange
  alias Plotex.Axis
  alias Plotex.Output.Formatter
  require Logger

  @moduledoc """
  Documentation for Plotex.

  TODO
  """
  defstruct [:config, :xticks, :yticks, :datasets, :datasets]

  @type t :: %Plotex{config: Plotex.Config.t(),
                      xticks: Enumerable.t(),
                      yticks: Enumerable.t(),
                      datasets: Enumerable.t()}

  @doc """
  Generates a stream of the data points (ticks) for a given axis.
  """
  def generate_axis(%Axis{units: units} = axis) do
    a = axis.limits.start
    b = axis.limits.stop

    unless a == nil || b == nil do
      %{data: data, basis: basis} = Plotex.Axis.Units.scale(units, axis.limits)
      xrng = scale_data(data, axis)

      [data: Stream.zip(data, xrng), basis: basis]
    else
      [data: [], basis: nil]
    end
  end

  @doc """
  Returns a stream of scaled data points zipped with the original points.
  """
  def scale_data(_data, %Axis{limits: %{start: start, stop: stop} } = _axis ) when is_nil(start) or is_nil(stop) do
    []
  end
  def scale_data(data, %Axis{} = axis ) do
    # Logger.warn("SCALE_DATA: #{inspect axis}")
    m = ViewRange.diff( axis.view.stop, axis.view.start )
          / ViewRange.diff( axis.limits.stop, axis.limits.start )
    b = axis.view.start |> ViewRange.to_val()
    x! = axis.limits.start |> ViewRange.to_val()

    data
    |> Stream.map(fn x -> m*(ViewRange.to_val(x)-x!) + b  end)
  end

  @doc """
  Returns of scaled data for both X & Y coordinates for a given {X,Y} dataset.
  """
  def plot_data({xdata, ydata}, %Axis{} = xaxis, %Axis{} = yaxis ) do

    xrng = scale_data(xdata, xaxis)
    yrng = scale_data(ydata, yaxis)

    {Enum.zip(xdata, xrng), Enum.zip(ydata, yrng)}
  end

  @doc """
  Find the appropriate limits given an enumerable of datasets.

  For example, given {[1,2,3,4], [0.4,0.3,0.2,0.1]} will find the X limits 1..4
  and the Y limits of 0.1..0.4.
  """
  def limits(datasets, opts \\ []) do
    proj = Keyword.get(opts, :projection, :cartesian)

    {xl, yl} =
      for {xdata, ydata} <- datasets, reduce: {ViewRange.empty, ViewRange.empty} do
        {xlims, ylims} ->
          xlims! = xdata |> ViewRange.from(proj)
          ylims! = ydata |> ViewRange.from(proj)

          xlims! = ViewRange.min_max(xlims, xlims!)
          ylims! = ViewRange.min_max(ylims, ylims!)

          {xlims!, ylims!}
      end

    xpad = (opts[:xaxis][:padding] || 0.05)
    xl = ViewRange.pad(xl, opts[:xaxis] || [])

    ypad = (opts[:yaxis][:padding] || 0.05)
    yl = ViewRange.pad(yl, opts[:yaxis] || [])

    # Logger.warn("lims reduced: limits!: post!: #{inspect {xl, yl}}")
    {xl, yl}
  end

  def std_units(opts) do
    case opts[:kind] do
      nil -> nil
      :numeric -> %Axis.Units.Numeric{}
      :datetime -> %Axis.Units.Time{}
    end
  end
  def std_fmt(opts) do
    case opts[:kind] do
      nil -> %Plotex.Output.Formatter.NumericDefault{}
      :numeric -> %Plotex.Output.Formatter.NumericDefault{}
      :datetime -> %Plotex.Output.Formatter.DateTime.Calendar{}
    end
  end

  @doc """
  Create a Plotex struct for given datasets and configuration. Will load and scan data
  for all input datasets.
  """
  @spec plot([ [{number, number}] ], nil | keyword | map) :: Plotex.t()
  def plot(datasets, opts \\ []) do
    {xlim, ylim} = limits(datasets, opts)

    # ticks = opts[:xaxis][:ticks]

    # And this part is kludgy...
    xaxis = %Axis{
      limits: xlim,
      units: struct(opts[:xaxis][:units] || std_units(opts[:xaxis]) || %Axis.Units.Numeric{}),
      formatter: struct(opts[:xaxis][:formatter] || std_fmt(opts[:xaxis]) || %Formatter.NumericDefault{}),
      view: %ViewRange{start: 10, stop: (opts[:xaxis][:width] || 100) - 10}
    }
    yaxis = %Axis{
      limits: ylim,
      units: struct(opts[:yaxis][:units] || std_units(opts[:yaxis]) || %Axis.Units.Numeric{}),
      formatter: struct(opts[:yaxis][:formatter] || std_fmt(opts[:yaxis]) || %Formatter.DateTime.Calendar{}),
      view: %ViewRange{start: 10, stop: (opts[:yaxis][:width] || 100) - 10}
    }

    [data: xticks, basis: xbasis] = generate_axis(xaxis)

    xticks =
      xticks
      |> Stream.filter(& elem(&1, 1) >= xaxis.view.start)
      |> Stream.filter(& elem(&1, 1) <= xaxis.view.stop)
      |> Enum.to_list

    [data: yticks, basis: ybasis] = generate_axis(yaxis)
    yticks =
      yticks
      |> Stream.filter(& elem(&1, 1) >= yaxis.view.start )
      |> Stream.filter(& elem(&1, 1) <= yaxis.view.stop )

    xaxis = xaxis |> Map.put(:basis, xbasis)
    yaxis = yaxis |> Map.put(:basis, ybasis)

    # Logger.warn("plot xaxis: #{inspect xaxis}")
    # Logger.warn("plot yaxis: #{inspect yaxis}")

    config = %Plotex.Config{
      xaxis: xaxis,
      yaxis: yaxis,
    }

    # Logger.warn("xticks: #{inspect xticks  |> Enum.to_list()}")
    # Logger.warn("yticks: #{inspect yticks  |> Enum.to_list()}")

    datasets! =
      for {data, idx} <- datasets |> Stream.with_index(), into: [] do
        {xd, yd} = Plotex.plot_data(data, config.xaxis, config.yaxis)
        {Stream.zip(xd, yd), idx}
      end

    # Logger.warn  "datasets! => #{inspect datasets! |> Enum.at(0) |> elem(0) |> Enum.to_list()}"

    %Plotex{config: config,
      xticks: xticks,
      yticks: yticks,
      datasets: datasets!}
  end

end
