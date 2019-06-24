defmodule Plotex.Output.Options.Item do

  defstruct size: 2.0,
            offset: 5.0,
            rotate: 0.0
end

defmodule Plotex.Output.Options.Axis do
  alias Plotex.Output.Options

  defstruct ticks: %Options.Item{},
            label: %Options.Item{},
            format: nil
end

defmodule Plotex.Output.Options.Data do
  alias Plotex.Output.Options

  defstruct shape: :circle,
            width: 1.5,
            height: 1.5
end

defprotocol Plotex.Output.Options.Formatter do
  @doc "Formats a value"
  def calc(formatter, val)
end

defmodule Plotex.Output.Options.NumericFormatter do
  defstruct precision: 8, decimals: 2
end
defimpl Plotex.Output.Options.Formatter, for: Plotex.Output.Options.NumericFormatter do
  alias Plotex.Output.Options

  def calc(formatter, val) do
    # fn v ->
      :io_lib.format("~#{formatter.precision}.#{formatter.decimals}f", [val])
    # end
  end
end

defmodule Plotex.Output.Options.DateTimeFormatter do
  defstruct [ :basis, :year, :month, :day, :hour, :minute, :second, :millisecond ]
end
defimpl Plotex.Output.Options.Formatter, for: Plotex.Output.Options.DateTimeFormatter do
  alias Plotex.TimeUnits
  alias Plotex.ViewRange

  def calc(opts, v) do
    # fn v ->
      # epoch = nil
      epoch = TimeUnits.display_epoch(opts.basis.order)

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
        end

      result
    # end
  end
end

defmodule Plotex.Output.Options do
  require Logger
  alias Plotex.Output.Options

  @default_svg_attrs %{
    :preserveAspectRatio => "none",
    :class => "plx-graph",
  }

  defstruct xaxis: %Options.Axis{ label: %Options.Item{ offset: 5.0 } },
            yaxis: %Options.Axis{ label: %Options.Item{ offset: 5.0 } },
            width: 100,
            height: 100,
            svg_attrs: @default_svg_attrs,
            custom_svg: [],
            data: %{},
            default_data: %Options.Data{}

  def data(%Plotex.Output.Options{} = opts, idx) do
    opts.data[idx] || opts.default_data
  end

  def formatter(%Plotex.Axis{} = axis, formatter) do
    # Logger.warn("formatter: #{inspect axis}")
    if formatter do
      formatter
    else
      case axis.kind do
        :numeric ->
          %Options.NumericFormatter{}
        :datetime ->
          %Options.DateTimeFormatter{basis: axis.basis}
      end
    end
  end

end
