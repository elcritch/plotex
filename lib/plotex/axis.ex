
defmodule Plotex.Axis do
  alias Plotex.ViewRange

  defstruct limits: %ViewRange{},
            view: %ViewRange{},
            name: "",
            basis: %{},
            units: nil,
            formatter: nil

  @type t :: %Plotex.Axis{
    limits: ViewRange.t(),
    view: ViewRange.t(),
    name: String.t(),
    basis: map(),
    units: Plotex.Axis.Units,
  }

end
