# Find the closest duplicate appearance based on coordinates

Find the closest duplicate appearance based on coordinates

## Usage

``` r
closest_dup(target_core, x0, y0, dup_xy_list, dup_xy)
```

## Arguments

- target_core:

  The coreID of the individual to find.

- x0:

  The x-coordinate of the reference point.

- y0:

  The y-coordinate of the reference point.

- dup_xy_list:

  A list of data.frames, each containing duplicate appearances for a
  specific coreID with columns: \`personID\`, \`x_pos\`, \`y_pos\`, and
  \`total_blue\`.

- dup_xy:

  A data.frame containing all duplicate appearances with columns:
  \`personID\`, \`coreID\`, \`x_pos\`, \`y_pos\`, and \`total_blue\`.

## Value

The personID of the closest duplicate appearance.
