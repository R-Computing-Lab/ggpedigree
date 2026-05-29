# Build spouse segments

Build spouse segments

## Usage

``` r
buildSpouseSegments(ped, connections_for_FOO, use_hash = TRUE, config = list())
```

## Arguments

- ped:

  A data frame containing the pedigree data. Needs personID, momID,
  dadID, and sex columns.

- connections_for_FOO:

  A data frame containing the connections for the spouse segments from
  parent connections

- use_hash:

  Logical. If TRUE, use the parent_hash to build segments. If FALSE, use
  the spouseID.

- config:

  List of configuration parameters. Currently unused but passed through
  to internal helpers.

## Value

A data frame with the spouse segments
