defmodule Plotter.TimeUnitsTest do
  use ExUnit.Case
  doctest Plotter

  test "a first b after" do
    dt_a = DateTime.from_iso8601("2019-05-20T05:00:00.836Z") |> elem(1)
    dt_b = DateTime.from_iso8601("2019-05-20T05:05:00.836Z") |> elem(1)

    assert Plotter.TimeUnits.units_for(dt_a, dt_b, ticks: 3) == {:minute, 60}
  end

  test "a after b first" do
    dt_a = DateTime.from_iso8601("2019-05-20T05:05:00.836Z") |> elem(1)
    dt_b = DateTime.from_iso8601("2019-05-20T05:00:00.836Z") |> elem(1)

    assert Plotter.TimeUnits.units_for(dt_a, dt_b, ticks: 3) == {:minute, 60}
  end
end
