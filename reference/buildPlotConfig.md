# build Config

This function builds a configuration list for ggPedigree plots. It
merges a default configuration with user-specified settings, ensuring
all necessary parameters are set.

## Usage

``` r
buildPlotConfig(
  default_config,
  config,
  function_name = "ggPedigree",
  pedigree_size = NULL
)
```

## Arguments

- default_config:

  A list of default configuration parameters.

- config:

  A list of user-specified configuration parameters.

- function_name:

  The name of the function for which the configuration is being built.

- pedigree_size:

  Size of the pedigree, used for point scaling.

## Value

A complete configuration list with all necessary parameters.
