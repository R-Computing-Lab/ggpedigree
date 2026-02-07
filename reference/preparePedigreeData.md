# Prepare Pedigree Data

This function checks and prepares the pedigree data frame for use in
ggPedigree.

## Usage

``` r
preparePedigreeData(
  ped,
  famID = "famID",
  personID = "personID",
  momID = "momID",
  dadID = "dadID",
  matID = "matID",
  patID = "patID",
  config = list(focal_fill_include = TRUE, focal_fill_component = "maternal",
    recode_missing_ids = TRUE, add_phantoms = FALSE, code_male = "M", code_female = "F",
    code_na = NA),
  fill_group_paternal = c("paternal", "patID", "paternal line", "paternal lineages",
    "paternal lines"),
  fill_group_maternal = c("maternal", "matID", "maternal line", "maternal lineages",
    "maternal lines"),
  fill_group_family = c("family", "famID", "family line", "family lineages",
    "family lines"),
  status_column = NULL,
  focal_fill_column = NULL,
  sexVar = "sex"
)
```

## Arguments

- ped:

  A data frame containing the pedigree data. Needs personID, momID,
  dadID, and sex columns.

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

- matID:

  Character string specifying the column name for maternal lines
  Defaults to "matID".

- patID:

  Character string specifying the column name for paternal lines
  Defaults to "patID".

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

- fill_group_paternal:

  A character vector specifying which paternal components to fill.

- fill_group_maternal:

  A character vector specifying which maternal components to fill.

- fill_group_family:

  A character vector specifying the family fill group names.

- status_column:

  Character string specifying the column name for affected status.
  Defaults to NULL.

- focal_fill_column:

  Character string specifying the column name for focal fill color.

- sexVar:

  Character string specifying the column name for sex. Defaults to
  "sex".

## Value

A data frame with the prepared pedigree data.
