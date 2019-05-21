defmodule Plotter.NumberUnitsTest do
  use ExUnit.Case
  doctest Plotter
  require Logger

  test "base-10 rank for numbers" do
    ranks =
      [1000, 120.2, 53.9, 13.1, 8.9, 0.98, 0.0396]
      |> Enum.map(&Plotter.NumberUnits.rank(&1, 10))

    assert ranks == [1, 0, 0, 0, -1, -2, -3]
  end

  test "basis 1.0 " do
    x_a = 1.123
    x_b = 13.45

    %{basis: xbasis} = Plotter.NumberUnits.units_for(x_a, x_b)
    assert xbasis == 1.0
  end

  test "basis 0.05 " do
    x_a = 1.123
    x_b = 1.52

    %{basis: xbasis} = Plotter.NumberUnits.units_for(x_a, x_b)
    assert xbasis == 0.05
  end

  test "basis 10 " do
    x_a = 1.123
    x_b = 130.45

    %{basis: xbasis} = Plotter.NumberUnits.units_for(x_a, x_b)
    assert xbasis == 10.0
  end

  test "basis 50 " do
    x_a = 1.123
    x_b = 530.45

    # units = Plotter.NumberUnits.units_for(x_a, x_b)
    # Logger.warn("units: #{inspect units}")

    %{basis: xbasis} = Plotter.NumberUnits.units_for(x_a, x_b)
    assert xbasis == 50.0
  end

  test "decade 100 " do
    x_a = 1.123
    x_b = 930.45

    # units = Plotter.NumberUnits.units_for(x_a, x_b)
    # Logger.warn("units: #{inspect units}")

    %{basis: xbasis} = Plotter.NumberUnits.units_for(x_a, x_b)
    assert xbasis == 100.0
  end

  test "decade 200 " do
    x_a = 1.123
    x_b = 1930.45

    # units = Plotter.NumberUnits.units_for(x_a, x_b)
    # Logger.warn("units: #{inspect units}")

    %{basis: xbasis} = Plotter.NumberUnits.units_for(x_a, x_b)
    assert xbasis == 200.0
  end

  test "range 200 " do
    x_a = 40.123
    x_b = 1930.45

    # units = Plotter.NumberUnits.units_for(x_a, x_b)
    # Logger.warn("units: #{inspect units}")

    xrange =
      Plotter.NumberUnits.number_scale(x_a, x_b, ticks: 10)
      |> Enum.take(50)

    # Logger.warn("number scale range: #{inspect(Enum.take(xrange, 50))}")
    scale = [0.0, 200.0, 400.0, 600.0, 800.0, 1.0e3, 1.2e3, 1.4e3, 1.6e3, 1.8e3, 2.0e3]

    assert scale == xrange
  end

  test "range 200 negative offset " do
    x_a = -110.123
    x_b = 1930.45

    xrange =
      Plotter.NumberUnits.number_scale(x_a, x_b, ticks: 10)
      |> Enum.take(50)

    # Logger.warn("number scale range: #{inspect(Enum.take(xrange, 50))}")
    scale = [-200.0, 0.0, 200.0, 400.0, 600.0, 800.0, 1.0e3, 1.2e3, 1.4e3, 1.6e3, 1.8e3, 2.0e3]

    assert scale == xrange
  end
end
