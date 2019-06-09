defmodule PlotEx.TimeUnits do
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
    microsecond: {1.0e-6, 10}
  ]

  def display_epoch(order) do
      case order do
        ord when ord <= 2 -> :year
        ord when ord <= 4 -> :month
        ord when ord <= 5 -> :day
        ord when ord <= 6 -> :hour
        ord when ord <= 7 -> :minute
        ord when ord <= 8 -> :second
        ord when ord <= 9 -> :millisecond
      end
  end

  defstruct [:basis_name, :val, :order, :diff]

  @type t :: %PlotEx.TimeUnits{basis_name: atom, val: number, order: number, diff: number }
  @doc """
  Get units for a given date range, using the number of ticks.

  """
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

  @spec optimize_units(number, keyword) :: PlotEx.TimeUnits.t()
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

    %PlotEx.TimeUnits{basis_name: basis_name, val: basis_val, order: basis_order, diff: diff_seconds}
  end

  def time_units() do
    @time_basis
  end

  def next_smaller_unit({_name, amount}) do
    optimize_units(amount - 1.0).basis_name
  end

  def time_scale(data, opts \\ []) do
    {dt_a, dt_b} = date_range_from(data)
    time_scale(dt_a, dt_b, opts)
  end

  def time_scale(dt_a, dt_b, opts) do
    %{diff: diff_seconds, val: unit_val} = basis = units_for(dt_a, dt_b, opts)
    dt_start = clone(dt_a, basis)

    basis_count = diff_seconds / unit_val
    stride = round(basis_count / Keyword.get(opts, :ticks, 10))

    # Logger.warn("time_stride: #{inspect(stride)}")

    rng =
      0..1_000_000_000
      |> Stream.map(fn i ->
        # Logger.warn("#{inspect(dt_start)}")
        # Logger.warn("#{inspect({i, unit_val, i * unit_val})}")
        DateTime.add(dt_start, round(i * unit_val), :second)
      end)
      |> Stream.take_every(stride)
      |> Stream.take_while(fn dt -> DateTime.compare(dt, dt_b) == :lt end)

    %{data: rng, basis: basis}
  end

  defp gets(dt, %{basis_name: _base_unit, val: _base_number, order: base_order}, field) do
    {_fn, {_fval, field_order}} = Enum.find(@time_basis, fn xf -> field == elem(xf, 0) end)

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
