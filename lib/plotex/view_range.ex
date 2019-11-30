defmodule Plotex.ViewRange do
  alias __MODULE__

  @unix_epoch ~N[1970-01-01 00:00:00]

  defstruct start: 10,
            stop: 90,
            projection: :cartesian

  @type t :: %Plotex.ViewRange{start: number(), stop: number(), projection: :cartesian | :polar }

  def new({a,b}, proj \\ :cartesian) do
    %ViewRange{start: a, stop: b, projection: proj}
  end

  def empty(proj \\ :cartesian) do
    %ViewRange{start: nil, stop: nil, projection: proj}
  end

  @doc """
  Find the maximum and minumun points for a given line of data.
  """
  def from(data, proj \\ :cartesian) do
    unless Enum.count(data) == 0 do
      {a, b} = Enum.min_max_by(data, &Plotex.ViewRange.convert/1)
      %ViewRange{start: a, stop: b, projection: proj}
    else
      %ViewRange{start: nil, stop: nil, projection: proj}
    end
  end

  def min_max(%{start: nil, stop: nil}, b), do: b
  def min_max(a, %{start: nil, stop: nil}), do: a
  def min_max(va, vb) do
    start! = Enum.min_by([va.start, vb.start], &convert/1)
    stop! = Enum.max_by([va.stop, vb.stop], &convert/1)

    %ViewRange{start: start!, stop: stop!, projection: va.projection}
  end

  def convert(nil), do: nil
  def convert(%Time{} = val), do: Time.to_erl(val)
  def convert(%Date{} = val), do: Date.to_erl(val)
  def convert(%DateTime{} = val), do: DateTime.to_unix(val, :nanosecond)
  def convert(%NaiveDateTime{} = a), do: NaiveDateTime.diff(a, @unix_epoch, :nanosecond)
  def convert(val) when is_number(val), do: val

  def to_val(a, units \\ :nanosecond), do: vals(a, units)
  def vals(%DateTime{} = a, units), do: DateTime.to_unix(a, units)
  def vals(%NaiveDateTime{} = a, units), do: NaiveDateTime.diff(a, @unix_epoch, units)
  def vals(a, _units), do: a

  def diff(%DateTime{} = b, %DateTime{} = a), do: DateTime.diff(b, a, :nanosecond)
  def diff(%NaiveDateTime{} = b, %NaiveDateTime{} = a), do: NaiveDateTime.diff(b, a, :nanosecond)
  def diff(b, a), do: b - a

  def pad(%ViewRange{start: start, stop: stop, projection: proj}, opts)
              when is_nil(start) or is_nil(stop) do
    %ViewRange{start: nil, stop: nil, projection: proj}
  end
  def pad(%ViewRange{start: %DateTime{} = start, stop: %DateTime{} = stop} = vr, opts) do
    amount = Keywords.get(opts, :padding, 0.05) * ViewRange.dist(vr)
    %ViewRange{start: start |> DateTime.add(-round(amount), :nanosecond),
               stop: stop |> DateTime.add(round(amount), :nanosecond)}
  end
  def pad(%ViewRange{start: %NaiveDateTime{} = start, stop: %NaiveDateTime{} = stop} = vr, opts) do
    amount = Keywords.get(opts, :padding, 0.05) * ViewRange.dist(vr)
    %ViewRange{start: start |> NaiveDateTime.add(-round(amount), :nanosecond),
               stop: stop |> NaiveDateTime.add(round(amount), :nanosecond)}
  end
  def pad(%ViewRange{start: start, stop: stop, projection: proj} = vr, opts) do
    amount = Keywords.get(opts, :padding, 0.05) * ViewRange.dist(vr)
    %ViewRange{start: start - amount, stop: stop + amount, projection: proj}
  end

  def dist({start, stop}) when is_nil(start) or is_nil(stop) do
    1.0
  end

  @type datetime :: DateTime.t() | NaiveDateTime.t()

  @spec dist( { datetime(), datetime() } | {nil, nil} | ViewRange.t() ) :: number
  def dist({%{} = start, %{} = stop}) do
    diff = to_val(stop) - to_val(start)
    if diff != 0 do
      diff
    else
      1_000_000_000
    end
  end

  def dist({start, stop}) do
    if stop != start do
      stop - start
    else
      1.0
    end
  end

  def dist(%ViewRange{} = range) do
    dist({range.start, range.stop})
  end

end
