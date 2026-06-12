# Add a single (possibly lineage-colored) segment layer

Internal helper that appends a \`geom_segment\` layer to a ggplot
object. When \`lineage_active\` is \`TRUE\` and the segment \`type\`
participates in lineage coloring (and the data carries a
\`segment_lineage\` column), the layer maps the \`colour\` aesthetic to
\`segment_lineage\`. Otherwise it uses the fixed per-type color
\`config\[\["segment\_\<type\>\_color"\]\]\`, preserving the original
behavior.

## Usage

``` r
.addSegmentLayer(
  plotObject,
  data,
  mapping,
  type,
  config,
  lineage_active = FALSE,
  ...
)
```

## Arguments

- plotObject:

  A ggplot object.

- data:

  A data frame supplying the segment endpoints.

- mapping:

  An \`aes()\` mapping for the segment geometry (x/xend/y/yend).

- type:

  Segment type, one of "spouse", "parent", "offspring", "sibling", "mz".

- config:

  A configuration list.

- lineage_active:

  Logical; whether lineage coloring is in effect for this plot.

- ...:

  Additional arguments passed to \`ggplot2::geom_segment()\`.

## Value

A ggplot object with the segment layer added.
