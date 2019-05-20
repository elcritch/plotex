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
  Hello world.

  ## Examples

      iex> Plotter.hello()
      :world

  """
  @spec units_for( DateTime.t(), DateTime.t(), keyword() ) :: { atom(), integer() }
  def units_for(dt_a, dt_b, opts \\ []) do
    DateTime.diff(dt_a, dt_b)
    |> abs()
    |> optimize_units(opts)
  end

  @spec units_from( Enumerable.t(), keyword() ) :: { atom(), integer() }
  def units_from(data, opts \\ []) do
    if length(data) == 0 do
      opts[:default] || @time_basis[5]
    else
      a = Enum.at(data, 0)
      b = Enum.at(data, -1)
      unless DateTime.compare(a,b) == :lt do
        units_for(a, b, opts)
      else
        units_for(b, a, opts)
      end
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

  #  a = DateTime.from_iso8601 "2019-05-20 01:55:41.541044Z"
  #  b = DateTime.from_iso8601 "2019-05-20 01:54:02.540529Z"

end
