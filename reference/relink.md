# Relink IDs to closest duplicate appearance based on coordinates

Relink IDs to closest duplicate appearance based on coordinates

## Usage

``` r
relink(df, col, dup_xy_list)
```

## Arguments

- df:

  A data.frame containing pedigree layout info with columns including:
  \`x_pos\`, \`y_pos\`, and the target column to relink.

- col:

  Character; name of the column to relink (e.g., \`"momID"\`,
  \`dadID"\`, \`spouseID"\`).

## Value

A modified \`df\` data.frame with updated IDs in the specified column.
