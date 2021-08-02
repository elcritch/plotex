defprotocol Plotex.Output.Formatter do
  @doc "Formats a value"
  def output(config, axis, val)
end
