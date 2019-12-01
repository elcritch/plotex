
defmodule Plotex.Axis.Units.Time.Item do
  defstruct [:basis_name, :val, :order, :diff]
  @type t :: %__MODULE__{basis_name: atom, val: number, order: number, diff: number }
end


defmodule Plotex.Axis.Units.Time do
  require Logger
  alias Plotex.Axis.Units
  alias Plotex.ViewRange

  @default_time_basis [
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

  defstruct time_basis: @default_time_basis, ticks: 10, min_basis: :microsecond

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

  @doc """
  Get units for a given date range, using the number of ticks.

  """
  def units_for(%DateTime{} = dt_a, %DateTime{} = dt_b, config) do
    DateTime.diff(dt_a, dt_b)
    |> abs()
    |> optimize_units(config)
  end
  def units_for(%NaiveDateTime{} = dt_a, %NaiveDateTime{} = dt_b, config) do
    NaiveDateTime.diff(dt_a, dt_b)
    |> abs()
    |> optimize_units(config)
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

  @spec optimize_units(number, struct()) :: __MODULE__.t()
  def optimize_units(diff_seconds, config) do
    count = config.ticks
    delta = diff_seconds / count
    {min_time_delta, _} = Keyword.get(config.time_basis, config.min_basis)

    idx =
      config.time_basis
      |> Enum.find_index(fn {_time_unit, {diff_val, _time_ord}} ->
        delta >= diff_val && diff_val >= min_time_delta
      end)

    bcount = Enum.count(config.time_basis)

    {basis_name, {basis_val, basis_order}} =
      config.time_basis |> Enum.at(idx |> max(0) |> min(bcount - 1))

    %__MODULE__.Item{basis_name: basis_name, val: basis_val, order: basis_order, diff: diff_seconds}
  end

  def next_smaller_unit({_name, amount}, config) do
    optimize_units(amount - 1.0, config).basis_name
  end


  defp gets(dt, %{basis_name: _base_unit, val: _base_number, order: base_order}, config, field) do
    {_fn, {_fval, field_order}} = Enum.find(config.time_basis, fn xf -> field == elem(xf, 0) end)

    cond do
      base_order >= field_order ->
        dt[field]

      true ->
        0
    end
  end

  def dt_add(%DateTime{} = dt_start, val, units) do
      DateTime.add(dt_start, val, units)
  end
  def dt_add(%NaiveDateTime{} = dt_start, val, units) do
      NaiveDateTime.add(dt_start, val, units)
  end

  def dt_compare(%DateTime{} = dt_a, %DateTime{} = dt_b) do
      DateTime.compare(dt_a, dt_b)
  end
  def dt_compare(%NaiveDateTime{} = dt_a, %NaiveDateTime{} = dt_b) do
      NaiveDateTime.compare(dt_a, dt_b)
  end


  def clone(%DateTime{} = dt, unit, config) do
    dt = dt |> Map.from_struct()

    %DateTime{
      day: gets(dt, unit, config, :day),
      hour: gets(dt, unit, config, :hour),
      minute: gets(dt, unit, config, :minute),
      month: gets(dt, unit, config, :month),
      second: gets(dt, unit, config, :second),
      microsecond: {gets(dt, unit, config, :microsecond), 6},
      calendar: dt.calendar,
      std_offset: dt.std_offset,
      time_zone: dt.time_zone,
      utc_offset: dt.utc_offset,
      year: dt.year,
      zone_abbr: dt.zone_abbr
    }
  end

  def clone(%NaiveDateTime{} = dt, unit, config) do
    dt = dt |> Map.from_struct()

    %NaiveDateTime{
      day: gets(dt, unit, config, :day),
      hour: gets(dt, unit, config, :hour),
      minute: gets(dt, unit, config, :minute),
      month: gets(dt, unit, config, :month),
      second: gets(dt, unit, config, :second),
      microsecond: {gets(dt, unit, config, :microsecond), 6},
      calendar: dt.calendar,
      year: dt.year,
    }
  end
end

defimpl Plotex.Axis.Units, for: Plotex.Axis.Units.Time do
  alias Plotex.ViewRange
  alias Plotex.Axis.Units

  # def time_scale(data, config \\ []) do
  #   {dt_a, dt_b} = date_range_from(data)
  #   time_scale(dt_a, dt_b, config)
  # end

  def scale(config, %ViewRange{start: dt_a, stop: dt_b}) do
    %{diff: diff_seconds, val: unit_val} = basis = Units.Time.units_for(dt_a, dt_b, config)
    dt_start = Units.Time.clone(dt_a, basis, config)

    basis_count = diff_seconds / unit_val
    stride = round(basis_count / config.ticks )

    # Logger.warn("time_stride: #{inspect(stride)}")

    rng =
      0..1_000_000_000
      |> Stream.map(fn i ->
        # Logger.warn("#{inspect(dt_start)}")
        # Logger.warn("#{inspect({i, unit_val, i * unit_val})}")
        Units.Time.dt_add(dt_start, round(i * unit_val), :second)
      end)
      |> Stream.take_every(stride)
      |> Stream.take_while(fn dt -> Units.Time.dt_compare(dt, dt_b) == :lt end)

    %{data: rng, basis: basis}
  end
end
