
defprotocol Plotex.Output.Formatter do
  @doc "Formats a value"
  def calc(formatter, val)
end
