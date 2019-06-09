# Plotex

Pure Elixir library for producing simple plots. It's useful for producing streaming SVG graphs with the new Phoenix LiveView library. It could readily be used for other frameworks like Scenic. 

Warning, alpha status! It works, but is still very rough in many areas. However, it implements the fundamentals for plotting data. 

See units tests for examples of producing SVG graphs. 

## Installation

```elixir
def deps do
  [
    {:plotex, github: "elcritch/plotex", "~> 0.1.0"}
  ]
end
```

## Example 

```elixir


def render(socket) do

    xdata = [
      DateTime.from_iso8601("2019-05-20T05:04:12.836Z") |> elem(1),
      DateTime.from_iso8601("2019-05-20T05:13:17.836Z") |> elem(1),
      DateTime.from_iso8601("2019-05-20T05:21:23.836Z") |> elem(1),
      DateTime.from_iso8601("2019-05-20T05:33:25.836Z") |> elem(1),
    ]
    ydata = [0.1, 0.25, 0.15, 0.1]

    plt = PlotEx.plot(
      [{xdata, ydata}],
      xaxis: [kind: :datetime,
              ticks: 5,
              padding: 0.05]
    )
    Logger.warn("svg plotex cfg: #{inspect plt, pretty: true }")

    svg_str =
      PlotEx.Output.Svg.generate(
        plt,
        xaxis: [rotate: 35, dy: '2.5em' ],
        yaxis: [],
      ) |> Phoenix.HTML.safe_to_string()

    Logger.warn("SVG: \n#{svg_str}")
    assigns = [svg_str: svg_str]

    ~L"""
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
      <%= @svg_str %>
    </body>
    </html>
    """
end

```

## TODO

[] The configuration API needs to be expanded upon. 
[] Needs work in plumbing through options for adjusting the side widths and adjusting the overall size. 
[] Lots of work on documentation work. 
[] Would like to remove the dependency on Calendar and TZData dependency.  
[] PR's welcome. 

