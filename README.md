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

