# Relink IDs to closest duplicate appearance based on coordinates

Relink IDs to closest duplicate appearance based on coordinates

## Usage

``` r
relink(df, col, dup_xy_list, dup_xy)
```

## Arguments

- df:

  A data.frame containing pedigree layout info with columns including:
  \`x_pos\`, \`y_pos\`, and the target column to relink.

- col:

  Character; name of the column to relink (e.g., \`"momID"\`,
  \`dadID"\`, \`spouseID"\`).

- dup_xy_list:

  A list of data.frames, each containing duplicate appearances for a
  specific coreID with columns: \`personID\`, \`x_pos\`, \`y_pos\`, and
  \`total_blue\`.

- dup_xy:

  A data.frame containing all duplicate appearances with columns:
  \`personID\`, \`coreID\`, \`x_pos\`, \`y_pos\`, and \`total_blue\`.

## Value

A modified \`df\` data.frame with updated IDs in the specified column.
