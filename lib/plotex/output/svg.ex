defmodule Plotex.Output.Svg do
  require Logger
  alias Plotex.TimeUnits
  alias Plotex.ViewRange
  alias Plotex.Output.Options
  alias Plotex.Output.Formatter

  use Phoenix.HTML

  @doc """
  Default example CSS Styling.
  """
  def default_css() do
    """
        .plx-labels {
          text-anchor: middle;
          dominant-baseline: central;
        }
        .plx-graph {
          height: 500px;
          width: 800px;
        }
        .plx-graph .plx-grid {
          stroke: #ccc;
          stroke-dasharray: 0;
          stroke-width: 1.0;
        }
        .plx-grid-lines {
          stroke-width: 0.1;
        }
        .plx-ticks {
          stroke: #ccc;
          stroke-dasharray: 0;
          stroke-width: 0.5;
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
          stroke-width: 1.0;
        }
        .plx-data .plx-data-line {
          stroke: #0074d9;
          stroke-width: 0.05em;
          stroke-width: 0.05em;
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
  def generate(%Plotex{} = plot, %Options{} = opts) do

    xfmt = Options.formatter(plot.config.xaxis, opts.xaxis.format)
    yfmt = Options.formatter(plot.config.yaxis, opts.yaxis.format)

    assigns =
      plot
      |> Map.from_struct()
      |> Map.put(:opts, opts)
      |> Map.put(:ds, 1.5)

    ~E"""
        <svg version="1.2" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"
             viewbox="0 -100 <%= @opts.width %> <%= @opts.height %>"
            <%= for {attr, val} <- @opts.svg_attrs do %> <%= raw ~s{#{attr}="#{val}"} %> <% end %> >
          <title class="plx-title"><%= @config.title %></title>

          <%= for item <- @opts.custom_svg do %>
            <%= item %>
          <% end %>

        <!-- X Axis -->
        <g class="plx-grid plx-x-axis ">
          <g class="plx-border">
            <line x1="<%= @config.xaxis.view.start %>"
                  x2="<%= @config.xaxis.view.stop %>"
                  y1="-<%= @config.yaxis.view.start %>"
                  y2="-<%= @config.yaxis.view.start %>" >
            </line>
          </g>

          <g class="plx-ticks">
            <%= for {_xl, xp} <- @xticks do %>
              <line
                    x1="<%= xp %>"
                    y1="-<%= @config.yaxis.view.start %>"
                    x2="<%= xp %>"
                    y2="-<%= @config.yaxis.view.start + @opts.xaxis.ticks.size %>"
                    >
              </line>
            <% end %>
          </g>
          <g class="plx-grid-lines">
            <%= for {_xl, xp} <- @xticks do %>
              <line
                    x1="<%= xp %>"
                    y1="-<%= @config.yaxis.view.start %>"
                    x2="<%= xp %>"
                    y2="-<%= @config.yaxis.view.stop %>"
                    >
              </line>
            <% end %>
          </g>
        </g>

        <g class="plx-labels plx-x-labels">
          <%= for {xl, xp} <- @xticks do %>
            <text x="<%= xp %>"
                  y="-<%= @config.yaxis.view.start %>"
                  transform="rotate(<%= @opts.xaxis.label.rotate %>, <%= xp %>, -<%= @config.yaxis.view.start - @opts.xaxis.label.offset %>)"
                  dy="<%= @opts.xaxis.label.offset %>">
                <%= Formatter.calc(xfmt, xl) %>
            </text>
          <% end %>
          <text x="<%= (@config.xaxis.view.stop - @config.xaxis.view.start)/2.0 %>"
                y="-<%= @config.yaxis.view.start/2.0  %>"
                class="label-title">
            <%= @config.xaxis.name %>
          </text>
        </g>

        <!-- Y Axis -->
        <g class="plx-grid plx-y-axis">
          <g class="plx-border">
            <line x1="<%= @config.xaxis.view.start %>"
                  x2="<%= @config.xaxis.view.start %>"
                  y1="-<%= @config.yaxis.view.start %>"
                  y2="-<%= @config.yaxis.view.stop %>" >
            </line>
          </g>

          <g class="plx-ticks">
            <%= for {_yl, yp} <- @yticks do %>
              <line
                    x1="<%= @config.xaxis.view.start %>"
                    y1="-<%= yp %>"
                    x2="<%= @config.xaxis.view.start + @opts.yaxis.ticks.size %>"
                    y2="-<%= yp %>"
                    >
              </line>
            <% end %>
          </g>
          <g class="plx-grid-lines">
            <%= for {_yl, yp} <- @yticks do %>
              <line
                    x1="<%= @config.xaxis.view.start %>"
                    y1="-<%= yp %>"
                    x2="<%= @config.xaxis.view.stop %>"
                    y2="-<%= yp %>"
                    >
              </line>
            <% end %>
          </g>
        </g>
        <g class="plx-labels plx-y-labels">
          <%= for {yl, yp} <- @yticks do %>
            <text y="-<%= yp %>"
                  x="<%= @config.xaxis.view.start %>"
                  transform="rotate(<%= @opts.yaxis.label.rotate %>, <%= @config.xaxis.view.start - @opts.yaxis.label.offset %>, -<%= yp %>)"
                  dx="-<%= @opts.yaxis.label.offset %>">
                <%= Formatter.calc(yfmt, yl) %>
              </text>
          <% end %>
          <text y="-<%= (@config.yaxis.view.stop - @config.yaxis.view.start)/2.0 %>"
                x="<%= @config.xaxis.view.start/2.0 %>"
                class="label-title">
            <%= @config.yaxis.name %>
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
              <%= case Options.data(@opts,idx).shape do %>
              <% :circle -> %>
                <circle class="plx-data-point "
                        cx="<%= xp %>"
                        cy="-<%= yp %>"
                        r="<%= Options.data(@opts, idx).width / 2.0 %>"
                        data-x-value="<%= xl %>"
                        data-y-value="<%= yl %>"
                        ></circle>
              <% _rect_default -> %>
                <rect class="plx-data-point "
                      x="<%= xp - Options.data(@opts, idx).width / 2  %>"
                      y="<%= yp - Options.data(@opts, idx).height / 2  %>"
                      data-x-value="<%= xl %>"
                      data-y-value="<%= yl %>"
                      width="<%= Options.data(@opts, idx).width %>"
                      height="<%= Options.data(@opts, idx).height %>"
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
