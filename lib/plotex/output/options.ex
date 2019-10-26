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

defmodule Plotex.Output.Options do
  require Logger
  alias Plotex.Output.Options
  alias Plotex.Output.Formatter

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
          %Formatter.NumericDefault{}
        :datetime ->
          %Formatter.DateTime.Calendar{basis: axis.basis}
        :cldr_default ->
          %Formatter.DateTime.Cldr{basis: axis.basis}
      end
    end
  end

end
