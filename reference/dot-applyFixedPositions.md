# Pin individuals to fixed layout positions

Overrides the computed layout coordinates for specific individuals,
using the \`config\$fixed_positions\` data frame. Positions are
interpreted in raw layout-slot units (the units produced by
\`calculateCoordinates()\`, before spacing and radial transforms), so
pins compose with \`generation_width\` / \`generation_height\` scaling
and radial layout. Because all downstream connection anchors are derived
from \`x_pos\`/\`y_pos\`, pinning automatically propagates to the
connecting segments. When a pinned individual is a parent, the family
anchor (\`x_fam\`/\`y_fam\`) of their children is recomputed as the
midpoint of the (pinned) parent positions, unless
\`config\$fixed_positions_update_family\` is \`FALSE\`.

## Usage

``` r
.applyFixedPositions(
  ds,
  config,
  personID = "personID",
  momID = "momID",
  dadID = "dadID"
)
```

## Arguments

- ds:

  A data frame of layout coordinates with at least \`x_pos\`, \`y_pos\`,
  and the \`personID\` column.

- config:

  A configuration list. Uses \`fixed_positions\` and
  \`fixed_positions_update_family\`.

- personID:

  Name of the individual ID column.

- momID:

  Name of the mother ID column.

- dadID:

  Name of the father ID column.

## Value

The input data frame with pinned coordinates applied.
