# Offset x positions across components and combine into one data frame

Offset x positions across components and combine into one data frame

## Usage

``` r
stitchComponents(component_dfs, x_offset = 0)
```

## Arguments

- component_dfs:

  List of data frames, one per component.

- x_offset:

  Numeric, initial offset to apply to the first component (default 0).

## Value

Single data frame with x positions shifted to prevent overlap.
