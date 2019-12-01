defmodule Plotex.Axis.Units.Numeric do
  require Logger
  alias Plotex.ViewRange

  @default_number_basis [1, 2, 5, 10, 20, 50, 100]

  defstruct basis: @default_number_basis, ticks: 10

  @doc """
  Get units for a given date range, using the number of ticks.

  """
  def units_for(x_a, x_b, config) do
    xmax = max(x_a, x_b)

    xdiff = abs(x_a - x_b)

    xmin = 1.0e-9
    xmin = if xmax/1.0e3 < xmin do xmax/1.0e3 else xmin end

    xdiff! =
      if xdiff < xmin do
        xmin
      else
        xdiff
      end

    xdiff! |> optimize_units(config)
  end

  @spec range_from(Enumerable.t()) :: {Number.t(), Number.t()}
  def range_from(data) do
    a = Enum.min(data)
    b = Enum.max(data)

    {a, b}
  end

  def optimize_units(xdiff, config) do
    count = config.ticks

    # Logger.warn("xdiff: #{inspect xdiff}")
    r = rank(xdiff, count)
    # Logger.warn("rank: #{inspect r}")
    b = find_basis(config.basis, xdiff, r, count)
    # Logger.warn("basis: #{inspect b}")
    %{val: xdiff, rank: r, basis: :math.pow(10, r) * b}
  end

  def find_basis(number_basis, x, rank, count) do
    number_basis
    |> Enum.map(&{&1, x / (&1 * :math.pow(count, 1 * rank))})
    |> Enum.min_by(fn {_base, val} -> abs(count - val) end)
    |> elem(0)
  end

  @doc """
  Calculate the base-10 rank of a number.
  """
  def rank(0, _b), do: raise %ArgumentError{message: "scale must needs to be non-zero"}
  # def rank(0.1, _b), do: raise %ArgumentError{message: "scale must needs to be non-zero"}
  def rank(x, b), do: trunc(:math.log10( (x+1.0e-8) / b) - 1)
end

defimpl Plotex.Axis.Units, for: Plotex.Axis.Units.Numeric do
  alias Plotex.ViewRange
  alias Plotex.Axis.Units

  def scale(%Plotex.Axis.Units.Numeric{} = config, %ViewRange{start: x_a, stop: x_b}) do
    %{basis: basis} = _units = Units.Numeric.units_for(x_a, x_b, config)
    # Logger.warn("x_basis: #{inspect units}")

    # stride = round(basis_count / Keyword.get(config, :ticks, 10))
    # Logger.warn("x_stride: #{inspect(stride)}")
    # Logger.warn("x_a: #{x_a}")
    # Logger.warn("x_fmod: #{inspect :math.fmod(x_a, basis)}")

    x_start =
      unless x_a < 0.0 do
        trunc( x_a / basis ) * basis
      else
        trunc( x_a / basis ) * basis - basis
      end

    # x_start = x_a - :math.fmod(x_a, basis)
    x_stop = x_b + basis

    # Logger.warn("x_start: #{inspect x_start}")
    rng =
      0..1_000_000_000
      |> Stream.map(fn i -> x_start + i * basis end)
      |> Stream.take_while(fn x -> x < x_stop end)

    %{data: rng, basis: basis}
  end

end
