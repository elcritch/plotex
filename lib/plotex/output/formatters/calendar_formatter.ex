defmodule Plotex.Output.Formatter.DateTime.Calendar do
  defstruct [:year, :month, :day, :hour, :minute, :second, :millisecond]
end

defimpl Plotex.Output.Formatter, for: Plotex.Output.Formatter.DateTime.Calendar do
  alias Plotex.Axis.Units
  alias Plotex.ViewRange
  require Logger

  def output(opts, axis, v) do
    # fn v ->
    # epoch = nil

    # Logger.debug("DateTime.Calendar: opts: #{inspect opts}")
    epoch = Units.Time.display_epoch(axis.basis.order)

    {:ok, result} =
      case epoch do
        :year ->
          v |> Calendar.Strftime.strftime(opts.year || "%Y/%m/%d")

        :month ->
          v |> Calendar.Strftime.strftime(opts.month || "%y/%m/%d")

        :day ->
          v |> Calendar.Strftime.strftime(opts.day || "%m/%d %H")

        :hour ->
          v |> Calendar.Strftime.strftime(opts.hour || "%d %H:%M")

        :minute ->
          v |> Calendar.Strftime.strftime(opts.minute || "%H:%M:%S")

        :second ->
          v |> Calendar.Strftime.strftime(opts.second || "%H:%M:%S")

        :millisecond ->
          if opts.millisecond do
            v |> Calendar.Strftime.strftime(opts.second || "%H:%M:%S")
          else
            {:ok, ViewRange.vals(v, :microsecond)}
          end

        :microsecond ->
          {:ok, ViewRange.vals(v, :microsecond)}
      end

    result
    # end
  end
end
