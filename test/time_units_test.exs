defmodule Plotter.TimeUnitsTest do
  use ExUnit.Case
  doctest Plotter
  require Logger

  test "a first b after" do
    dt_a = DateTime.from_iso8601("2019-05-20T05:00:00.836Z") |> elem(1)
    dt_b = DateTime.from_iso8601("2019-05-20T05:05:00.836Z") |> elem(1)

    assert Plotter.TimeUnits.units_for(dt_a, dt_b, ticks: 3) == {300, :minute, 60}
  end

  test "a after b first" do
    dt_a = DateTime.from_iso8601("2019-05-20T05:05:00.836Z") |> elem(1)
    dt_b = DateTime.from_iso8601("2019-05-20T05:00:00.836Z") |> elem(1)

    assert Plotter.TimeUnits.units_for(dt_a, dt_b, ticks: 3) == {300, :minute, 60}
  end

  test "time scale" do
    dt_a = DateTime.from_iso8601("2019-05-20T05:04:10.836Z") |> elem(1)
    dt_b = DateTime.from_iso8601("2019-05-20T05:15:00.836Z") |> elem(1)

    scale = Plotter.TimeUnits.time_scale(dt_a, dt_b, [])

    scale! = scale |> Enum.take(30)

    for i <- scale! do
      Logger.warn("#{inspect(i)}")
    end
    assert length(scale!) == 12

  end

  test "time scale with 4 ticks " do
    dt_a = DateTime.from_iso8601("2019-05-20T05:04:10.836Z") |> elem(1)
    dt_b = DateTime.from_iso8601("2019-05-20T05:15:00.836Z") |> elem(1)

    scale = Plotter.TimeUnits.time_scale(dt_a, dt_b, ticks: 4)
    scale! = scale |> Enum.take(30)

    for i <- scale! do
      Logger.warn("#{inspect(i)}")
    end
    assert length(scale!) == 4

  end
end
