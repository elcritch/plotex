defmodule Plotter.Output.Svg do
  require Logger

  use Phoenix.HTML

  def format_number(label, fmt \\ "~5.2f") do
    :io_lib.format(fmt, [label])
  end

  def generate(%Plotter{} = plot, opts \\ []) do

    nfmt = Keyword.get(opts, :number_format, "~5.2f")

    for xt <- plot.xticks do
      Logger.info("xtick: #{inspect xt}")
    end

    for yt <- plot.yticks do
      Logger.info("xtick: #{inspect yt}")
    end

    for data <- plot.datasets do
      for {x,y} <- data do
        Logger.info("data: #{inspect {x,y}}")
      end
    end


    assigns =
      plot
      |> Map.from_struct()
      # |> Map.update!(:xticks, & if opts[:x_axis_trim] do &1 |> Enum.drop(1) |> Enum.drop(-1) else &1 end)
      # |> Map.update!(:yticks, & if opts[:y_axis_trim] do &1 |> Enum.drop(1) |> Enum.drop(-1) else &1 end)
      |> Map.put(:opts, opts)

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
                  transform="rotate(<%= @opts[:x_axis_rotate] || 0 %>, <%= xp %>, -<%= @config.yaxis.view.start %>)"
                  dy="1em">

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
                  transform="rotate(<%= @opts[:y_axis_rotate] || 0 %>, <%= @config.xaxis.view.start %>, -<%= yp %>)"
                  dx="-1em">
              <%= format_number(yl, nfmt) %>
              </text>
          <% end %>
          <text y="-<%= (@config.yaxis.view.stop - @config.yaxis.view.start)/2.0 %>"
                x="<%= @config.xaxis.view.start/2.0 %>"
                class="label-title">
            <%= @config.xaxis.name %>
          </text>
        </g>
      </svg>


      """
      |> safe_to_string()
  end
end
