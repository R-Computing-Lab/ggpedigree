# Add Segment Lineage Column to Pedigree Data

Adds a \`segment_lineage\` column to the pedigree data when
\`config\$segment_lineage_include\` is \`TRUE\`. This column drives
lineage-based coloring of connecting segments (e.g., paternal, maternal,
or mitochondrial lines). Each person receives a lineage value; segments
later inherit the value of the person they are anchored to. Two modes
are supported:

- **Focal/continuous**: when \`segment_lineage_focal_personID\` is
  supplied and the component is relatedness-based (additive, common
  nuclear, mitochondrial), values come from \`ped2com()\` relative to
  the focal person.

- **Group**: otherwise, the value is a discrete lineage-group factor
  (\`matID\` for maternal/mitochondrial, \`patID\` for paternal,
  \`famID\` for family). If a focal person is supplied in group mode,
  only that person's group is colored and all others become \`NA\`.

## Usage

``` r
addSegmentLineageColumn(
  ds_ped,
  config,
  famID = "famID",
  matID = "matID",
  patID = "patID",
  momID = "momID",
  dadID = "dadID",
  personID = "personID",
  fill_group_family = c("famID", "family", "family lineages", "family lines",
    "family line"),
  fill_group_maternal = c("maternal", "matID", "maternal line", "maternal lineages",
    "maternal lines"),
  fill_group_paternal = c("paternal", "patID", "paternal line", "paternal lineages",
    "paternal lines"),
  fill_group_mito = c("mitochondrial", "mtdna", "mitochondria", "mitochondrial line",
    "mitochondrial lines")
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

- famID:

  Character string specifying the column name for family IDs. Defaults
  to "famID".

- matID:

  Character string specifying the column name for maternal lines
  Defaults to "matID".

- patID:

  Character string specifying the column name for paternal lines
  Defaults to "patID".

- momID:

  Character string specifying the column name for mother IDs. Defaults
  to "momID".

- dadID:

  Character string specifying the column name for father IDs. Defaults
  to "dadID".

- personID:

  Character string specifying the column name for individual IDs.
  Defaults to "personID".

- fill_group_family:

  Character vector specifying fill types for family lineage.

- fill_group_maternal:

  Character vector specifying fill types for maternal lineage.

- fill_group_paternal:

  Character vector specifying fill types for paternal lineage.

- fill_group_mito:

  Character vector of \`segment_lineage_component\` values that map to
  the maternal/mitochondrial line (\`matID\`).

## Value

A data frame with a \`segment_lineage\` column added when applicable.
