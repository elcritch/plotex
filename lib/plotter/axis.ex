
defmodule Plotter.Axis do
  alias Plotter.ViewRange
  alias __MODULE__

  defstruct limits: %ViewRange{},
            view: %ViewRange{},
            name: "",
            basis: %{},
            ticks: 10,
            kind: :numeric

  @type t :: %Plotter.Axis{
    limits: ViewRange.t(),
    view: ViewRange.t(),
    name: String.t(),
    basis: map(),
    ticks: non_neg_integer(),
    kind: :numeric | :datetime,
  }

end
