defmodule Plotter.NumberUnits do
  require Logger

  @number_basis [1, 2, 5, 10, 20, 50, 100]

  @doc """
  Get units for a given date range, using the number of ticks.

  """
  def units_for(x_a, x_b, opts \\ []) do
    abs(x_a - x_b)
    |> optimize_units(opts)
  end

  @spec range_from(Enumerable.t()) :: {Number.t(), Number.t()}
  def range_from(data) do
    a = Enum.min(data)
    b = Enum.max(data)

    {a, b}
  end

  def number_scale(x_a, x_b, opts) do
    %{basis: basis} = units_for(x_a, x_b, opts)

    # stride = round(basis_count / Keyword.get(opts, :ticks, 10))
    # Logger.warn("x_stride: #{inspect(stride)}")
    x_start = x_a - :math.fmod(x_a, basis)
    x_stop = x_b + basis

    0..1_000_000_000
    |> Stream.map(fn i -> x_start + i*basis end)
    |> Stream.take_while(fn x -> x <  x_stop end)
  end

  def optimize_units(xdiff, opts \\ []) do
    count = Keyword.get(opts, :ticks, 10)

    r = rank(xdiff, count)
    Logger.warn("rank: #{inspect r}")
    b = find_basis(xdiff, r, count)
    Logger.warn("basis: #{inspect b}")
    %{val: xdiff, rank: r, basis: :math.pow(10, r) * b}
  end

  def find_basis(x, rank, count) do
    @number_basis
    |> Enum.map(& {&1, x / ( &1 * :math.pow(count, 1 * rank))} )
    |> Enum.min_by(fn {_base, val} -> abs(count-val) end) |> elem(0)
  end

  @doc """
  Calculate the base-10 rank of a number.
  """
  def rank(x, b), do: trunc( :math.log10( x / b  ) - 1 )

end
