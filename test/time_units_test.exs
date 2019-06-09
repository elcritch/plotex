defmodule PlotEx.TimeUnitsTest do
  use ExUnit.Case
  doctest PlotEx
  require Logger

  test "a first b after" do
    dt_a = DateTime.from_iso8601("2019-05-20T05:00:00.836Z") |> elem(1)
    dt_b = DateTime.from_iso8601("2019-05-20T05:05:00.836Z") |> elem(1)

    %{basis_name: unit_name, val: unit_val, order: _unit_ord, diff: delta} =
      PlotEx.TimeUnits.units_for(dt_a, dt_b, ticks: 3)

    assert delta == 300
    assert unit_name == :minute
    assert unit_val == 60
  end

  test "a after b first" do
    dt_a = DateTime.from_iso8601("2019-05-20T05:05:00.836Z") |> elem(1)
    dt_b = DateTime.from_iso8601("2019-05-20T05:00:00.836Z") |> elem(1)

    %{basis_name: unit_name, val: unit_val, order: _unit_ord, diff: delta} = PlotEx.TimeUnits.units_for(dt_a, dt_b, ticks: 3)
    assert delta == 300
    assert unit_name == :minute
    assert unit_val == 60
  end

  test "time scale" do
    dt_a = DateTime.from_iso8601("2019-05-20T05:04:10.836Z") |> elem(1)
    dt_b = DateTime.from_iso8601("2019-05-20T05:15:00.836Z") |> elem(1)

    scale = PlotEx.TimeUnits.time_scale(dt_a, dt_b, [])

    scale! = scale[:data] |> Enum.take(30)

    # for i <- scale! do Logger.warn("#{inspect(i)}") end

    assert length(scale!) == 12
  end

  test "time scale with 4 ticks " do
    dt_a = DateTime.from_iso8601("2019-05-20T05:04:10.836Z") |> elem(1)
    dt_b = DateTime.from_iso8601("2019-05-20T05:15:00.836Z") |> elem(1)

    scale = PlotEx.TimeUnits.time_scale(dt_a, dt_b, ticks: 4)
    scale! = scale[:data] |> Enum.take(30)

    # for i <- scale! do Logger.warn("#{inspect(i)}") end

    assert length(scale!) == 4
  end

  test "hour time scale" do
    dt_a = DateTime.from_iso8601("2019-05-20T05:04:10.836Z") |> elem(1)
    dt_b = DateTime.from_iso8601("2019-05-20T08:15:00.836Z") |> elem(1)

    scale = PlotEx.TimeUnits.time_scale(dt_a, dt_b, [])

    scale! = scale[:data] |> Enum.take(30)

    # for i <- scale! do
      # Logger.warn("#{inspect(i)}")
    # end

    assert length(scale!) == 14
  end
end
