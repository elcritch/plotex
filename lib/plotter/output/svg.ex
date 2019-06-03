defmodule Plotter.Output.Svg do
  require Logger
  alias Plotter.TimeUnits

  use Phoenix.HTML

  def formatter(%Plotter.Axis{kind: :numeric} = _axis, opts) do
    opts[:format] || fn v -> :io_lib.format("~5.2f", [v]) end
  end

  def formatter(%Plotter.Axis{kind: :datetime, basis: basis} = axis, opts) do
    years =

    Logger.error("formatter: axis: #{inspect axis} ")

    opts[:format] || fn v ->
      epoch = TimeUnits.display_epoch(basis.order)
      Logger.error("EPOCH: #{inspect epoch}")

      {:ok, result} =
        case epoch do
          :year ->
            v |> Calendar.Strftime.strftime("%Y/%m/%d")
          :month ->
            v |> Calendar.Strftime.strftime("%y/%m/%d")
          :day ->
            v |> Calendar.Strftime.strftime("%m/%d %H")
          :hour ->
            v |> Calendar.Strftime.strftime("%d %H:%M")
          :minute ->
            v |> Calendar.Strftime.strftime("%H:%M:%S")
          :second ->
            v |> Calendar.Strftime.strftime("%H:%M:%S")
          :millisecond ->
            {:ok, v |> DateTime.to_unix(:microsecond)}
        end

      result
    end
  end

  def generate(%Plotter{} = plot, opts \\ []) do

    xfmt = formatter(plot.config.xaxis, opts[:xaxis])
    yfmt = formatter(plot.config.yaxis, opts[:yaxis])

    # xfmt = fn v -> :io_lib.format(v |> IO.inspect(label: :XFMT)) end
    # yfmt = fn v -> :io_lib.format(v |> IO.inspect(label: :YFMT)) end

    assigns =
      plot
      |> Map.from_struct()
      |> Map.put(:opts, opts)
      |> Map.put(:ds, 1.5)

    ~E"""
        <svg version="1.2" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"
             viewbox="0 -100 100 100"
             class="graph" version="1.2" >
        <title id="title"> <%= @config.title %> </title>

        <!-- X Axis -->
        <g class="grid x-grid">
          <line x1="<%= @config.xaxis.view.start %>"
                x2="<%= @config.xaxis.view.stop %>"
                y1="-<%= @config.yaxis.view.start %>"
                y2="-<%= @config.yaxis.view.start %>" >
          </line>

        </g>
        <g class="labels x-labels">
          <%= for {xl, xp} <- @xticks do %>
            <text x="<%= xp %>"
                  y="-<%= @config.yaxis.view.start %>"
                  transform="rotate(<%= @opts[:xaxis][:rotate] || 0 %>, <%= xp %>, -<%= @config.yaxis.view.start %>)"
                  dy="<%= @opts[:xaxis][:dy] || '1.5em' %>">

              <%= xfmt.(xl) %>
            </text>
          <% end %>
          <text x="<%= (@config.xaxis.view.stop - @config.xaxis.view.start)/2.0 %>"
                y="-<%= @config.yaxis.view.start/2.0  %>"
                class="label-title">
            <%= @config.xaxis.name %>
          </text>
        </g>

        <!-- Y Axis -->
        <g class="grid y-grid">
          <line x1="<%= @config.xaxis.view.start %>"
                x2="<%= @config.xaxis.view.start %>"
                y1="-<%= @config.yaxis.view.start %>"
                y2="-<%= @config.yaxis.view.stop %>" >
          </line>

        </g>
        <g class="labels y-labels">
          <%= for {yl, yp} <- @yticks do %>
            <text y="-<%= yp %>"
                  x="<%= @config.xaxis.view.start %>"
                  transform="rotate(<%= @opts[:yaxis][:rotate] || 0 %>, <%= @config.xaxis.view.start %>, -<%= yp %>)"
                  dx="-<%= @opts[:yaxis][:dy] || '1.5em' %>">
              <%= yfmt.(yl) %>
              </text>
          <% end %>
          <text y="-<%= (@config.yaxis.view.stop - @config.yaxis.view.start)/2.0 %>"
                x="<%= @config.xaxis.view.start/2.0 %>"
                class="label-title">
            <%= @config.xaxis.name %>
          </text>
        </g>

        <!-- Data -->
        <g class="data">
        <%= for {dataset, idx} <- @datasets do %>
          <g class="dataset-<%= idx %>" data-setname="data-<%= idx %>">
            <polyline class="data-line"
                      points="
                        <%= for {{_xl, xp}, {_yl, yp}} <- dataset do %>
                          <%= xp %>,-<%= yp %>
                        <% end %>
                        "/>

            <%= for {{xl, xp}, {yl, yp}} <- dataset do %>
              <%= case @opts[:data][:type] do %>
              <% :circle -> %>
                <circle class="data-point "
                        cx="<%= xp %>"
                        cy="-<%= yp %>"
                        r="<%= (@opts[:data][:size] || @ds)/2.0 %>"
                        data-x-value="<%= xl %>"
                        data-y-value="<%= yl %>"
                        ></circle>
              <% _rect_default -> %>
                <rect class="data-point "
                      x="<%= xp - (@opts[:data][:size] || @ds)/2  %>"
                      y="-<%= yp + (@opts[:data][:size] || @ds)/2  %>"
                      data-x-value="<%= xl %>"
                      data-y-value="<%= yl %>"
                      width="<%= @opts[:data][:size] || @ds %>"
                      height="<%= @opts[:data][:size] || @ds %>"
                      ></rect>
              <% end %>
            <% end %>
          </g>
        <% end %>
        </g>
      </svg>


      """
  end
end
