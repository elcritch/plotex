
defmodule PlotEx.Axis do
  alias PlotEx.ViewRange
  alias __MODULE__

  defstruct limits: %ViewRange{},
            view: %ViewRange{},
            name: "",
            basis: %{},
            ticks: 10,
            kind: :numeric

  @type t :: %PlotEx.Axis{
    limits: ViewRange.t(),
    view: ViewRange.t(),
    name: String.t(),
    basis: map(),
    ticks: non_neg_integer(),
    kind: :numeric | :datetime,
  }

end
