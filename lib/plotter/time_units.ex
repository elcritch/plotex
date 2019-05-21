defmodule Plotter.TimeUnits do
  require Logger

  @time_basis [
    # Decades
    decade: {315_360_000, 1},
    # Years
    year: {31_536_000, 2},
    # Months
    month: {2_592_000, 3},
    # Weeks
    week: {604_800, 4},
    # Days
    day: {86_400, 5},
    # Hours
    half_day: {43_200, 6},
    quarter_day: {21_600, 6},
    eigth_day: {10_800, 6},
    hour: {3_600, 6},
    # Minutes
    half_hour: {1_800, 6},
    quarter_hour: {900, 6},
    minute: {60, 7},
    # Seconds
    half_minute: {30, 8},
    quarter_minute: {15, 8},
    second: {1, 8},
    # Milliseconds
    millisecond: {1.0e-3, 9},
    # Microseconds
    microsecond: {1.0e-6, 10},
  ]

  @doc """
  Get units for a given date range, using the number of ticks.

  """
  @spec units_for(DateTime.t(), DateTime.t(), keyword()) :: {number(), {atom(), integer(), integer()}}
  def units_for(dt_a, dt_b, opts \\ []) do
    DateTime.diff(dt_a, dt_b)
    |> abs()
    |> optimize_units(opts)
  end

  @spec date_range_from(Enumerable.t()) :: {DateTime.t(), DateTime.t()}
  def date_range_from(data) do
    a = Enum.at(data, 0)
    b = Enum.at(data, -1)

    unless DateTime.compare(a, b) == :lt do
      {a, b}
    else
      {b, a}
    end
  end

  @spec optimize_units(number(), keyword()) :: {number(), {atom(), integer(), integer()}}
  def optimize_units(diff_seconds, opts \\ []) do
    count = Keyword.get(opts, :ticks, 10)
    delta = diff_seconds / count

    idx =
      @time_basis
      |> Enum.find_index(fn {_time_unit, {diff_val, _time_ord}} ->
        delta >= diff_val
      end)

    {basis_name, {basis_val, basis_order}} =
      @time_basis |> Enum.at(idx |> max(0) |> min(Enum.count(@time_basis) - 1))

    {diff_seconds, {basis_name, basis_val, basis_order}}
  end

  def time_units() do
    @time_basis
  end

  def next_smaller_unit({_name, amount}) do
    optimize_units(amount - 1.0) |> elem(1)
  end

  def time_scale(data, opts \\ []) do
    {dt_a, dt_b} = date_range_from(data)
    time_scale(dt_a, dt_b, opts)
  end

  def time_scale(dt_a, dt_b, opts) do
    {diff_seconds, unit} = units_for(dt_a, dt_b, opts)
    {_unit_name, unit_val, _unit_number} = unit
    # Logger.warn("unit name: #{inspect(unit)}")
    dt_start = clone(dt_a, unit)

    basis_count = diff_seconds / unit_val

    stride =
      if opts[:ticks] do
        round(basis_count / opts[:ticks])
      else
        round(basis_count / 10)
      end

    # Logger.warn("time_stride: #{inspect(stride)}")

    0..1_000_000_000
    |> Stream.map(fn i ->
      # Logger.warn("#{inspect(dt_start)}")
      # Logger.warn("#{inspect({i, unit_val, i * unit_val})}")
      DateTime.add(dt_start, i * unit_val, :second)
    end)
    |> Stream.take_every(stride)
    |> Stream.take_while(fn dt -> DateTime.compare(dt, dt_b) == :lt end)
  end

  @spec gets(map(), {atom(), integer(), integer()}, atom()) :: integer()
  defp gets(dt, {_base_unit, _base_number, base_order}, field) do
    {_fn, {_fval, field_order}} = Enum.find(@time_basis, fn xf -> field == elem(xf,0) end)

    cond do
      base_order >= field_order ->
        dt[field]

      true ->
        0
    end
  end

  def clone(%DateTime{} = dt, unit) do
    dt = dt |> Map.from_struct()

    %DateTime{
      day: gets(dt, unit, :day),
      hour: gets(dt, unit, :hour),
      minute: gets(dt, unit, :minute),
      month: gets(dt, unit, :month),
      second: gets(dt, unit, :second),
      microsecond: {gets(dt, unit, :microsecond), 6},

      calendar: dt.calendar,
      std_offset: dt.std_offset,
      time_zone: dt.time_zone,
      utc_offset: dt.utc_offset,
      year: dt.year,
      zone_abbr: dt.zone_abbr
    }
  end
end
