# Build spouse segments

Build spouse segments

## Usage

``` r
buildSpouseSegments(ped, connections_for_FOO, use_hash = TRUE)
```

## Arguments

- ped:

  A data frame containing the pedigree data. Needs personID, momID, and
  dadID columns

- connections_for_FOO:

  A data frame containing the connections for the spouse segments from
  parent connections

- use_hash:

  Logical. If TRUE, use the parent_hash to build segments. If FALSE, use
  the spouseID.

## Value

A data frame with the spouse segments
