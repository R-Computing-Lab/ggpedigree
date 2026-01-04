# Shared Default Plotting Configuration

Centralized configuration list used by all gg-based plotting functions.
Returns a named list of default settings used by all gg-based plotting
functions. This configuration can be overridden by supplying a list of
key-value pairs to plotting functions such as \`ggPedigree()\`,
\`ggRelatednessMatrix()\`, and \`ggPhenotypeByDegree()\`. Each key
corresponds to a configurable plot, layout, or aesthetic behavior.

## Usage

``` r
getDefaultPlotConfig(
  function_name = "getDefaultPlotConfig",
  personID = "personID",
  status_column = NULL,
  alpha_default = 1,
  apply_default_scales = TRUE,
  apply_default_theme = TRUE,
  segment_default_color = "black",
  color_theme = "color",
  greyscale_palette_default = c("grey10", "grey50", "grey85"),
  greyscale_low = "black",
  greyscale_mid = "grey50",
  greyscale_high = "white",
  color_palette_default = c("#440154FF", "#7fd34e", "#f1e51d"),
  color_palette_low = "#000004FF",
  color_palette_mid = "#56106EFF",
  color_palette_high = "#FCFDBFFF",
  color_scale_midpoint = 0.5,
  color_scale_theme = "ggthemes::calc",
  alpha = alpha_default,
  plot_title = NULL,
  plot_subtitle = NULL,
  value_rounding_digits = 5,
  code_male = 1,
  code_na = NA,
  code_unknown = NULL,
  code_female = 0,
  label_include = TRUE,
  label_column = "personID",
  label_method = "geom_text",
  label_max_overlaps = 25,
  label_nudge_x = 0,
  label_nudge_y = 0.15,
  label_nudge_y_flip = TRUE,
  label_segment_color = NA,
  label_text_angle = 0,
  label_text_size = 3,
  label_text_color = "black",
  label_text_family = "sans",
  point_size = 6,
  point_scale_by_pedigree = TRUE,
  outline_include = FALSE,
  outline_multiplier = 1.25,
  outline_additional_size = 0,
  outline_alpha = 1,
  outline_color = "black",
  tooltip_include = TRUE,
  tooltip_columns = c("ID1", "ID2", "value"),
  axis_x_label = NULL,
  axis_y_label = NULL,
  axis_text_angle_x = 90,
  axis_text_angle_y = 0,
  axis_text_size = 9,
  axis_text_color = "black",
  axis_text_family = "sans",
  generation_height = 1,
  generation_width = 1,
  ped_packed = TRUE,
  ped_align = TRUE,
  ped_width = 15,
  segment_linewidth = 0.5,
  segment_linetype = 1,
  segment_lineend = "round",
  segment_linejoin = "round",
  segment_scale_by_pedigree = FALSE,
  segment_offspring_color = segment_default_color,
  segment_parent_color = segment_default_color,
  segment_self_color = segment_default_color,
  segment_sibling_color = segment_default_color,
  segment_spouse_color = segment_default_color,
  segment_mz_color = segment_default_color,
  segment_mz_linetype = segment_linetype,
  segment_mz_alpha = 1,
  segment_mz_t = 0.6,
  segment_self_linetype = "dotdash",
  segment_self_linewidth = 0.5 * segment_linewidth,
  segment_self_alpha = 0.5,
  segment_self_angle = 90,
  segment_self_curvature = -0.2,
  sex_color_include = TRUE,
  sex_legend_title = "Sex",
  sex_shape_labels = c("Female", "Male", "Unknown"),
  sex_color_palette = color_palette_default,
  sex_shape_female = 16,
  sex_shape_male = 15,
  sex_shape_unknown = 18,
  sex_shape_values = NULL,
  sex_shape_include = TRUE,
  sex_legend_show = FALSE,
  status_include = TRUE,
  status_code_affected = 1,
  status_code_unaffected = 0,
  status_label_affected = "Affected",
  status_label_unaffected = "Unaffected",
  status_alpha_affected = 1,
  status_alpha_unaffected = 0,
  status_color_palette = c(color_palette_default[1], color_palette_default[2]),
  status_color_affected = "black",
  status_color_unaffected = color_palette_default[2],
  status_shape_affected = 4,
  status_legend_title = "Affected",
  status_legend_show = FALSE,
  overlay_shape = 4,
  overlay_code_affected = 1,
  overlay_code_unaffected = 0,
  overlay_label_affected = "Affected",
  overlay_label_unaffected = "Unaffected",
  overlay_alpha_affected = 1,
  overlay_alpha_unaffected = 0,
  overlay_color = "black",
  overlay_include = FALSE,
  overlay_legend_title = "Overlay",
  overlay_legend_show = FALSE,
  focal_fill_include = FALSE,
  focal_fill_legend_show = TRUE,
  focal_fill_personID = 1,
  focal_fill_legend_title = "Focal Fill",
  focal_fill_high_color = "#FDE725FF",
  focal_fill_mid_color = "#9F2A63FF",
  focal_fill_low_color = "#0D082AFF",
  focal_fill_scale_midpoint = color_scale_midpoint,
  focal_fill_method = "gradient",
  focal_fill_component = "additive",
  focal_fill_n_breaks = NULL,
  focal_fill_na_value = "black",
  focal_fill_shape = 21,
  focal_fill_force_zero = FALSE,
  focal_fill_use_log = FALSE,
  focal_fill_hue_range = c(0, 360),
  focal_fill_chroma = 50,
  focal_fill_lightness = 50,
  focal_fill_hue_direction = "horizontal",
  focal_fill_viridis_option = "D",
  focal_fill_viridis_begin = 0,
  focal_fill_viridis_end = 1,
  focal_fill_viridis_direction = 1,
  focal_fill_color_values = c("#052f60", "#e69f00", "#56b4e9", "#009e73", "#f0e442",
    "#0072b2", "#d55e00", "#cc79a7"),
  focal_fill_labels = c("Low", "Mid", "High"),
  filter_n_pairs = 500,
  filter_degree_min = 0,
  filter_degree_max = 7,
  drop_classic_kin = FALSE,
  drop_non_classic_sibs = TRUE,
  use_only_classic_kin = TRUE,
  use_relative_degree = TRUE,
  group_by_kin = TRUE,
  match_threshold_percent = 10,
  max_degree_levels = 12,
  grouping_column = "mtdna_factor",
  annotate_include = TRUE,
  annotate_x_shift = -0.1,
  annotate_y_shift = 0.005,
  ci_include = TRUE,
  ci_ribbon_alpha = 0.3,
  tile_color_palette = c("white", "gold", "red"),
  tile_interpolate = TRUE,
  tile_color_border = NA,
  tile_cluster = TRUE,
  tile_geom = "geom_tile",
  tile_na_rm = FALSE,
  tile_linejoin = "mitre",
  matrix_diagonal_include = TRUE,
  matrix_upper_triangle_include = FALSE,
  matrix_lower_triangle_include = TRUE,
  matrix_sparse = FALSE,
  matrix_isChild_method = "partialparent",
  return_static = TRUE,
  return_widget = FALSE,
  return_interactive = FALSE,
  return_mid_parent = FALSE,
  hints = NULL,
  relation = NULL,
  debug = FALSE,
  override_many2many = FALSE,
  optimize_plotly = TRUE,
  recode_missing_ids = TRUE,
  recode_missing_sex = TRUE,
  add_phantoms = FALSE,
  ...
)
```

## Arguments

- function_name:

  The name of the function calling this configuration.

- personID:

  The column name for person identifiers in the data.

- status_column:

  The column name for affected status in the data.

- alpha_default:

  Default alpha transparency level.

- apply_default_scales:

  Whether to apply default color scales.

- apply_default_theme:

  Whether to apply default ggplot2 theme.

- segment_default_color:

  A character string for the default color of segments in the plot.

- color_theme:

  Theme mode controlling default palettes. Options: "color" (default) or
  "greyscale".

- greyscale_palette_default:

  Default discrete greyscale palette used when color_theme="greyscale".

- greyscale_low:

  Greyscale low color for continuous gradients when
  color_theme="greyscale".

- greyscale_mid:

  Greyscale midpoint color for continuous gradients when
  color_theme="greyscale".

- greyscale_high:

  Greyscale high color for continuous gradients when
  color_theme="greyscale".

- color_palette_default:

  A character vector of default colors for the plot.

- color_palette_low:

  Color for the low end of a gradient.

- color_palette_mid:

  Color for the midpoint of a gradient.

- color_palette_high:

  Color for the high end of a gradient.

- color_scale_midpoint:

  Midpoint value for continuous color scales.

- color_scale_theme:

  Name of the color scale used (e.g., "ggthemes::calc").

- alpha:

  Default alpha transparency for plot elements.

- plot_title:

  Main title of the plot.

- plot_subtitle:

  Subtitle of the plot.

- value_rounding_digits:

  Number of digits to round displayed values.

- code_male:

  Integer/string code for males in data. Default is 1.

- code_na:

  optional Integer/string code for missing values in data. Default is
  NA.

- code_unknown:

  optional Integer/string code for unknown sex in data. Default is NULL.

- code_female:

  optional Integer/string code for females in data. Default is 0.

- label_include:

  Whether to display labels on plot points.

- label_column:

  Column to use for text labels.

- label_method:

  Method used for labeling (e.g., ggrepel, geom_text).

- label_max_overlaps:

  Maximum number of overlapping labels.

- label_nudge_x:

  Horizontal nudge for label text.

- label_nudge_y:

  Vertical nudge for label text.

- label_nudge_y_flip:

  TRUE. Whether to flip the nudge y value to be negative. The plot is
  reversed vertically, so this is needed to nudge labels up instead of
  down.

- label_segment_color:

  Segment color for label connectors.

- label_text_angle:

  Text angle for labels.

- label_text_size:

  Font size for labels.

- label_text_color:

  Color of the label text.

- label_text_family:

  Font family for label text.

- point_size:

  Size of points drawn in plot.

- point_scale_by_pedigree:

  Whether to scale point sizes by pedigree size.

- outline_include:

  Whether to include outlines around points.

- outline_multiplier:

  Multiplier to compute outline size from point size.

- outline_additional_size:

  Additional size added to outlines.

- outline_alpha:

  Alpha transparency for point outlines.

- outline_color:

  Color used for point outlines.

- tooltip_include:

  Whether tooltips are shown in interactive plots.

- tooltip_columns:

  Columns to include in tooltips.

- axis_x_label:

  Label for the X-axis.

- axis_y_label:

  Label for the Y-axis.

- axis_text_angle_x:

  Angle of X-axis text.

- axis_text_angle_y:

  Angle of Y-axis text.

- axis_text_size:

  Font size of axis text.

- axis_text_color:

  Color of axis text.

- axis_text_family:

  Font family for axis text.

- generation_height:

  Vertical spacing of generations.

- generation_width:

  Horizontal spacing of generations.

- ped_packed:

  Whether the pedigree should use packed layout.

- ped_align:

  Whether to align pedigree generations.

- ped_width:

  Plot width of the pedigree block.

- segment_linewidth:

  Line width for segments. Default is 0.5.

- segment_linetype:

  Line type for segments. Default is 1 (solid).

- segment_lineend:

  Line end type for segments. Default is "round".

- segment_linejoin:

  Line join type for segments. Default is "round".

- segment_scale_by_pedigree:

  Whether to scale segment sizes by pedigree size. Default is FALSE.

- segment_offspring_color:

  Color for offspring segments. Default uses segment_default_color.

- segment_parent_color:

  Color for parent segments. Default uses segment_default_color.

- segment_self_color:

  Color for self-loop segments. Default uses segment_default_color.

- segment_sibling_color:

  Color for sibling segments. Default uses segment_default_color.

- segment_spouse_color:

  Color for spouse segments. Default uses segment_default_color.

- segment_mz_color:

  Color for monozygotic twin segments. Default uses
  segment_default_color.

- segment_mz_linetype:

  Line type for MZ segments. Default uses segment_linetype.

- segment_mz_alpha:

  Alpha for MZ segments. Default is 1.

- segment_mz_t:

  Tuning parameter for MZ segment layout. Default is 0.6.

- segment_self_linetype:

  Line type for self-loop segments. Default is "dotdash".

- segment_self_linewidth:

  Width of self-loop segment lines. Default is half of
  segment_linewidth.

- segment_self_alpha:

  Alpha value for self-loop segments. Default is 0.5.

- segment_self_angle:

  Angle of self-loop segment. Default is 90 degrees.

- segment_self_curvature:

  Curvature of self-loop segment. Default is -0.2.

- sex_color_include:

  Whether to color nodes by sex. Default is TRUE.

- sex_legend_title:

  Title of the sex legend.

- sex_shape_labels:

  Labels used in sex legend.

- sex_color_palette:

  A character vector of colors for sex. Default uses
  color_palette_default.

- sex_shape_female:

  Shape for female nodes. Default is 16 (circle).

- sex_shape_male:

  Shape for male nodes. Default is 15 (square).

- sex_shape_unknown:

  Shape for unknown sex nodes. Default is 18 (diamond).

- sex_shape_values:

  A named vector mapping sex codes to shapes.

- sex_shape_include:

  Whether to display the shape for sex variables

- sex_legend_show:

  Whether to display sex in the legend or not.

- status_include:

  Whether to display affected status.

- status_code_affected:

  Value that encodes affected status.

- status_code_unaffected:

  Value that encodes unaffected status.

- status_label_affected:

  Label for affected status.

- status_label_unaffected:

  Label for unaffected status.

- status_alpha_affected:

  Alpha for affected individuals.

- status_alpha_unaffected:

  Alpha for unaffected individuals. Default is 0 (transparent).

- status_color_palette:

  A character vector of colors for affected status.

- status_color_affected:

  Color for affected individuals.

- status_color_unaffected:

  Color for unaffected individuals.

- status_shape_affected:

  Shape for affected individuals.

- status_legend_title:

  Title of the status legend.

- status_legend_show:

  Whether to show the status legend.

- overlay_shape:

  Shape used for overlaying points in the plot. Default is 4 (cross).

- overlay_code_affected:

  Code for affected individuals in overlay. Default is 1.

- overlay_code_unaffected:

  Code for unaffected individuals in overlay. Default is 0.

- overlay_label_affected:

  Label for affected individuals in overlay. Default is "Affected".

- overlay_label_unaffected:

  Label for unaffected individuals in overlay. Default is "Unaffected".

- overlay_alpha_affected:

  Alpha for affected individuals in overlay. Default is 1.

- overlay_alpha_unaffected:

  Alpha for unaffected individuals in overlay. Default is 0.

- overlay_color:

  Color for overlay points. Default is "black".

- overlay_include:

  Whether to include overlay points in the plot. Default is FALSE.

- overlay_legend_title:

  Title of the overlay legend. Default is "Overlay".

- overlay_legend_show:

  Whether to show the overlay legend. Default is FALSE.

- focal_fill_include:

  Whether to fill focal individuals. Default is FALSE.

- focal_fill_legend_show:

  Whether to show legend for focal fill. Default is TRUE.

- focal_fill_personID:

  ID of focal individual. Default is 1.

- focal_fill_legend_title:

  Title of focal fill legend.

- focal_fill_high_color:

  High-end color for focal gradient.

- focal_fill_mid_color:

  Midpoint color for focal gradient.

- focal_fill_low_color:

  Low-end color for focal gradient.

- focal_fill_scale_midpoint:

  Midpoint for focal fill scale. Default uses color_scale_midpoint.

- focal_fill_method:

  Method used for focal fill gradient. Options are 'steps', 'steps2',
  'step', 'step2', 'viridis_c', 'viridis_d', 'viridis_b', 'manual',
  'hue', 'gradient2', 'gradient'.

- focal_fill_component:

  Component type for focal fill.

- focal_fill_n_breaks:

  Number of breaks in focal fill scale.

- focal_fill_na_value:

  Color for NA values in focal fill.

- focal_fill_shape:

  Shape used for focal fill points.

- focal_fill_force_zero:

  Whether to force zero to NA in focal fill.

- focal_fill_use_log:

  Whether to use log scale for focal fill.

- focal_fill_hue_range:

  Hue range for focal fill colors.

- focal_fill_chroma:

  Chroma value for focal fill colors.

- focal_fill_lightness:

  Lightness value for focal fill colors.

- focal_fill_hue_direction:

  Direction of focal fill gradient.

- focal_fill_viridis_option:

  Option for viridis color scale.

- focal_fill_viridis_begin:

  Start of viridis color scale.

- focal_fill_viridis_end:

  End of viridis color scale.

- focal_fill_viridis_direction:

  Direction of viridis color scale (1 for left to right, -1 for right to
  left).

- focal_fill_color_values:

  A character vector of colors for focal fill.

- focal_fill_labels:

  Labels for focal fill colors.

- filter_n_pairs:

  Threshold to filter maximum number of pairs.

- filter_degree_min:

  Minimum degree value used in filtering.

- filter_degree_max:

  Maximum degree value used in filtering.

- drop_classic_kin:

  Whether to exclude classic kin categories.

- drop_non_classic_sibs:

  Whether to exclude non-classic sibs.

- use_only_classic_kin:

  Whether to restrict analysis to classic kinship.

- use_relative_degree:

  Whether to use relative degrees instead of absolute.

- group_by_kin:

  Whether to group output by kinship group.

- match_threshold_percent:

  Kinbin matching threshold as a percentage.

- max_degree_levels:

  Maximum number of degree levels to show.

- grouping_column:

  Name of column used for grouping.

- annotate_include:

  Whether to include annotations.

- annotate_x_shift:

  Horizontal shift applied to annotation text.

- annotate_y_shift:

  Vertical shift applied to annotation text.

- ci_include:

  Whether to show confidence intervals.

- ci_ribbon_alpha:

  Alpha level for CI ribbons.

- tile_color_palette:

  Color palette for matrix plots. Default is c("white", "gold", "red").

- tile_interpolate:

  Whether to interpolate colors in matrix tiles.

- tile_color_border:

  Color border for matrix tiles. Default is NA (no border).

- tile_cluster:

  Whether to sort by clusters the matrix.

- tile_geom:

  Geometry type for matrix tiles (e.g., "geom_tile", "geom_raster").

- tile_na_rm:

  Whether to remove NA values in matrix tiles. Default is FALSE.

- tile_linejoin:

  Line join type for matrix tiles. Default is "mitre".

- matrix_diagonal_include:

  Whether to include diagonal in matrix plots. Default is TRUE.

- matrix_upper_triangle_include:

  Whether to include upper triangle in matrix plots.

- matrix_lower_triangle_include:

  Whether to include lower triangle in matrix plots.

- matrix_sparse:

  Whether matrix input is sparse.

- matrix_isChild_method:

  Method used for isChild matrix derivation. Options are
  "partialparent", "fullparent", "anyparent".

- return_static:

  Whether to return a static plot.

- return_widget:

  Whether to return a widget object.

- return_interactive:

  Whether to return an interactive plot.

- return_mid_parent:

  Whether to return mid_parent values in the plot.

- hints:

  Optional hints to pass along to kinship2::autohint

- relation:

  Optional relation to pass along to kinship2::pedigree

- debug:

  Whether to enable debugging mode.

- override_many2many:

  Whether to override many-to-many link logic.

- optimize_plotly:

  Whether to optimize the plotly output for speed.

- recode_missing_ids:

  Whether to recode 0s as missing IDs in the pedigree. Default is TRUE.

- recode_missing_sex:

  Whether to recode missing sex codes in the pedigree. Default is TRUE.

- add_phantoms:

  Whether to add phantom parents for individuals without parents.

- ...:

  Additional arguments for future extensibility.

## Value

A named list of default plotting and layout parameters.

## See also

buildPlotConfig, vignette("v10_configuration")
