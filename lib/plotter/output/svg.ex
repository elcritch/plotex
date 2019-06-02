defmodule Plotter.Output.Svg do
  require Logger

  use Phoenix.HTML


  def generate(%Plotter{} = plot) do

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

    assigns = plot |> Map.from_struct()

    ~E"""
        <svg version="1.2" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"
             viewbox="0 0 1 1 " class="graph" version="1.2" >
        <title id="title"> <%= @config.title %> </title>
        <g class="grid x-grid">
          <line x1="<%= @config.xaxis.view.start %>"
                x2="<%= @config.xaxis.view.stop %>"
                y1="<%= @config.yaxis.view.start %>"
                y2="<%= @config.yaxis.view.stop %>" >
          </line>

        </g>
        <g class="labels x-labels">
          <%= for {xl, xp} <- @xticks do %>
            <text x="<%= xp %>" y="<%= @config.yaxis.view.start %>"><%= xl %></text>
          <% end %>
          <text x="<%= (@config.xaxis.view.stop - @config.xaxis.view.start)/2.0 %>"
                y="<%= @config.yaxis.view.start/2.0  %>"
                class="label-title">
            <%= @config.xaxis.name %>
          </text>
        </g>
      </svg>


      """
      |> safe_to_string()
  end
end
