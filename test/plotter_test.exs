defmodule PlotterTest do
  require Logger
  use ExUnit.Case
  alias Plotter.Axis
  alias Plotter.ViewRange

  doctest Plotter

  test "data plots" do

    xdata = 1..4 |> Enum.map(& &1 )
    ydata = xdata |> Enum.map(& :math.sin(&1/10.0) )


    xlims = Plotter.NumberUnits.range_from(xdata) |> Plotter.ViewRange.new(:horiz)
    xaxis = %Axis{limits: xlims}
    # Logger.warn("xlims: #{inspect xlims}")
    # Logger.warn("xaxis: #{inspect xaxis}")

    ylims = Plotter.NumberUnits.range_from(ydata) |> Plotter.ViewRange.new(:vert)
    yaxis = %Axis{limits: ylims}
    # Logger.warn("ylims: #{inspect ylims}")
    # Logger.warn("yaxis: #{inspect yaxis}")

    {xrng, yrng} = Plotter.plot_data({xdata, ydata}, xaxis, yaxis)
    # Logger.warn("xrng: #{inspect xrng |> Enum.to_list()}")
    # Logger.warn("yrng: #{inspect yrng |> Enum.to_list()}")

    xs = [{1, 10.0}, {2, 36.66666666666667}, {3, 63.333333333333336}, {4, 90.0}]
    assert xs == Enum.to_list(xrng)
    ys = [{0.09983341664682815, 10.0}, {0.19866933079506122, 37.30415995856187}, {0.29552020666133955, 64.05993825604988}, {0.3894183423086505, 90.0}]
    assert ys == Enum.to_list(yrng)
  end

  test "plot limits" do

    xdata = 1..4 |> Enum.map(& &1 )
    ydata = xdata |> Enum.map(& :math.sin(&1/10.0) )

    xlims = Plotter.NumberUnits.range_from(xdata) |> Plotter.ViewRange.new()
    xaxis = %Axis{limits: xlims}

    ylims = Plotter.NumberUnits.range_from(ydata) |> Plotter.ViewRange.new()
    yaxis = %Axis{limits: ylims}

    {xrng, yrng} = Plotter.limits([{xdata, ydata}])

    assert xrng = %Plotter.ViewRange{projection: :cartesian, start: 0.85, stop: 4.15}
    assert yrng = %Plotter.ViewRange{projection: :cartesian, start: 0.08535417036373703, stop: 0.40389758859174163}
  end

  test "simple plot" do
    xdata = 1..4 |> Enum.map(& &1 )
    ydata = xdata |> Enum.map(& :math.sin(&1/10.0) )

    plt = Plotter.plot([{xdata, ydata}])
    Logger.warn("plotter cfg: #{inspect plt }")
  end

  test "nil plot" do
    xdata = []
    ydata = []

    plt = Plotter.plot([{xdata, ydata}])
    Logger.warn("plotter cfg: #{inspect plt }")
  end

  # test "nil date plot" do
  #   xdata = []
  #   ydata = []

  #   plt = Plotter.plot([{xdata, ydata}], xkind: :datetime)
  #   Logger.warn("plotter cfg: #{inspect plt }")
  # end

  test "date plot" do
    xdata = [0.0, 2.0, 3.0, 4.0]
    ydata = [0.1, 0.25, 0.15, 0.1]

    plt = Plotter.plot([{xdata, ydata}], xkind: :numeric)
    # Logger.warn("plotter cfg: #{inspect plt }")

    # for xt <- plt.xticks do
    #   Logger.info("xtick: #{inspect xt}")
    # end

    # for yt <- plt.yticks do
    #   Logger.info("xtick: #{inspect yt}")
    # end

    # for data <- plt.datasets do
    #   for {x,y} <- data do
    #     Logger.info("data: #{inspect {x,y}}")
    #   end
    # end

  end

  test "svg plot" do
    xdata = [0.0, 2.0, 3.0, 4.0]
    ydata = [0.1, 0.25, 0.15, 0.1]

    plt = Plotter.plot([{xdata, ydata}], xkind: :numeric, xaxis: [padding: 0.05])
    # Logger.warn("svg plotter cfg: #{inspect plt, pretty: true }")

    svg_str = Plotter.Output.Svg.generate(
                plt,
                number_format: "~5.3f",
                xaxis: [rotate: 35],
                yaxis: [rotate: 35],
      ) |> Phoenix.HTML.safe_to_string()

    # Logger.warn("SVG: \n#{svg_str}")

    html_str = """
    <html>
    <head>
      <style>
        .graph .labels .x-labels {
          text-anchor: middle;
        }
        .graph .labels, .graph .y-labels {
          text-anchor: middle;
        }
        .graph {
          height: 500px;
          width: 800px;
        }
        .graph .grid {
          stroke: #ccc;
          stroke-dasharray: 0;
          stroke-width: 1.0;
        }
        .labels {
          font-size: 3px;
        }
        .label-title {
          font-size: 8px;
          font-weight: bold;
          text-transform: uppercase;
          fill: black;
        }
        .data .data-point {
          fill: darkblue;
          stroke-width: 1.0;
        }
        .data .data-line {
          stroke: #0074d9;
          stroke-width: 0.1em;
          stroke-width: 0.1em;
          stroke-linecap: round;
          fill: none;
        }
      </style>
    </head>
    <body>
      #{svg_str}
    </body>
    </html>
    """
    File.write!("output.html", html_str)
  end

  test "svg datetime (short) plot" do
    xdata = [
      DateTime.from_iso8601("2019-05-20T05:04:12.836Z") |> elem(1),
      DateTime.from_iso8601("2019-05-20T05:04:17.836Z") |> elem(1),
      DateTime.from_iso8601("2019-05-20T05:04:23.836Z") |> elem(1),
      DateTime.from_iso8601("2019-05-20T05:04:25.836Z") |> elem(1),
    ]
    ydata = [0.1, 0.25, 0.15, 0.1]

    plt = Plotter.plot(
      [{xdata, ydata}],
      xaxis: [kind: :datetime,
              ticks: 5,
              padding: 0.05]
    )
    Logger.warn("svg plotter cfg: #{inspect plt, pretty: true }")

    svg_str =
      Plotter.Output.Svg.generate(
        plt,
        xaxis: [rotate: 35, dy: '2.5em' ],
        yaxis: [],
      ) |> Phoenix.HTML.safe_to_string()

    Logger.warn("SVG: \n#{svg_str}")

    html_str = """
    <html>
    <head>
      <style>
        .graph .labels .x-labels {
          text-anchor: middle;
        }
        .graph .labels, .graph .y-labels {
          text-anchor: middle;
        }
        .graph {
          height: 500px;
          width: 800px;
        }
        .graph .grid {
          stroke: #ccc;
          stroke-dasharray: 0;
          stroke-width: 1.0;
        }
        .labels {
          font-size: 3px;
        }
        .labels .x-labels {
          font-size: 1px;
        }
        .label-title {
          font-size: 8px;
          font-weight: bold;
          text-transform: uppercase;
          fill: black;
        }
        .data .data-point {
          fill: darkblue;
          stroke-width: 1.0;
        }
        .data .data-line {
          stroke: #0074d9;
          stroke-width: 0.1em;
          stroke-width: 0.1em;
          stroke-linecap: round;
          fill: none;
        }
      </style>
    </head>
    <body>
      #{svg_str}
    </body>
    </html>
    """
    File.write!("output-dt.html", html_str)
  end

  test "svg datetime (hours) plot" do
    xdata = [
      DateTime.from_iso8601("2019-05-20T05:04:12.836Z") |> elem(1),
      DateTime.from_iso8601("2019-05-20T05:13:17.836Z") |> elem(1),
      DateTime.from_iso8601("2019-05-20T05:21:23.836Z") |> elem(1),
      DateTime.from_iso8601("2019-05-20T05:33:25.836Z") |> elem(1),
    ]
    ydata = [0.1, 0.25, 0.15, 0.1]

    plt = Plotter.plot(
      [{xdata, ydata}],
      xaxis: [kind: :datetime,
              ticks: 5,
              padding: 0.05]
    )
    Logger.warn("svg plotter cfg: #{inspect plt, pretty: true }")

    svg_str =
      Plotter.Output.Svg.generate(
        plt,
        xaxis: [rotate: 35, dy: '2.5em' ],
        yaxis: [],
      ) |> Phoenix.HTML.safe_to_string()

    Logger.warn("SVG: \n#{svg_str}")

    html_str = """
    <html>
    <head>
      <style>
        .graph .labels .x-labels {
          text-anchor: middle;
        }
        .graph .labels, .graph .y-labels {
          text-anchor: middle;
        }
        .graph {
          height: 500px;
          width: 800px;
        }
        .graph .grid {
          stroke: #ccc;
          stroke-dasharray: 0;
          stroke-width: 1.0;
        }
        .labels {
          font-size: 3px;
        }
        .labels .x-labels {
          font-size: 1px;
        }
        .label-title {
          font-size: 8px;
          font-weight: bold;
          text-transform: uppercase;
          fill: black;
        }
        .data .data-point {
          fill: darkblue;
          stroke-width: 1.0;
        }
        .data .data-line {
          stroke: #0074d9;
          stroke-width: 0.1em;
          stroke-width: 0.1em;
          stroke-linecap: round;
          fill: none;
        }
      </style>
    </head>
    <body>
      #{svg_str}
    </body>
    </html>
    """
    File.write!("output-dt-hours.html", html_str)
  end

end
