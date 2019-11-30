
defmodule Plotex.Output.Formatter.DateTime.Cldr do
  defstruct [ :basis, :year, :month, :day, :hour, :minute, :second, :millisecond ]
end

defimpl Plotex.Output.Formatter, for: Plotex.Output.Formatter.DateTime.Cldr do
  alias Plotex.Axis.Units
  alias Plotex.ViewRange

  def output(opts, axis, v) do
    # fn v ->
      # epoch = nil
      epoch = Units.Time.display_epoch(axis.basis.order)

      {:ok, result} =
        case epoch do
          :year ->
            v |> Cldr.DateTime.to_string(format: "Y/M")
          :month ->
            v |> Cldr.DateTime.to_string(format: "Y/M/d")
          :day ->
            v |> Cldr.DateTime.to_string(format: "M/d HH")
          :hour ->
            v |> Cldr.DateTime.to_string(format: "d H:mm")
          :minute ->
            v |> Cldr.DateTime.to_string(format: "H:mm:ss")
          :second ->
            v |> Cldr.DateTime.to_string(format: "H:mm:ss")
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

defmodule Plotex.Cldr do
  use Cldr, locales: ["en"], providers: [Cldr.Number, Cldr.Calendar, Cldr.DateTime]
end
