defmodule Plotter.ViewRange do
  alias __MODULE__

  defstruct start: 10,
            stop: 90,
            projection: :cartesian

  @type t :: %Plotter.ViewRange{start: number(), stop: number(), projection: :cartesian | :polar }

  def new({a,b}, proj \\ :cartesian) do
    %ViewRange{start: a, stop: b, projection: proj}
  end

  def min_max(nil, b), do: b
  def min_max(a, nil), do: a
  def min_max(va, vb) do
    start! = Enum.min_by([va.start, vb.start], &convert/1)
    stop! = Enum.max_by([va.stop, vb.stop], &convert/1)

    %ViewRange{start: start!, stop: stop!, projection: va.projection}
  end

  def convert(%Time{} = val), do: Time.to_erl(val)
  def convert(%Date{} = val), do: Date.to_erl(val)
  def convert(%DateTime{} = val), do: DateTime.to_unix(val, :nanosecond)
  def convert(val) when is_number(val), do: val

  def pad({start, stop}, _amount)  when is_nil(start) or is_nil(stop) do
    {nil, nil}
  end

  def pad({start, stop}, amount) do
    {start - amount, stop + amount}
  end

  def dist({start, stop}) when is_nil(start) or is_nil(stop) do
    0.0
  end

  @spec dist( tuple() ) :: number
  def dist({start, stop}) do
    stop - start
  end

  @spec dist(Plotter.ViewRange.t()) :: number
  def dist(%ViewRange{} = range) do
    range.stop - range.start
  end

end
