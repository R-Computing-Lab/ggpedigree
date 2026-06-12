# Count crossed parent-stub segments in a pedigree layout

Within each generation row, counts pairs of individuals whose
parent-stub segments cross: individual i is to the left of j in their
generation, but i's parent midpoint (\`x_fam\`) is to the right of j's
parent midpoint, or vice versa. This is an inversion count — equivalent
to counting bubble-sort swaps needed to restore a monotone
parent-midpoint ordering. Only non-extra, placed individuals with a
known \`x_fam\` are considered.

Within each generation row, counts pairs of individuals whose
parent-stub segments cross: individual i is to the left of j in their
generation, but i's parent midpoint (\`x_fam\`) is to the right of j's
parent midpoint, or vice versa. This is an inversion count — equivalent
to counting bubble-sort swaps needed to restore a monotone
parent-midpoint ordering. Only non-extra, placed individuals with a
known \`x_fam\` are considered.

## Usage

``` r
.layoutScoreCrossings(ds)

.layoutScoreCrossings(ds)
```

## Arguments

- ds:

  Data frame produced by \`calculateCoordinates\`.

## Value

A non-negative integer.

A non-negative integer.
