# Apply radial layout transformation to pedigree coordinates

Transforms Cartesian pedigree coordinates (x_pos = horizontal slot,
y_pos = generation) into Cartesian coordinates derived from a polar
mapping, producing a circular or fan-shaped layout. The transformation
maps x_pos to an angular position and y_pos to a radial distance, then
converts back to (x, y) via standard polar-to-Cartesian conversion.
Family bar positions (x_fam, y_fam) are transformed using the same
mapping.

## Usage

``` r
.applyRadialLayout(ds, config)

applyRadialLayout(ds, config)
```

## Arguments

- ds:

  A data frame containing at minimum x_pos, y_pos, x_fam, and y_fam
  columns, as produced by calculateCoordinates and .adjustSpacing.

- config:

  A list of configuration options for customizing the plot. See
  getDefaultPlotConfig for details of each option. The list can include:

  code_male

  :   Integer or string. Value identifying males in the sex column.
      (typically 0 or 1) Default: 1

  segment_spouse_color, segment_self_color

  :   Character. Line colors for respective connection types.

  segment_sibling_color, segment_parent_color, segment_offspring_color

  :   Character. Line colors for respective connection types.

  label_text_size, point_size, segment_linewidth

  :   Numeric. Controls text size, point size, and line thickness.

  generation_height

  :   Numeric. Vertical spacing multiplier between generations. Default:
      1.

  shape_unknown, shape_female, shape_male, status_shape_affected

  :   Integers. Shape codes for plotting each group.

  sex_shape_labels

  :   Character vector of labels for the sex variable. (default:
      c("Female", "Male", "Unknown"))

  unaffected, affected

  :   Values indicating unaffected/affected status.

  sex_color_include

  :   Logical. If TRUE, uses color to differentiate sex.

  label_max_overlaps

  :   Maximum number of overlaps allowed in repelled labels.

  label_segment_color

  :   Color used for label connector lines.

## Value

The input data frame with x_pos, y_pos, x_fam, and y_fam replaced by
their radially transformed equivalents.
