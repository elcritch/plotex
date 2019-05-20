defmodule Plotter.TimeUnits do
  require Logger

  @time_basis [
    full_day: 86400,
    half_day: 43200,
    quarter_day: 21600,
    eigth_day: 10800,

    full_hour: 3600,
    half_hour: 1800,
    quarter_hour: 900,

    minute: 60,
    half_minute: 30,
    quarter_minute: 15,

    second: 1,
    millisecond: 1.0e-3,
    microsecond: 1.0e-6,
  ]

  @doc """
  Get units for a given date range, using the number of ticks.

  """
  @spec units_for( DateTime.t(), DateTime.t(), keyword() ) :: { atom(), integer() }
  def units_for(dt_a, dt_b, opts \\ []) do
    DateTime.diff(dt_a, dt_b)
    |> abs()
    |> optimize_units(opts)
  end

  @spec date_range_from( Enumerable.t() ) :: { DateTime.t(), DateTime.t() }
  def date_range_from(data) do
    a = Enum.at(data, 0)
    b = Enum.at(data, -1)

    unless DateTime.compare(a,b) == :lt do
      {a,b}
    else
      {b,a}
    end
  end

  def optimize_units(diff_seconds, opts \\ []) do
    count = Keyword.get(opts, :ticks, 10)
    delta = diff_seconds / count

    idx =
      @time_basis
      |> Enum.find_index(fn {_time_unit, dt_val} ->
        delta >= dt_val
      end)

    @time_basis |> Enum.at( (idx) |> max(0) |> min(Enum.count(@time_basis)-1) )
  end

  def time_units() do
    @time_basis
  end

  def next_smaller_unit({_name, amount}) do
    optimize_units(amount - 1.0)
  end

  def time_scale(data, opts \\ []) do
    {dt_a, dt_b} = date_range_from(data)
    unit = units_for(dt_a, dt_b, opts)

    clone(dt_a, unit)
    |> Stream.map(fn dt ->
      dt
    end)
    |> Stream.filter(fn dt ->
      DateTime.compare(dt, dt_b) == :lt
    end)
  end

  @spec gets(map(), {atom(), integer(), integer()}, atom()) :: integer()
  defp gets(dt, {_base_unit, base_number, base_value}, field) do
    {_field_unit, field_val, _field_num} = basis_unit({field, 0})
    cond do
      base_number < field_val ->
        dt[field]
      base_number < field_val ->
        base_value
      true ->
        0
    end
  end

  def clone(%DateTime{} = dt, unit) do
    bu = basis_unit(unit)
    dt = dt |> Map.from_struct()

    %DateTime{
      day: gets(dt, bu, :day),
      hour: gets(dt, bu, :hour),
      minute: gets(dt, bu, :minute),
      month: gets(dt, bu, :month),
      second: gets(dt, bu, :second),
      microsecond: {gets(dt, bu, :microsecond), 6},

      calendar: dt.calendar,
      std_offset: dt.std_offset,
      time_zone: dt.time_zone,
      utc_offset: dt.utc_offset,
      year: dt.year,
      zone_abbr: dt.zone_abbr,
    }
  end

  @spec basis_unit({atom(), integer()}) :: {:day, 1, integer()} |
                              {:hour, 2, integer()} |
                              {:minute, 3, integer()} |
                              {:second, 4, integer()} |
                              {:microsecond, 5, integer()}
  def basis_unit({unit_name, unit_value}) do
    case unit_name do
      n when n in [:full_day, :day] ->
        {:day, 1, unit_value}
      n when n in [:half_day, :quarter_day, :eigth_day, :full_hour, :hour] ->
        {:hour, 2, unit_value}
      n when n in [:half_hour, :quarter_hour, :minute] ->
        {:minute, 3, unit_value}
      n when n in [:half_minute, :quarter_minute, :second] ->
        {:second, 4, unit_value}
      n when n in [:millisecond, :microsecond] ->
        {:microsecond, 5, unit_value}
    end
  end
end
