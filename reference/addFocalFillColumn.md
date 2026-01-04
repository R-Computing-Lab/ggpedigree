# Add Focal Fill Column to Pedigree Data

Adds a \`focal_fill\` column to the pedigree data based on configuration
input. Supports additive, mitochondrial, and line-based modes. If
\`focal_fill_column\` is specified, it takes priority over inferred
modes.

## Usage

``` r
addFocalFillColumn(
  ds_ped,
  config,
  focal_fill_column = NULL,
  famID = "famID",
  matID = "matID",
  patID = "patID",
  personID = "personID",
  fill_group_family = c("famID", "family", "family lineages", "family lines",
    "family line"),
  fill_group_maternal = c("maternal", "matID", "maternal line", "maternal lineages",
    "maternal lines"),
  fill_group_paternal = c("paternal", "patID", "paternal line", "paternal lineages",
    "paternal lines")
)
```

## Arguments

- ds_ped:

  A data frame already processed by \`transformPed()\`.

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

- focal_fill_column:

  Character string specifying the column name for focal fill color.

- famID:

  Character string specifying the column name for family IDs. Defaults
  to "famID".

- matID:

  Character string specifying the column name for maternal lines
  Defaults to "matID".

- patID:

  Character string specifying the column name for paternal lines
  Defaults to "patID".

- personID:

  Character string specifying the column name for individual IDs.
  Defaults to "personID".

- fill_group_family:

  Character vector specifying fill types for family lineage.

- fill_group_maternal:

  Character vector specifying fill types for maternal lineage.

- fill_group_paternal:

  Character vector specifying fill types for paternal lineage.

## Value

A data frame with a \`focal_fill\` column added if applicable.
