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
end
