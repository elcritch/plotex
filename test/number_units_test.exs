defmodule Axis.Units.NumericTest do
  use ExUnit.Case
  doctest Plotex
  require Logger
  alias Plotex.Axis
  alias Plotex.ViewRange

  test "base-10 rank for numbers" do
    ranks =
      [1000, 120.2, 53.9, 13.1, 8.9, 0.98, 0.0396]
      |> Enum.map(&Axis.Units.Numeric.rank(&1, 10))

    assert ranks == [1, 0, 0, 0, -1, -2, -3]
  end

  @config %Plotex.Axis.Units.Numeric{}

  test "basis 1.0 " do
    x_a = 1.123
    x_b = 13.45

    %{basis: xbasis} = Axis.Units.Numeric.units_for(x_a, x_b, @config)
    assert xbasis == 1.0
  end

  test "basis 0.05 " do
    x_a = 1.123
    x_b = 1.52

    %{basis: xbasis} = Axis.Units.Numeric.units_for(x_a, x_b, @config)
    assert xbasis == 0.05
  end

  test "basis 10 " do
    x_a = 1.123
    x_b = 130.45

    %{basis: xbasis} = Axis.Units.Numeric.units_for(x_a, x_b, @config)
    assert xbasis == 10.0
  end

  test "basis 50 " do
    x_a = 1.123
    x_b = 530.45

    # units = Axis.Units.Numeric.units_for(x_a, x_b, @config)
    # Logger.warn("units: #{inspect units}")

    %{basis: xbasis} = Axis.Units.Numeric.units_for(x_a, x_b, @config)
    assert xbasis == 50.0
  end

  test "decade 100 " do
    x_a = 1.123
    x_b = 930.45

    # units = Axis.Units.Numeric.units_for(x_a, x_b, @config)
    # Logger.warn("units: #{inspect units}")

    %{basis: xbasis} = Axis.Units.Numeric.units_for(x_a, x_b, @config)
    assert xbasis == 100.0
  end

  test "decade 200 " do
    x_a = 1.123
    x_b = 1930.45

    # units = Axis.Units.Numeric.units_for(x_a, x_b, @config)
    # Logger.warn("units: #{inspect units}")

    %{basis: xbasis} = Axis.Units.Numeric.units_for(x_a, x_b, @config)
    assert xbasis == 200.0
  end

  test "range 200 " do
    x_a = 40.123
    x_b = 1930.45

    # units = Axis.Units.Numeric.units_for(x_a, x_b, @config)
    # Logger.warn("units: #{inspect units}")

    nscale = Axis.Units.scale(%{@config | ticks: 10}, %ViewRange{start: x_a, stop: x_b})

    xrange = nscale[:data] |> Enum.take(50)
    # Logger.warn("number scale range: #{inspect(Enum.take(xrange, 50))}")
    scale = [0.0, 200.0, 400.0, 600.0, 800.0, 1.0e3, 1.2e3, 1.4e3, 1.6e3, 1.8e3, 2.0e3]

    assert scale == xrange
  end

  test "range 200 negative offset " do
    x_a = -110.123
    x_b = 1930.45

    nscale = Axis.Units.scale(%{@config | ticks: 10}, %ViewRange{start: x_a, stop: x_b})

    xrange = nscale[:data] |> Enum.take(50)
    # Logger.warn("number scale range: #{inspect(Enum.take(xrange, 50))}")
    scale = [-200.0, 0.0, 200.0, 400.0, 600.0, 800.0, 1.0e3, 1.2e3, 1.4e3, 1.6e3, 1.8e3, 2.0e3]

    assert scale == xrange
  end

  test "range 2 offset " do
    x_a = 11.34
    x_b = 28.47

    nscale = Axis.Units.scale(%{@config | ticks: 10}, %ViewRange{start: x_a, stop: x_b})

    xrange = nscale[:data] |> Enum.take(50)
    # Logger.warn("number scale range: #{inspect(Enum.take(xrange, 50))}")
    scale = [10.0, 12.0, 14.0, 16.0, 18.0, 20.0, 22.0, 24.0, 26.0, 28.0, 30.0]

    assert scale == xrange
  end

  test "range 2 negative offset " do
    x_a = -28.47
    x_b = -11.34

    nscale = Axis.Units.scale(%{@config | ticks: 10}, %ViewRange{start: x_a, stop: x_b})

    xrange = nscale[:data] |> Enum.take(50)
    # Logger.warn("number scale range: #{inspect(Enum.take(xrange, 50))}")
    scale = [-30.0, -28.0, -26.0, -24.0, -22.0, -20.0, -18.0, -16.0, -14.0, -12.0, -10.0]

    assert scale == xrange
  end
end
