
defmodule Plotex.Output.Formatter.DateTime.Cldr do
  defstruct [ :basis, :year, :month, :day, :hour, :minute, :second, :millisecond ]
end

defimpl Plotex.Output.Formatter, for: Plotex.Output.Formatter.DateTime.Cldr do
  alias Plotex.Axis.Units
  alias Plotex.TimeUnits
  alias Plotex.ViewRange

  def output(opts, axis, v) do
    # fn v ->
      # epoch = nil
      epoch = Units.Time.display_epoch(axis.basis.order)

      {:ok, result} =
        case epoch do
          :year ->
            v |> Cldr.DateTime.to_string(format: "Y/m/d")
          :month ->
            v |> Cldr.DateTime.to_string(format: "y/m/d")
          :day ->
            v |> Cldr.DateTime.to_string(format: "m/d H")
          :hour ->
            v |> Cldr.DateTime.to_string(format: "d H:M")
          :minute ->
            v |> Cldr.DateTime.to_string(format: "H:M:S")
          :second ->
            v |> Cldr.DateTime.to_string(format: "H:M:S")
          :millisecond ->
            if opts.millisecond do
              v |> Cldr.DateTime.to_string(format: "A+")
            else
              {:ok, ViewRange.vals(v, :microsecond)}
            end
        end

      result
    # end
  end
end
