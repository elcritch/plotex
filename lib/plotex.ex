defmodule Plotex do
  alias Plotex.ViewRange
  alias Plotex.Axis
  require Logger

  @moduledoc """
  Documentation for Plotex.
  """
  defstruct [:config, :xticks, :yticks, :datasets, :datasets]

  @type t :: %Plotex{config: Plotex.Config.t(),
                      xticks: Enumerable.t(),
                      yticks: Enumerable.t(),
                      datasets: Enumerable.t()}

  def generate_axis(%Axis{kind: :numeric} = axis) do
    a = axis.limits.start
    b = axis.limits.stop
    n = axis.ticks

    unless a == nil || b == nil do
      [data: data, basis: basis] = Plotex.NumberUnits.number_scale(a, b, ticks: n)
      xrng = scale_data(data, axis)

      [data: Stream.zip(data, xrng), basis: basis]
    else
      [data: [], basis: nil]
    end
  end

  def generate_axis(%Axis{kind: :datetime} = axis) do
    a = axis.limits.start
    b = axis.limits.stop
    n = axis.ticks

    # Logger.warn("AXIS: a, b: #{inspect {a,b}}")
    unless a == nil || b == nil do
      %{data: data, basis: basis} = Plotex.TimeUnits.time_scale(a, b, ticks: n)
      # Logger.warn("AXIS DATA: #{inspect data |> Enum.to_list()}")
      xrng = scale_data(data, axis)

      [data: Stream.zip(data, xrng), basis: basis]
    else
      [data: [], basis: nil]
    end
  end

  def scale_data(_data, %Axis{limits: %{start: start, stop: stop} } = _axis ) when is_nil(start) or is_nil(stop) do
    []
  end
  def scale_data(data, %Axis{} = axis ) do
    # Logger.warn("SCALE_DATA: #{inspect axis}")
    m = ViewRange.diff( axis.view.stop, axis.view.start )
          / ViewRange.diff( axis.limits.stop, axis.limits.start )
    b = axis.view.start |> ViewRange.val()
    x! = axis.limits.start |> ViewRange.val()

    data
    |> Stream.map(fn x -> m*(ViewRange.val(x)-x!) + b  end)
  end

  def plot_data({xdata, ydata}, %Axis{} = xaxis, %Axis{} = yaxis ) do

    xrng = scale_data(xdata, xaxis)
    yrng = scale_data(ydata, yaxis)

    {Enum.zip(xdata, xrng), Enum.zip(ydata, yrng)}
  end

  def range_from(data) do
    unless Enum.count(data) == 0 do
      Enum.min_max_by(data, &Plotex.ViewRange.convert/1)
    else
      {nil, nil}
    end
  end

  def limits(datasets, opts \\ []) do
    # Logger.warn("plot: limits: opts: #{inspect opts}")
    proj = Keyword.get(opts, :projection, :cartesian)

    {{xa, xb}, {ya, yb}} =
      datasets
      |> Enum.reduce({nil, nil}, fn {xdata, ydata}, {xlims, ylims} ->
        xlims! = xdata |> Plotex.range_from()
        ylims! = ydata |> Plotex.range_from()

        xlims! = ViewRange.min_max(xlims, xlims!)
        ylims! = ViewRange.min_max(ylims, ylims!)

        {xlims!, ylims!}
      end)

    xpad = (opts[:xaxis][:padding] || 0.05) * ViewRange.dist({xa, xb})
    {xa, xb} = ViewRange.pad({xa, xb}, xpad)

    ypad = (opts[:yaxis][:padding] || 0.05) * ViewRange.dist({ya, yb})
    {ya, yb} = ViewRange.pad({ya, yb}, ypad)

    {%ViewRange{start: xa, stop: xb, projection: proj},
     %ViewRange{start: ya, stop: yb, projection: proj}}
  end

  @spec plot([ [{number, number}] ], nil | keyword | map) :: Plotex.t()
  def plot(datasets, opts \\ []) do
    {xlim, ylim} = limits(datasets, opts)

    xaxis = %Axis{
      limits: xlim,
      kind: opts[:xaxis][:kind] || :numeric,
      ticks: opts[:xaxis][:ticks] || 10,
      view: %ViewRange{start: 10, stop: (opts[:xaxis][:width] || 100) - 10}
    }
    yaxis = %Axis{
      limits: ylim,
      kind: opts[:yaxis][:kind] || :numeric,
      ticks: opts[:yaxis][:ticks] || 10,
      view: %ViewRange{start: 10, stop: (opts[:yaxis][:width] || 100) - 10}
    }

    # Logger.warn("plot xaxis: #{inspect xaxis}")
    # Logger.warn("plot yaxis: #{inspect yaxis}")

    [data: xticks, basis: xbasis] = generate_axis(xaxis)

    xticks =
      xticks
      |> Stream.filter(& elem(&1, 1) >= xaxis.view.start)
      |> Stream.filter(& elem(&1, 1) <= xaxis.view.stop)

    [data: yticks, basis: ybasis] = generate_axis(yaxis)
    yticks =
      yticks
      |> Stream.filter(& elem(&1, 1) >= yaxis.view.start )
      |> Stream.filter(& elem(&1, 1) <= yaxis.view.stop )

    xaxis = xaxis |> Map.put(:basis, xbasis)
    yaxis = yaxis |> Map.put(:basis, ybasis)

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
