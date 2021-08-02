defmodule Plotex.Axis do
  alias Plotex.ViewRange

  defstruct kind: nil,
            limits: %ViewRange{},
            view: %ViewRange{},
            name: "",
            basis: %{},
            units: nil,
            formatter: nil

  @type t :: %Plotex.Axis{
          kind: atom(),
          limits: ViewRange.t(),
          view: ViewRange.t(),
          name: String.t(),
          basis: map(),
          units: Plotex.Axis.Units
        }
end
