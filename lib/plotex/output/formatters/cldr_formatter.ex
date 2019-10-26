
defmodule Plotex.Output.Formatter.DateTime.Cldr do
  defstruct [ :basis, :year, :month, :day, :hour, :minute, :second, :millisecond ]
end

defimpl Plotex.Output.Formatter, for: Plotex.Output.Formatter.DateTime.Cldr do
  alias Plotex.TimeUnits
  alias Plotex.ViewRange

  def calc(opts, v) do
    # fn v ->
      # epoch = nil
      epoch = TimeUnits.display_epoch(opts.basis.order)

      {:ok, result} =
        case epoch do
          :year ->
            v |> Calendar.Strftime.strftime(opts.year || "Y/m/d")
          :month ->
            v |> Calendar.Strftime.strftime(opts.month || "y/m/d")
          :day ->
            v |> Calendar.Strftime.strftime(opts.day || "m/d H")
          :hour ->
            v |> Calendar.Strftime.strftime(opts.hour || "d H:M")
          :minute ->
            v |> Calendar.Strftime.strftime(opts.minute || "H:M:S")
          :second ->
            v |> Calendar.Strftime.strftime(opts.second || "H:M:S")
          :millisecond ->
            if opts.millisecond do
              v |> Calendar.Strftime.strftime(opts.second || "H:M:S")
            else
              {:ok, ViewRange.vals(v, :microsecond)}
            end
        end

      result
    # end
  end
end
