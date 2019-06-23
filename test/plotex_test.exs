defmodule PlotexTest do
  require Logger
  use ExUnit.Case
  alias Plotex.Axis
  alias Plotex.ViewRange
  alias Plotex.Output.Options

  @default_css

  doctest Plotex

  test "data plots" do

    xdata = 1..4 |> Enum.map(& &1 )
    ydata = xdata |> Enum.map(& :math.sin(&1/10.0) )


    xlims = Plotex.NumberUnits.range_from(xdata) |> Plotex.ViewRange.new(:horiz)
    xaxis = %Axis{limits: xlims}
    # Logger.warn("xlims: #{inspect xlims}")
    # Logger.warn("xaxis: #{inspect xaxis}")

    ylims = Plotex.NumberUnits.range_from(ydata) |> Plotex.ViewRange.new(:vert)
    yaxis = %Axis{limits: ylims}
    # Logger.warn("ylims: #{inspect ylims}")
    # Logger.warn("yaxis: #{inspect yaxis}")

    {xrng, yrng} = Plotex.plot_data({xdata, ydata}, xaxis, yaxis)
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

    xlims = Plotex.NumberUnits.range_from(xdata) |> Plotex.ViewRange.new()
    xaxis = %Axis{limits: xlims}

    ylims = Plotex.NumberUnits.range_from(ydata) |> Plotex.ViewRange.new()
    yaxis = %Axis{limits: ylims}

    {xrng, yrng} = Plotex.limits([{xdata, ydata}])

    assert xrng = %Plotex.ViewRange{projection: :cartesian, start: 0.85, stop: 4.15}
    assert yrng = %Plotex.ViewRange{projection: :cartesian, start: 0.08535417036373703, stop: 0.40389758859174163}
  end

  test "simple plot" do
    xdata = 1..4 |> Enum.map(& &1 )
    ydata = xdata |> Enum.map(& :math.sin(&1/10.0) )

    plt = Plotex.plot([{xdata, ydata}])
    # Logger.warn("plotex cfg: #{inspect plt }")
  end

  test "nil plot" do
    xdata = []
    ydata = []

    plt = Plotex.plot([{xdata, ydata}])
    # Logger.warn("plotex cfg: #{inspect plt }")
  end

  # test "nil date plot" do
  #   xdata = []
  #   ydata = []

  #   plt = Plotex.plot([{xdata, ydata}], xkind: :datetime)
  #   Logger.warn("plotex cfg: #{inspect plt }")
  # end

  test "date plot" do
    xdata = [0.0, 2.0, 3.0, 4.0]
    ydata = [0.1, 0.25, 0.15, 0.1]

    plt = Plotex.plot([{xdata, ydata}], xkind: :numeric)
    # Logger.warn("plotex cfg: #{inspect plt }")

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

    plt = Plotex.plot([{xdata, ydata}], xkind: :numeric, xaxis: [padding: 0.05])
    # Logger.warn("svg plotex cfg: #{inspect plt, pretty: true }")

    svg_str = Plotex.Output.Svg.generate(
                plt,
                %Options{
                  xaxis: %Options.Axis{ label: %Options.Item{ rotate: 35 }},
                  xaxis: %Options.Axis{ label: %Options.Item{ rotate: 35 }},
                }
            ) |> Phoenix.HTML.safe_to_string()

    # Logger.warn("SVG: \n#{svg_str}")

    html_str = """
    <html>
    <head>
      <style>
        #{Plotex.Output.Svg.default_css()}
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

    plt = Plotex.plot(
      [{xdata, ydata}],
      xaxis: [kind: :datetime,
              ticks: 5,
              padding: 0.05]
    )
    # Logger.warn("svg plotex cfg: #{inspect plt, pretty: true }")

    svg_str =
      Plotex.Output.Svg.generate(
        plt,
        %Options{
          # xaxis: [rotate: 35, offset: '2.5em' ],
          xaxis: %Options.Axis{ label: %Options.Item{ rotate: 35 } },
          yaxis: %Options.Axis{ label: %Options.Item{ } },
        }
      ) |> Phoenix.HTML.safe_to_string()

    # Logger.warn("SVG: \n#{svg_str}")

    html_str = """
    <html>
    <head>
      <style>
        #{Plotex.Output.Svg.default_css()}
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

    plt = Plotex.plot(
      [{xdata, ydata}],
      xaxis: [kind: :datetime,
              ticks: 5,
              padding: 0.05]
    )
    # Logger.warn("svg plotex cfg: #{inspect plt, pretty: true }")

    svg_str =
      Plotex.Output.Svg.generate(
        plt,
        %Options{
          # xaxis: [rotate: 35, offset: '2.5em' ],
          xaxis: %Options.Axis{ label: %Options.Item{ rotate: 35 } },
          yaxis: %Options.Axis{ },
        }
      ) |> Phoenix.HTML.safe_to_string()

    # Logger.warn("SVG: \n#{svg_str}")

    html_str = """
    <html>
    <head>
      <style>
        #{Plotex.Output.Svg.default_css()}
      </style>
    </head>
    <body>
      #{svg_str}
    </body>
    </html>
    """
    File.write!("output-dt-hours.html", html_str)
  end

  test "svg naivedatetime (hours) plot" do
    xdata = [
      NaiveDateTime.from_iso8601("2019-05-20T05:04:12.836") |> elem(1),
      NaiveDateTime.from_iso8601("2019-05-20T05:13:17.836") |> elem(1),
      NaiveDateTime.from_iso8601("2019-05-20T05:21:23.836") |> elem(1),
      NaiveDateTime.from_iso8601("2019-05-20T05:33:25.836") |> elem(1),
    ]
    ydata = [0.1, 0.25, 0.15, 0.1]

    plt = Plotex.plot(
      [{xdata, ydata}],
      xaxis: [kind: :datetime,
              ticks: 5,
              padding: 0.05]
    )
    # Logger.warn("svg plotex cfg: #{inspect plt, pretty: true }")

    svg_str =
      Plotex.Output.Svg.generate(
        plt,
        %Options{
          xaxis: %Options.Axis{ label: %Options.Item{ rotate: 35, offset: 5.0 } },
          yaxis: %Options.Axis{ label: %Options.Item{ offset: 5.0 } },
        }
      ) |> Phoenix.HTML.safe_to_string()

    # Logger.warn("SVG: \n#{svg_str}")

    html_str = """
    <html>
    <head>
      <style>
        #{Plotex.Output.Svg.default_css()}
      </style>
    </head>
    <body>
      #{svg_str}
    </body>
    </html>
    """
    File.write!("output-naive-dt-hours.html", html_str)
  end

end
