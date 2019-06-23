defmodule Plotex.Output.Options.Item do

  defstruct size: 2.0,
            offset: 1.0,
            rotate: 0.0
end

defmodule Plotex.Output.Options.Axis do
  alias Plotex.Output.Options

  defstruct ticks: %Options.Item{},
            label: %Options.Item{rotate: 0.0, offset: 1.5, size: nil},
            format: nil
end

defmodule Plotex.Output.Options.Data do
  alias Plotex.Output.Options

  defstruct shape: :circle,
            width: 1.5,
            height: 1.5
end

defprotocol Plotex.Output.Options.Formmater do
  @doc "Formats a value"
  def func(axis, opts)
end

defmodule Plotex.Output.Options.NumericFormatter do
  defstruct precision: 8, decimals: 2
end
defimpl Plotex.Output.Options.Formmater, for: Plotex.Output.Options.NumberFormat do
  alias Plotex.Output.Options

  def func(%Plotex.Axis{kind: :numeric} = _axis, opts) do
    fn v ->
      :io_lib.format("~#{opts.precision}.#{opts.decimals}f", [v])
    end
  end
end

defmodule Plotex.Output.Options.DateTimeFormatter do
  defstruct [ :year, :month, :day, :hour, :minute, :second, :millisecond ]
end
defimpl Plotex.Output.Options.Formmater, for: Plotex.Output.Options.DateTimeFormat do
  def func(%Plotex.Axis{kind: :datetime, basis: basis} = _axis, opts) do
    fn v ->
      epoch = TimeUnits.display_epoch(basis.order)

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
              Calendar.Strftime.strftime(opts.second || "%H:%M:%S")
            else
              {:ok, ViewRange.vals(v, :microsecond)}
            end
        end

      result
    end
  end
end


defmodule Plotex.Output.Options do
  alias Plotex.Output.Options

  defstruct xaxis: %Options.Axis{},
            yaxis: %Options.Axis{},
            width: 100,
            heights: 100,
            data: %{},
            default_data: %Options.Data{}

  def data(%Plotex.Output.Options{} = opts, idx) do
    opts.data[idx] || opts.default_data
  end

  def formatter(%Plotex.Axis{} = axis, formatter) do
    if formatter do
      formatter
    else
      case axis.kind do
        :numeric ->
          %Options.NumericFormatter{}
        :datetime ->
          %Options.DateTimeFormatter{}
      end
    end
  end
end
