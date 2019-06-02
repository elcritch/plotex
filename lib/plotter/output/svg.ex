defmodule Plotter.Output.Svg do
  require Logger

  use Phoenix.HTML

  def format_number(label, fmt \\ "~5.2f") do
    :io_lib.format(fmt, [label])
  end


  def generate(%Plotter{} = plot, opts \\ []) do

    nfmt = Keyword.get(opts, :number_format, "~5.2f")

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
                  transform="rotate(<%= @opts[:x_axis][:rotate] || 0 %>, <%= xp %>, -<%= @config.yaxis.view.start %>)"
                  dy="<%= @opts[:x_axis][:em] || '1.5em' %>">

              <%= format_number(xl, nfmt) %>
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
                  transform="rotate(<%= @opts[:y_axis][:rotate] || 0 %>, <%= @config.xaxis.view.start %>, -<%= yp %>)"
                  dx="-<%= @opts[:y_axis][:em] || '1.5em' %>">
              <%= format_number(yl, nfmt) %>
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
        <%= for dataset <- @datasets do %>
          <g class="data-point" data-setname="">
            <polyline class="data-line"
                      points="
                        <%= for {{_xl, xp}, {_yl, yp}} <- dataset do %>
                          <%= xp %>,-<%= yp %>
                        <% end %>
                        "/>

            <%= for {{xl, xp}, {yl, yp}} <- dataset do %>
              <%= case @opts[:data][:type] do %>
              <% :circle -> %>
                <circle
                      cx="<%= xp %>"
                      cy="-<%= yp %>"
                      r="<%= (@opts[:data][:size] || @ds)/2.0 %>"
                      data-x-value="<%= xl %>"
                      data-y-value="<%= yl %>"
                      ></circle>
              <% _rect_default -> %>
                <rect
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
      |> safe_to_string()
  end
end
