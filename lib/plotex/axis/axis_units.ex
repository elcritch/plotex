
defprotocol Plotex.Axis.Units do
  @doc "Generates a value scale from a given range "
  def scale(rng, opts)
end
