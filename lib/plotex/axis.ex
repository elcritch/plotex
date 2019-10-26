
defmodule Plotex.Axis do
  alias Plotex.ViewRange
  alias __MODULE__

  defstruct limits: %ViewRange{},
            view: %ViewRange{},
            name: "",
            basis: %{},
            ticks: 10,
            units: %{}

  @type t :: %Plotex.Axis{
    limits: ViewRange.t(),
    view: ViewRange.t(),
    name: String.t(),
    basis: map(),
    ticks: non_neg_integer(),
    units: Plotex.Axis.Units,
  }

end
