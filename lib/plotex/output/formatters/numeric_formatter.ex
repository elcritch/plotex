
defmodule Plotex.Output.Formatter.NumericDefault do
  defstruct precision: 8, decimals: 2
end

defimpl Plotex.Output.Formatter, for: Plotex.Output.Formatter.NumericDefault do

  def output(formatter, axis, val) do
    # fn v ->
      :io_lib.format("~#{formatter.precision}.#{formatter.decimals}f", [val])
    # end
  end
end
