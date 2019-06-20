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

  def val(%DateTime{} = a), do: DateTime.to_unix(a, :nanosecond)
  def val(%NaiveDateTime{} = a), do: NaiveDateTime.diff(a, @unix_epoch, :nanosecond)
  def val(a), do: a

  def diff(%DateTime{} = b, %DateTime{} = a), do: DateTime.diff(b, a, :nanosecond)
  def diff(%NaiveDateTime{} = b, %NaiveDateTime{} = a), do: NaiveDateTime.diff(b, a, :nanosecond)
  def diff(b, a), do: b - a

  @spec pad({DateTime.t(), DateTime.t()}, number) :: {DateTime.t(), DateTime.t()}
  def pad({%DateTime{} = start, %DateTime{} = stop}, amount) do
    {start |> DateTime.add(-round(amount), :nanosecond),
     stop |> DateTime.add(round(amount), :nanosecond)}
  end
  @spec pad({NaiveDateTime.t(), NaiveDateTime.t()}, number) :: {NaiveDateTime.t(), NaiveDateTime.t()}
  def pad({%NaiveDateTime{} = start, %NaiveDateTime{} = stop}, amount) do
    {start |> NaiveDateTime.add(-round(amount), :nanosecond),
     stop |> NaiveDateTime.add(round(amount), :nanosecond)}
  end

  def pad({start, stop}, _amount)  when is_nil(start) or is_nil(stop) do
    {nil, nil}
  end

  def pad({start, stop}, amount) do
    {start - amount, stop + amount}
  end

  def dist({start, stop}) when is_nil(start) or is_nil(stop) do
    1.0
  end

  @type datetime :: DateTime.t() | NaiveDateTime.t()

  @spec dist( { datetime(), datetime() } | {nil, nil} | ViewRange.t() ) :: number
  def dist({%{} = start, %{} = stop}) do
    diff = val(stop) - val(start)
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
