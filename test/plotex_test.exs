defmodule PlotexTest do
  require Logger
  use ExUnit.Case
  alias Plotex.Axis
  alias Plotex.Axis.Units
  alias Plotex.Output.Options
  # alias Plotex.Output.Formatter

  # import Phoenix.LiveView.Helpers
  import Phoenix.LiveViewTest

  # @default_css

  doctest Plotex

  test "simple plot" do
    xdata = 1..4 |> Enum.map(& &1)
    ydata = xdata |> Enum.map(&:math.sin(&1 / 10.0))

    plt = Plotex.plot([{xdata, ydata}])
    assert plt != nil
    # Logger.warn("plotex cfg: #{inspect plt }")
  end

  test "nil plot" do
    xdata = []
    ydata = []

    plt = Plotex.plot([{xdata, ydata}])
    assert plt != nil
    # Logger.warn("plotex cfg: #{inspect plt }")
  end

  test "date plot" do
    xdata = [0.0, 2.0, 3.0, 4.0]
    ydata = [0.1, 0.25, 0.15, 0.1]

    plt = Plotex.plot([{xdata, ydata}], xkind: :numeric)
    # Logger.warn("plotex cfg: #{inspect plt }")

    # Logger.info("xticks: #{inspect plt.xticks}")
    # Logger.info("yticks: #{inspect plt.yticks |> Enum.to_list()}")
    assert plt.xticks == [
             {0.0, 13.636363636363637},
             {0.5, 22.727272727272727},
             {1.0, 31.818181818181817},
             {1.5, 40.90909090909091},
             {2.0, 50.0},
             {2.5, 59.090909090909086},
             {3.0, 68.18181818181819},
             {3.5, 77.27272727272727},
             {4.0, 86.36363636363636}
           ]

    assert Enum.to_list(plt.yticks) == [
             {0.1, 13.63636363636364},
             {0.12, 23.33333333333333},
             {0.14, 33.03030303030303},
             {0.16, 42.72727272727273},
             {0.18, 52.42424242424242},
             {0.2, 62.121212121212125},
             {0.22000000000000003, 71.81818181818183},
             {0.24, 81.5151515151515}
           ]

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
    options = %Options{
          xaxis: %Options.Axis{label: %Options.Item{rotate: 35}}
        }

    svg_str =
      render_component(&Plotex.Output.Svg.generate/1, plot: plt, opts: options)

    # Logger.warning("SVG: \n#{svg_str}")

    html_str = """
    <html>
    <head>
    </head>
    <body>
      <style>
        #{Plotex.Output.Svg.default_css()}
      </style>
      #{svg_str}
    </body>
    </html>
    """

    File.write!("examples/output.html", html_str)
  end

  test "svg dual plot" do
    xdata1 = [0.0, 2.0, 3.0, 4.0]
    ydata1 = [0.1, 0.25, 0.15, 0.1]
    xdata2 = [0.0, 1.5, 3.5, 4.5]
    ydata2 = [0.2, 0.25, 0.10, 0.05]

    plt =
      Plotex.plot([{xdata1, ydata1}, {xdata2, ydata2}], xkind: :numeric, xaxis: [padding: 0.05])

    # Logger.warn("svg plotex cfg: #{inspect plt, pretty: true }")

    svg_str =
      render_component(&Plotex.Output.Svg.generate/1,
        plot: plt,
        opts: %Options{
          xaxis: %Options.Axis{label: %Options.Item{rotate: 35}},
          default_data: %Options.Data{
            shape: :rect,
            width: 3.0,
            height: 3.0
          },
          data: %{
            0 => %Options.Data{
              shape: :circle,
              width: 1.5,
              height: 1.5
            }
          }
        }
      )

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

    File.write!("examples/output-dual.html", html_str)
  end

  test "svg datetime (short) plot" do
    xdata = [
      ~U[2019-05-20T05:04:12.836Z],
      ~U[2019-05-20T05:04:17.836Z],
      ~U[2019-05-20T05:04:23.836Z],
      ~U[2019-05-20T05:04:25.836Z]
    ]

    ydata = [0.1, 0.25, 0.15, 0.1]

    plt =
      Plotex.plot(
        [{xdata, ydata}],
        xaxis: [kind: :datetime, ticks: 5, padding: 0.05]
      )

    # Logger.warn("svg plotex cfg: #{inspect plt, pretty: true }")

    svg_str =
      render_component(&Plotex.Output.Svg.generate/1,
        plot: plt,
        opts: %Options{
          # xaxis: [rotate: 35, offset: '2.5em' ],
          xaxis: %Options.Axis{label: %Options.Item{rotate: 35}},
          yaxis: %Options.Axis{label: %Options.Item{}}
        }
      )

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

    File.write!("examples/output-dt.html", html_str)
  end

  test "svg datetime (hours) plot" do
    xdata = [
      ~U[2019-05-20T05:04:12.836Z],
      ~U[2019-05-20T05:04:17.836Z],
      ~U[2019-05-20T05:04:23.836Z],
      ~U[2019-05-20T05:04:25.836Z]
    ]

    ydata = [0.1, 0.25, 0.15, 0.1]

    plt =
      Plotex.plot(
        [{xdata, ydata}],
        xaxis: [
          kind: :datetime,
          units: %Units.Time{ticks: 5},
          padding: 0.05
        ]
      )

    # Logger.warn("svg plotex cfg: #{inspect plt, pretty: true }")

    svg_str =
      render_component(&Plotex.Output.Svg.generate/1,
        plot: plt,
        opts: %Options{
          # xaxis: [rotate: 35, offset: '2.5em' ],
          xaxis: %Options.Axis{label: %Options.Item{rotate: 35}},
          yaxis: %Options.Axis{}
        }
      )

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

    File.write!("examples/output-dt-hours.html", html_str)
  end

  test "svg nativedatetime (hours) plot" do
    xdata = [
      ~N[2019-05-20T05:04:12.836Z],
      ~N[2019-05-20T05:04:17.836Z],
      ~N[2019-05-20T05:04:23.836Z],
      ~N[2019-05-20T05:05:27.836Z]
    ]

    ydata = [0.1, 0.13, 0.15, 0.1]

    plt =
      Plotex.plot(
        [{xdata, ydata}],
        xaxis: [kind: :datetime, ticks: 5, padding: 0.05]
      )

    # Logger.warn("svg plotex cfg: #{inspect plt, pretty: true }")

    svg_str =
      render_component(&Plotex.Output.Svg.generate/1,
        plot: plt,
        opts: %Options{
          xaxis: %Options.Axis{label: %Options.Item{rotate: 35, offset: 5.0}},
          yaxis: %Options.Axis{label: %Options.Item{offset: 5.0}}
        }
      )

    # Logger.warn("SVG: examples/output-naive-dt-hours.html => \n#{svg_str}")

    File.write!("examples/output-native-dt-hours.html", svg_wrap(svg_str))
  end

  test "svg naivedatetime micros plot" do
    xdata = [
      ~U[2019-05-20T05:04:12.000Z],
      ~U[2019-05-20T05:04:12.100Z],
      ~U[2019-05-20T05:04:12.200Z],
    ]

    ydata = [0.1, 0.25, 0.33]

    plt =
      Plotex.plot(
        [{xdata, ydata}],
        xaxis: [kind: :datetime, ticks: 5, padding: 0.05]
      )

    # Logger.warn("svg plotex cfg: #{inspect plt, pretty: true }")

    svg_str =
      render_component(&Plotex.Output.Svg.generate/1,
        plot: plt,
        opts: %Options{
          xaxis: %Options.Axis{label: %Options.Item{rotate: 35, offset: 5.0}},
          yaxis: %Options.Axis{label: %Options.Item{offset: 5.0}}
        }
      )

    # Logger.warn("SVG: \n#{svg_str}")
    File.write!("examples/output-naive-dt-micros.html", svg_wrap(svg_str))
  end

  test "svg naivedatetime micros min_basis plot" do
    xdata = [
      ~U[2019-05-20T05:04:12.000Z],
      ~U[2019-05-20T05:04:12.100Z],
      ~U[2019-05-20T05:04:12.200Z]
    ]

    ydata = [0.1, 0.25, 0.15, 0.1]

    plt =
      Plotex.plot(
        [{xdata, ydata}],
        xaxis: [
          kind: :datetime,
          units: %Axis.Units.Time{ticks: 4, min_basis: :minute},
          ticks: 5,
          padding: 0.05
        ]
      )

    # Logger.warn("svg plotex cfg: #{inspect plt, pretty: true }")

    svg_str =
      render_component(&Plotex.Output.Svg.generate/1,
        plot: plt,
        opts: %Options{
          xaxis: %Options.Axis{label: %Options.Item{rotate: 35, offset: 5.0}},
          yaxis: %Options.Axis{label: %Options.Item{offset: 5.0}}
        }
      )

    # Logger.warn("SVG: \n#{svg_str}")

    File.write!("examples/output-naive-dt-micros-min-basis.html", svg_wrap(svg_str))
  end

  defp svg_wrap(html_str, css_str \\ Plotex.Output.Svg.default_css()) do
    """
    <html>
    <head>
      <style>
        #{css_str}
      </style>
    </head>
    <body>
      #{html_str}
    </body>
    </html>
    """
  end

  test "kalman example" do

    xdata = 1..200 |> Enum.map(&(1.0*&1))
    # random_data_init = 1..100 |> Enum.map(fn _ -> :rand.normal(20.0, 0.05) end)
    # random_data_then = 1..100 |> Enum.map(fn _ -> :rand.normal(22.0, 0.05) end)

    # random_data = random_data_init ++ random_data_then
    random_data = [20.227417713530716, 20.20687663475102, 19.925046434279132, 19.875326175878612,
    20.12771910006722, 19.924661670715086, 19.864084044633668, 20.00800560692116,
    20.2539918989539, 20.13218575104653, 20.09740578858128, 20.401711269708354,
    20.472444820392155, 20.245419552103815, 19.8742802133798, 19.98878084965713,
    19.77402310062603, 20.233676029742178, 19.76144790477244, 20.286577179458522,
    19.681604290523563, 20.066789996130822, 19.927899120155452, 19.999394188864194,
    20.10180945886626, 19.853713547286464, 20.291132360203466, 20.078431534626056,
    19.999044816188675, 19.950855597186717, 20.37258097170872, 19.73799891736898,
    20.10229268998007, 20.09927147505095, 19.857252042470275, 20.25075470006898,
    19.87905343501343, 20.48937258037893, 19.715471439322272, 19.985213115754625,
    19.6917582200419, 19.899200022865426, 20.143368763712928, 20.10044713312054,
    19.947180203512005, 19.748759834277987, 20.010815015105397, 20.310499042488477,
    20.053627484829722, 20.212118584897407, 19.745181412930087, 20.288212947232818,
    19.779711850603764, 19.948463047098006, 20.054569337001894, 19.90569398333976,
    19.909790778930343, 19.752886853301877, 20.150215833959173, 20.26329566059294,
    20.026545417774056, 20.482206292441614, 19.9363067978462, 20.272450441644672,
    20.10173095608103, 19.891580120558682, 19.9295537203791, 20.186673119451232,
    19.865776852159847, 20.054642183170635, 19.999017111685053, 19.87618205665358,
    19.975203337400742, 20.031935662602496, 20.100606801463858, 20.12393132850585,
    19.932227629217206, 19.8791644558069, 20.06720737722687, 20.332838742597893,
    19.957665233176552, 20.024175899783494, 19.999450729406824, 19.649311989642904,
    20.433309604693175, 20.15983846748365, 19.534369471008404, 19.789365742771068,
    20.19258859147339, 19.941943465524055, 20.023316026813887, 19.901009882718107,
    19.895939537060165, 20.245979062815366, 20.035109657332548, 20.333335045996048,
    19.71859229999066, 19.786755731629974, 19.883711305884507, 20.087209840754085,
    21.67836879461743, 22.28147134051736, 21.666996216583055, 22.230047062534197,
    21.87742268458912, 22.1706108560654, 22.10152326700615, 21.75610083610442,
    21.84020151509927, 22.119607907420868, 22.23822916368149, 21.973376500404154,
    21.948376808639065, 22.164016261168193, 21.82498537119724, 22.22672887423946,
    21.58062441520716, 22.20954900289939, 21.854059172340815, 22.17430441251355,
    22.129355161431366, 22.06434503120941, 22.175390685862734, 22.23554643390378,
    21.971109776823386, 22.08807764564184, 22.027718919106906, 21.903734597270862,
    21.793654170343952, 22.073667879900967, 21.93125736949567, 21.881464398107312,
    22.08361957615157, 21.99272074010714, 21.741336249006604, 22.28113416667802,
    21.89053443598512, 22.085570007174884, 21.530299765711355, 22.203613846386883,
    21.95679890951436, 21.6795597621149, 21.892284062929964, 22.275749507675684,
    21.854589683863647, 22.11177200963023, 21.68497020542671, 22.188725279346535,
    21.945820630225146, 22.07691070761783, 22.246211406326424, 21.828590017206416,
    21.78645513277813, 21.769595002735304, 22.035326611785184, 21.820059207874262,
    21.645097825113087, 21.95550168914717, 21.98088103571782, 21.972677418181497,
    21.85579169997454, 22.092374716943965, 21.919576714274204, 21.957684872276545,
    22.057113540515083, 22.070977699969035, 21.50624463169333, 21.909468749760055,
    21.90440193713136, 21.92139188486217, 21.885565011553375, 21.590449732351473,
    22.208068805041446, 21.907384274209416, 21.720964702805425, 22.011438094913416,
    22.35882894534845, 22.05690631018278, 22.09226575798821, 21.971114634488185,
    22.29684031310041, 22.394461179802605, 22.244359730309423, 21.56704330485982,
    21.93365016741054, 21.829715981677513, 22.007888662132537, 22.298876282574728,
    22.01578793274998, 21.774143249274616, 21.631500837534315, 22.114274350170987,
    21.867792774707723, 22.297626093652706, 22.132228084507574, 22.06346766551326,
    22.06200658773504, 21.960340842432885, 22.007321695509187, 21.74450919457732]

    # IO.inspect(random_data, pretty: true, label: YY, limit: :infinity)

    k = Kalman.new(
      a: 1.0,  # No process innovation
      c: 1.0,  # Measurement
      b: 0.0,  # No control input
      q: 0.05,  # Process covariance
      r: 1.0,  # Measurement covariance
      x: 22.0,  # Initial estimate
      p: 1.0  # Initial covariance
    )

    moving_est = random_data |> box_average(5)

    {_, kalman_est} =
      for yy <- random_data, reduce: {k, []} do
        {k, prev} ->
          # IO.puts("YY: #{inspect yy}")
          k! = Kalman.step(0.0, yy, k)
          {k!, [Kalman.estimate(k!) | prev ]}
      end

    kalman_est = kalman_est |> Enum.reverse()

    plt =
      Plotex.plot(
        [
          {xdata, random_data},
          {xdata, kalman_est},
          {xdata, moving_est},
        ],
        xaxis: [
          ticks: 5,
          padding: 0.05
        ]
      )

    # Logger.warn("svg plotex cfg: #{inspect plt, pretty: true }")

    svg_str =
      render_component(&Plotex.Output.Svg.generate/1,
        plot: plt,
        opts: %Options{
          xaxis: %Options.Axis{label: %Options.Item{rotate: 35, offset: 5.0}},
          yaxis: %Options.Axis{label: %Options.Item{offset: 5.0}}
        }
      )

    # Logger.warn("SVG: \n#{svg_str}")
    html_str = """
    <html>
    <head>
    </head>
    <body>
      <style>
        :root {
          --graph-color0: rgba(217, 203, 0, 0.7);
          --graph-color1: rgba(0, 0, 0, 0.7);
          --graph-color2: rgba(0, 217, 11, 0.7);
          --graph-color3: rgba(217, 94, 0, 0.7);
        }

        #{Plotex.Output.Svg.default_css()}

        .plx-data .plx-data-line { stroke-width: 0.3; }

        // graph 0
        g.plx-data > g.plx-dataset-0 > polyline { display: none; }
        .plx-data .plx-dataset-0 .plx-data-line { stroke: rgba(0,0,0,0.0); }
        #marker-0 > .plx-data-point { stroke: var(--graph-color0); fill: var(--graph-color0); }

        // graph 1
        g.plx-data > g.plx-dataset-1 > polyline { stroke: var(--graph-color1); }
        g.plx-data > g.plx-dataset-1 > polyline { stroke: var(--graph-color1); }
        #marker-1 > .plx-data-point { stroke: var(--graph-color1); fill: var(--graph-color1); }

        // graph 2
        g.plx-data > g.plx-dataset-2 > polyline { stroke: var(--graph-color2); }
        g.plx-data > g.plx-dataset-2 > polyline { stroke: var(--graph-color2); }
        #marker-2 > .plx-data-point { stroke: var(--graph-color2); fill: var(--graph-color2); }

        .plx-graph {
          height: 500px;
          width: 1200px;
          stroke-width: 0.1;
        }
      </style>
      #{svg_str}
    </body>
    </html>
    """

    File.write!("examples/output-kalman-example.html", html_str)

  end

  ## very dumb box average, but avoids shortening the sample
  def box_average(data, 0) do
    data
  end

  def box_average(data, count) do
    data
    |> Enum.map_reduce([], fn x, acc ->
      group = Enum.take([x | acc], count)
      {Enum.sum(group) / Enum.count(group), group}
    end)
    |> (fn {data, _} -> data end).()
  end


end
