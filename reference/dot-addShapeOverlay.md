# Add Shape Overlay to ggplot Pedigree Plot

Draws a shape (cross, slash, or x) over symbols of matching individuals.
Used when overlay_mode is "shape" to draw markers on top of pedigree
symbols (e.g., cross for deceased individuals).

## Usage

``` r
.addShapeOverlay(plotObject, config, overlay_column, overlay_spec = NULL)

addShapeOverlay(plotObject, config, overlay_column, overlay_spec = NULL)
```

## Arguments

- plotObject:

  A ggplot object.

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

- overlay_column:

  Character string specifying the column name for overlay status.

- overlay_spec:

  Optional list of per-overlay settings that override config defaults.
  Recognized keys: `shape`, `color`, `size`, `stroke`, `code_affected`.

## Value

A ggplot object with shape overlay markers added.
