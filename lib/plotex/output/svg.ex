defmodule Plotex.Output.Svg do
  require Logger
  alias Plotex.Output.Options
  alias Plotex.Output.Formatter

  use Phoenix.LiveComponent


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
          stroke-width: 1.0;
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
          fill: white;
        }
        .plx-labels .plx-x-labels {
          font-size: 1px;
        }
        .plx-label-title {
          font-size: 8px;
          font-weight: bold;
          text-transform: uppercase;
          fill: white;
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

  def generate(assigns) do
    render(assigns)
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
  attr :opts, Plotex.Output.Options, required: true
  attr :plot, Plotex, required: true
  attr :config, Plotex.Config, default: nil
  attr :svg_attrs, :global, default: %{ :preserveAspectRatio => "none", :class => "plx-graph" }
  slot :custom_svg

  # TODO:
  # attr :width, :float, default: 100.0
  # attr :height, :float, default: 100.0
  # attr :ds, :float, default: 1.5
  # attr :data, :map, default: %{}
  # attr :default_data, :map, default: %Options.Data{}


  def render(assigns) do

    assigns =
      assigns
      |> assign(:config, assigns[:config] || assigns.plot.config)
      |> assign(:xfmt, assigns.plot.config.xaxis.formatter)
      |> assign(:yfmt, assigns.plot.config.yaxis.formatter)
      |> assign(:datasets, assigns.plot.datasets |> Enum.to_list())
      |> assign_extras(:svg_attrs)

    ~H"""
      <svg version="1.2" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"
             viewbox={"0 -100 #{@opts.width} #{@opts.height} "}
              {@extras}
        >
        <title class="plx-title"><%= @config.title %></title>

        <%= render_slot(@custom_svg) %>

        <defs>
          <%= for {_dataset, idx} <- @datasets do %>

            <%= case Options.data(@opts,idx).shape do %>

              <% :circle -> %>
                <!-- simple dot marker definition -->
                <marker id={"marker-#{idx}"} viewBox={"0 0 #{2 * Options.data(@opts, idx).width } #{2 * Options.data(@opts, idx).width }"}
                        refX={Options.data(@opts, idx).width} refY={Options.data(@opts, idx).width}
                        markerWidth={Options.data(@opts, idx).width} markerHeight={Options.data(@opts, idx).width}>
                  <circle class="plx-data-point "
                          cx={Options.data(@opts, idx).width}
                          cy={Options.data(@opts, idx).width}
                          r={Options.data(@opts, idx).width}
                          />
                </marker>

              <% :arrow -> %>
                <!-- arrowhead marker definition -->
                <marker id={"marker-#{idx}"} viewBox={"0 0 #{2 * Options.data(@opts, idx).width} #{2 * Options.data(@opts, idx).height}"}
                        refX={Options.data(@opts, idx).width} refY={Options.data(@opts, idx).height}
                        markerWidth={Options.data(@opts, idx).width} markerHeight={Options.data(@opts, idx).height}
                        orient="auto-start-reverse">
                  <path d={"M 0 0 L #{ Options.data(@opts, idx).width} #{ Options.data(@opts, idx).width/2 } L 0 #{Options.data(@opts, idx).width } z"} />
                  <rect class="plx-data-point "
                          x={Options.data(@opts, idx).width}
                          y={Options.data(@opts, idx).height}
                          width={Options.data(@opts, idx).width}
                          height={Options.data(@opts, idx).height}
                          />
                </marker>

              <% _rect_default -> %>
                <!-- simple dot marker definition -->
                <marker id={"marker-#{idx}"} viewBox={"0 0 #{2 * Options.data(@opts, idx).width} {2 * Options.data(@opts, idx).height}"}
                        refX={Options.data(@opts, idx).width} refY={Options.data(@opts, idx).height}
                        markerWidth={Options.data(@opts, idx).width} markerHeight={Options.data(@opts, idx).height}>
                  <rect class="plx-data-point "
                          x={Options.data(@opts, idx).width/2}
                          y={Options.data(@opts, idx).height/2}
                          width={Options.data(@opts, idx).width}
                          height={Options.data(@opts, idx).height}
                          />
                </marker>
              <% end %>

            <% end %>
        </defs>

        <!-- X Axis -->
        <g class="plx-grid plx-x-axis ">
          <g class="plx-border">
            <line x1={@config.xaxis.view.start}
                  x2={@config.xaxis.view.stop}
                  y1={-1 * @config.yaxis.view.start}
                  y2={-1 * @config.yaxis.view.start} >
            </line>
          </g>

          <g class="plx-ticks">
            <%= for {_xl, xp} <- @plot.xticks do %>
              <line
                    x1={xp}
                    y1={-1 * @config.yaxis.view.start}
                    x2={xp}
                    y2={-1 * (@config.yaxis.view.start + @opts.xaxis.ticks.size)}
                    >
              </line>
            <% end %>
          </g>
          <g class="plx-grid-lines">
            <%= for {_xl, xp} <- @plot.xticks do %>
              <line
                    x1={xp}
                    y1={-1 * @config.yaxis.view.start}
                    x2={xp}
                    y2={-1 * @config.yaxis.view.stop}
                    >
              </line>
            <% end %>
          </g>
        </g>

        <g class="plx-labels plx-x-labels">
          <%= for {xl, xp} <- @plot.xticks do %>
            <text x={xp}
                  y={-1 * @config.yaxis.view.start}
                  transform={"rotate(#{ @opts.xaxis.label.rotate }, #{ xp }, -#{ @config.yaxis.view.start - @opts.xaxis.label.offset })"}
                  dy={@opts.xaxis.label.offset}>
                <%= Formatter.output(@xfmt, @config.xaxis, xl) %>
            </text>
          <% end %>
          <text x={(@config.xaxis.view.stop - @config.xaxis.view.start)/2.0}
                y={-1 * @config.yaxis.view.start/2.0 }
                class="label-title">
            <%= @config.xaxis.name %>
          </text>
        </g>

        <!-- Y Axis -->
        <g class="plx-grid plx-y-axis">
          <g class="plx-border">
            <line x1={@config.xaxis.view.start}
                  x2={@config.xaxis.view.start}
                  y1={-1 * @config.yaxis.view.start}
                  y2={-1 * @config.yaxis.view.stop} >
            </line>
          </g>

          <g class="plx-ticks">
            <%= for {_yl, yp} <- @plot.yticks do %>
              <line
                    x1={@config.xaxis.view.start}
                    y1={-1 * yp}
                    x2={@config.xaxis.view.start + @opts.yaxis.ticks.size}
                    y2={-1 * yp}
                    >
              </line>
            <% end %>
          </g>
          <g class="plx-grid-lines">
            <%= for {_yl, yp} <- @plot.yticks do %>
              <line
                    x1={@config.xaxis.view.start}
                    y1={-1 * yp}
                    x2={@config.xaxis.view.stop}
                    y2={-1 * yp}
                    >
              </line>
            <% end %>
          </g>
        </g>
        <g class="plx-labels plx-y-labels">
          <%= for {yl, yp} <- @plot.yticks do %>
            <text y={-1 * yp}
                  x={@config.xaxis.view.start}
                  transform={"rotate(#{ @opts.yaxis.label.rotate }, #{ @config.xaxis.view.start - @opts.yaxis.label.offset }, -#{ yp })"}
                  dx={-1 * @opts.yaxis.label.offset}>
                <%= Formatter.output(@yfmt, @config.yaxis, yl) %>
              </text>
          <% end %>
          <text y={-1 * (@config.yaxis.view.stop - @config.yaxis.view.start)/2.0}
                x={@config.xaxis.view.start/2.0}
                class="label-title">
            <%= @config.yaxis.name %>
          </text>
        </g>

        <!-- Data -->
        <g class="plx-data">
        <%= for {dataset, idx} <- @datasets do %>
          <g class={"plx-dataset-#{ idx }"} data-setname={"plx-data-#{ idx }"}>
            <polyline class="plx-data-line"
                      points={ for {{_xl, xp}, {_yl, yp}} <- dataset, into: "", do: "#{float(xp)},-#{float(yp)} " }
                      marker-start={"url(#marker-#{ idx })"}
                      marker-mid={"url(#marker-#{ idx })"}
                      marker-end={"url(#marker-#{ idx })"} />
          </g>
        <% end %>
        </g>
      </svg>
    """
  end

  defp assign_extras(assigns, name) do
    extras =
      assigns[name]
      |> Map.reject(fn {_,v} -> is_map(v) end)
      |> Phoenix.Component.assigns_to_attributes([:socket, :myself, :flash])

    assigns |> Phoenix.Component.assign(:extras, extras)
  end

  defp float(f), do: :erlang.float_to_binary(f, decimals: 3)
end
