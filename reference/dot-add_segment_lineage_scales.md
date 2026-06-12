# Add Segment Lineage Color Scale

Builds and appends the color scale used for lineage-colored segments.
The scale type is chosen by \`config\$segment_lineage_method\`. Discrete
methods (\`"viridis_d"\`, \`"hue"\`, \`"manual"\`) suit lineage-group
coloring; continuous methods (\`"viridis_c"\`, \`"viridis_b"\`,
\`"gradient"\`, \`"gradient2"\`, \`"steps"\`) suit
focal/relatedness-based coloring.

## Usage

``` r
.add_segment_lineage_scales(p, config)
```

## Arguments

- p:

  A ggplot object.

- config:

  A configuration list.

## Value

A ggplot object with the segment lineage color scale added.
