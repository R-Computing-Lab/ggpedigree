# Core Function for ggPedigree

This function is the core implementation of the ggPedigree function. It
handles the data preparation, layout calculation, and plotting of the
pedigree diagram. It is not intended to be called directly by users.

## Usage

``` r
ggPedigree.core(
  ped,
  famID = "famID",
  personID = "personID",
  momID = "momID",
  dadID = "dadID",
  spouseID = "spouseID",
  matID = "matID",
  patID = "patID",
  twinID = "twinID",
  focal_fill_column = NULL,
  overlay_column = NULL,
  status_column = NULL,
  config = list(),
  debug = FALSE,
  hints = NULL,
  function_name = "ggPedigree",
  phantoms = FALSE,
  ...
)
```

## Arguments

- ped:

  A data frame containing the pedigree data. Needs personID, momID, and
  dadID columns

- famID:

  Character string specifying the column name for family IDs. Defaults
  to "famID".

- personID:

  Character string specifying the column name for individual IDs.
  Defaults to "personID".

- momID:

  Character string specifying the column name for mother IDs. Defaults
  to "momID".

- dadID:

  Character string specifying the column name for father IDs. Defaults
  to "dadID".

- spouseID:

  Character string specifying the column name for spouse IDs. Defaults
  to "spouseID".

- matID:

  Character string specifying the column name for maternal lines
  Defaults to "matID".

- patID:

  Character string specifying the column name for paternal lines
  Defaults to "patID".

- twinID:

  Character string specifying the column name for twin IDs. Defaults to
  "twinID".

- focal_fill_column:

  Character string specifying the column name for focal fill color.

- overlay_column:

  Character string specifying the column name for overlay alpha values.

- status_column:

  Character string specifying the column name for affected status.
  Defaults to NULL.

- config:

  A list of configuration options for customizing the plot. See
  getDefaultPlotConfig for details. The list can include:

  code_male

  :   Integer or string. Value identifying males in the sex column.
      (typically 0 or 1) Default: 1.

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

- debug:

  Logical. If TRUE, prints debugging information. Default: FALSE.

- hints:

  Data frame with hints for layout adjustments. Default: NULL.

- phantoms:

  Logical. If TRUE, adds phantom parents for individuals without
  parents.

- ...:

  Additional arguments passed to \`ggplot2\` functions.
