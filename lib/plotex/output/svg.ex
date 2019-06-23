defmodule Plotex.Output.Svg do
  require Logger
  alias Plotex.TimeUnits
  alias Plotex.ViewRange

  use Phoenix.HTML

  def formatter(%Plotex.Axis{kind: :numeric} = _axis, opts) do
    opts[:format] || fn v -> :io_lib.format("~8.2f", [v]) end
  end

  def formatter(%Plotex.Axis{kind: :datetime, basis: basis} = axis, opts) do
    years =

    # Logger.info("formatter: axis: #{inspect axis} ")

    opts[:format] || fn v ->
      epoch = TimeUnits.display_epoch(basis.order)

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
            {:ok, ViewRange.vals(v, :microsecond)}
        end

      result
    end
  end

  def default_css() do
    """
        .plx-graph .plx-labels .plx-x-labels {
          text-anchor: middle;
        }
        .plx-graph .plx-labels, .plx-graph .plx-y-labels {
          text-anchor: middle;
        }
        .plx-graph {
          height: 500px;
          width: 800px;
        }
        .plx-graph .plx-grid {
          stroke: #ccc;
          stroke-dasharray: 0;
          stroke-width: 1.plx-0;
        }
        .plx-labels {
          font-size: 3px;
        }
        .plx-labels .plx-x-labels {
          font-size: 1px;
        }
        .plx-label-title {
          font-size: 8px;
          font-weight: bold;
          text-transform: uppercase;
          fill: black;
        }
        .plx-data .plx-data-point {
          fill: darkblue;
          stroke-width: 1.plx-0;
        }
        .plx-data .plx-data-line {
          stroke: #0074d9;
          stroke-width: 0.plx-1em;
          stroke-width: 0.plx-1em;
          stroke-linecap: round;
          fill: none;
        }
    """
  end

  @doc """
  Primary function to generate SVG plots from a given Plotex structure. The SVG can be
  styled using standard CSS. Options include ability to set the tick rotation and offset.

  The overall SVG structure and CSS classes that can be used to style the SVG graph are:

  ```sass
  .plx-graph
    .plx-title
    .plx-label-title
    .plx-labels
      .plx-x-labels
      .plx-y-labels
    .plx-grid
    .plx-data
      .plx-dataset-<n>
        .plx-data-point
        .plx-data-line
  ```

  The generated SVG includes both a ployline connecting each dataset, and also either
  datapoints as either `rect` or `circle` type via `opts.data.type = :rect | :circle`.

  """
  def generate(%Plotex{} = plot, opts \\ []) do

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
             viewbox="0 -100 <%= opts[:width] || 100 %> <%= opts[:height] || 100 %>"
             preserveAspectRatio="none"
             class="plx-graph" version="1.2" >
        <title class="plx-title"> <%= @config.title %> </title>

        <!-- X Axis -->
        <g class="plx-grid plx-x-grid plx-border">
          <line x1="<%= @config.xaxis.view.start %>"
                x2="<%= @config.xaxis.view.stop %>"
                y1="-<%= @config.yaxis.view.start %>"
                y2="-<%= @config.yaxis.view.start %>" >
          </line>

        </g>
        <g class="plx-labels plx-x-labels">
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
        <g class="plx-grid plx-y-grid">
          <line x1="<%= @config.xaxis.view.start %>"
                x2="<%= @config.xaxis.view.start %>"
                y1="-<%= @config.yaxis.view.start %>"
                y2="-<%= @config.yaxis.view.stop %>" >
          </line>

        </g>
        <g class="plx-labels plx-y-labels">
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
        <g class="plx-data">
        <%= for {dataset, idx} <- @datasets do %>
          <g class="plx-dataset-<%= idx %>" data-setname="plx-data-<%= idx %>">
            <polyline class="plx-data-line"
                      points="
                        <%= for {{_xl, xp}, {_yl, yp}} <- dataset do %>
                          <%= xp %>,-<%= yp %>
                        <% end %>
                        "/>

            <%= for {{xl, xp}, {yl, yp}} <- dataset do %>
              <%= case @opts[:data][:type] do %>
              <% :circle -> %>
                <circle class="plx-data-point "
                        cx="<%= xp %>"
                        cy="-<%= yp %>"
                        r="<%= (@opts[:data][:size] || @ds)/2.0 %>"
                        data-x-value="<%= xl %>"
                        data-y-value="<%= yl %>"
                        ></circle>
              <% _rect_default -> %>
                <rect class="plx-data-point "
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
