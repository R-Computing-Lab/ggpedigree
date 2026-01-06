# Recode Missing IDs in Pedigree Data

This function recodes missing IDs in the pedigree data frame to NA. It
checks for specified missing codes (both numeric and character) in their
respective columns.

## Usage

``` r
recodeMissingIDs(
  ped,
  momID = "momID",
  dadID = "dadID",
  personID = "personID",
  famID = "famID",
  matID = "matID",
  patID = "patID",
  missing_code_numeric = 0,
  missing_code_character = c("0", "NA", "na", ""),
  config = list()
)
```

## Arguments

- ped:

  A data frame containing the pedigree data. Needs personID, momID,
  dadID, and sex columns.

- momID:

  Character string specifying the column name for mother IDs. Defaults
  to "momID".

- dadID:

  Character string specifying the column name for father IDs. Defaults
  to "dadID".

- personID:

  Character string specifying the column name for individual IDs.
  Defaults to "personID".

- famID:

  Character string specifying the column name for family IDs. Defaults
  to "famID".

- matID:

  Character string specifying the column name for maternal lines
  Defaults to "matID".

- patID:

  Character string specifying the column name for paternal lines
  Defaults to "patID".

- missing_code_numeric:

  Numeric code representing missing IDs (default is 0).

- missing_code_character:

  Character vector representing missing IDs (default is c("0", "NA",
  "na", "")).

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

A data frame with missing IDs recoded to NA.
