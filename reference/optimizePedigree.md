# Optimize Pedigree Plot

Optimize a pedigree plot by rounding coordinates to reduce file size.

## Usage

``` r
optimizePedigree(p, config = list(), plot_type = c("plotly", "static"))
```

## Arguments

- p:

  A plotly or ggplot object representing the pedigree plot.

- config:

  A list of configuration parameters, including
  \`value_rounding_digits\`.

- plot_type:

  A string indicating the type of plot: "plotly" or "static". Default is
  "plotly". @return The optimized plot object with rounded coordinates.
  @keywords internal
