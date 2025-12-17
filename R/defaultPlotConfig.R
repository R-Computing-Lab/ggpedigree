#' @title Shared Default Plotting Configuration
#' @description Centralized configuration list used by all gg-based plotting functions.
#' Returns a named list of default settings used by all gg-based plotting functions.
#' This configuration can be overridden by supplying a list of key-value pairs to
#' plotting functions such as `ggPedigree()`, `ggRelatednessMatrix()`, and `ggPhenotypeByDegree()`.
#' Each key corresponds to a configurable plot, layout, or aesthetic behavior.
#' @param color_palette_default A character vector of default colors for the plot.
#' @param segment_default_color A character string for the default color of segments in the plot.
#' @param function_name The name of the function calling this configuration.
#' @param personID The column name for person identifiers in the data.
#' @param status_column The column name for affected status in the data.
#' @param overlay_shape The shape used for overlaying points in the plot.
#' @param color_scale_midpoint Midpoint value for continuous color scales.
#' @param alpha_default Default alpha transparency level.
#' @param apply_default_scales Whether to apply default color scales.
#' @param apply_default_theme Whether to apply default ggplot2 theme.
#' @param color_palette_low Color for the low end of a gradient.
#' @param color_palette_mid Color for the midpoint of a gradient.
#' @param color_palette_high Color for the high end of a gradient.
#' @param color_scale_theme Name of the color scale used (e.g., "ggthemes::calc").
#' @param alpha Default alpha transparency for plot elements.
#' @param plot_title Main title of the plot.
#' @param plot_subtitle Subtitle of the plot.
#' @param value_rounding_digits Number of digits to round displayed values.
#' @param code_male Integer/string code for males in data.
#' @param code_na optional Integer/string code for missing values in data.
#' @param code_female  optional Integer/string code for females in data.
#' @param code_unknown  optional Integer/string code for unknown
#' @param filter_n_pairs Threshold to filter maximum number of pairs.
#' @param filter_degree_min Minimum degree value used in filtering.
#' @param filter_degree_max Maximum degree value used in filtering.
#' @param drop_classic_kin Whether to exclude classic kin categories.
#' @param drop_non_classic_sibs Whether to exclude non-classic sibs.
#' @param use_only_classic_kin Whether to restrict analysis to classic kinship.
#' @param use_relative_degree Whether to use relative degrees instead of absolute.
#' @param group_by_kin Whether to group output by kinship group.
#' @param match_threshold_percent Kinbin matching threshold as a percentage.
#' @param max_degree_levels Maximum number of degree levels to show.
#' @param grouping_column Name of column used for grouping.
#' @param annotate_include Whether to include annotations.
#' @param annotate_x_shift Horizontal shift applied to annotation text.
#' @param annotate_y_shift Vertical shift applied to annotation text.
#' @param label_include Whether to display labels on plot points.
#' @param label_column Column to use for text labels.
#' @param label_method Method used for labeling (e.g., ggrepel, geom_text).
#' @param label_max_overlaps Maximum number of overlapping labels.
#' @param label_nudge_x Horizontal nudge for label text.
#' @param label_nudge_y Vertical nudge for label text.
#' @param label_nudge_y_flip TRUE. Whether to flip the nudge y value to be negative. The plot is reversed vertically, so this is needed to nudge labels up instead of down.
#' @param label_segment_color Segment color for label connectors.
#' @param label_text_angle Text angle for labels.
#' @param label_text_size Font size for labels.
#' @param label_text_color Color of the label text.
#' @param label_text_family Font family for label text.
#' @param point_size Size of points drawn in plot.
#' @param outline_include Whether to include outlines around points.
#' @param outline_multiplier Multiplier to compute outline size from point size.
#' @param outline_additional_size Additional size added to outlines.
#' @param outline_alpha Alpha transparency for point outlines.
#' @param outline_color Color used for point outlines.
#' @param tooltip_include Whether tooltips are shown in interactive plots.
#' @param tooltip_columns Columns to include in tooltips.
#' @param axis_x_label Label for the X-axis.
#' @param axis_y_label Label for the Y-axis.
#' @param axis_text_angle_x Angle of X-axis text.
#' @param axis_text_angle_y Angle of Y-axis text.
#' @param axis_text_size Font size of axis text.
#' @param axis_text_color Color of axis text.
#' @param axis_text_family Font family for axis text.
#' @param generation_height Vertical spacing of generations.
#' @param generation_width Horizontal spacing of generations.
#' @param ped_packed Whether the pedigree should use packed layout.
#' @param ped_align Whether to align pedigree generations.
#' @param ped_width Plot width of the pedigree block.
#' @param segment_linewidth Line width for segments.
#' @param segment_linetype Line type for segments.
#' @param segment_lineend Line end type for segments.
#' @param segment_linejoin Line join type for segments.
#' @param segment_offspring_color Color for offspring segments.
#' @param segment_parent_color Color for parent segments.
#' @param segment_self_color Color for self-loop segments.
#' @param segment_sibling_color Color for sibling segments.
#' @param segment_spouse_color Color for spouse segments.
#' @param segment_mz_color Color for monozygotic twin segments.
#' @param segment_mz_linetype Line type for MZ segments.
#' @param segment_mz_alpha Alpha for MZ segments.
#' @param segment_mz_t Tuning parameter for MZ segment layout.
#' @param segment_self_linetype Line type for self-loop segments.
#' @param segment_self_alpha Alpha value for self-loop segments.
#' @param segment_self_angle Angle of self-loop segment.
#' @param segment_self_curvature Curvature of self-loop segment.
#' @param segment_self_linewidth Width of self-loop segment lines.
#' @param sex_color_include Whether to color nodes by sex.
#' @param sex_color_palette A character vector of colors for sex.
#' @param sex_legend_title Title of the sex legend.
#' @param sex_shape_labels Labels used in sex legend.
#' @param sex_shape_female Shape for female nodes.
#' @param sex_shape_male Shape for male nodes.
#' @param sex_shape_unknown Shape for unknown sex nodes.
#' @param sex_shape_include Whether to display the shape for sex variables
#' @param sex_legend_show Whether to display sex in the legend
#' @param status_include Whether to display affected status.
#' @param status_code_affected Value that encodes affected status.
#' @param status_code_unaffected Value that encodes unaffected status.
#' @param status_label_affected Label for affected status.
#' @param status_label_unaffected Label for unaffected status.
#' @param status_alpha_affected Alpha for affected individuals.
#' @param status_alpha_unaffected Alpha for unaffected individuals. Default is 0 (transparent).
#' @param status_shape_affected Shape for affected individuals.
#' @param status_color_palette A character vector of colors for affected status.
#' @param status_legend_title Title of the status legend.
#' @param status_legend_show Whether to show the status legend.
#' @param status_color_affected Color for affected individuals.
#' @param status_color_unaffected Color for unaffected individuals.
#' @param overlay_shape  Shape used for overlaying points in the plot. Default is 4 (cross).
#' @param overlay_code_affected  Code for affected individuals in overlay. Default is 1.
#' @param overlay_code_unaffected  Code for unaffected individuals in overlay. Default is 0.
#' @param overlay_label_affected  Label for affected individuals in overlay. Default is "Affected".
#' @param overlay_label_unaffected Label for unaffected individuals in overlay. Default is "Unaffected".
#' @param overlay_alpha_affected Alpha for affected individuals in overlay. Default is 1.
#' @param overlay_alpha_unaffected Alpha for unaffected individuals in overlay. Default is 0.
#' @param overlay_color  Color for overlay points. Default is "black".
#' @param overlay_include Whether to include overlay points in the plot. Default is FALSE.
#' @param overlay_legend_title  Title of the overlay legend. Default is "Overlay".
#' @param overlay_legend_show  Whether to show the overlay legend. Default is FALSE.
#' @param focal_fill_include Whether to fill focal individuals.
#' @param focal_fill_legend_show Whether to show legend for focal fill.
#' @param focal_fill_personID ID of focal individual.
#' @param focal_fill_legend_title Title of focal fill legend.
#' @param focal_fill_high_color High-end color for focal gradient.
#' @param focal_fill_mid_color Midpoint color for focal gradient.
#' @param focal_fill_low_color Low-end color for focal gradient.
#' @param focal_fill_scale_midpoint Midpoint for focal fill scale.
#' @param focal_fill_method Method used for focal fill gradient. Options are 'steps', 'steps2', 'step', 'step2', 'viridis_c', 'viridis_d', 'viridis_b', 'manual', 'hue', 'gradient2', 'gradient'.
#' @param focal_fill_component Component type for focal fill.
#' @param focal_fill_shape Shape used for focal fill points.
#' @param focal_fill_n_breaks Number of breaks in focal fill scale.
#' @param focal_fill_na_value Color for NA values in focal fill.
#' @param focal_fill_use_log Whether to use log scale for focal fill.
#' @param focal_fill_force_zero Whether to force zero to NA in focal fill.
#' @param focal_fill_hue_range Hue range for focal fill colors.
#' @param focal_fill_color_values A character vector of colors for focal fill.
#' @param focal_fill_labels Labels for focal fill colors.
#' @param focal_fill_chroma Chroma value for focal fill colors.
#' @param focal_fill_lightness Lightness value for focal fill colors.
#' @param focal_fill_hue_direction Direction of focal fill gradient.
#' @param focal_fill_viridis_option Option for viridis color scale.
#' @param focal_fill_viridis_begin Start of viridis color scale.
#' @param focal_fill_viridis_end End of viridis color scale.
#' @param focal_fill_viridis_direction Direction of viridis color scale (1 for left to right, -1 for right to left).
#' @param ci_include Whether to show confidence intervals.
#' @param ci_ribbon_alpha Alpha level for CI ribbons.
#' @param tile_color_palette Color palette for matrix plots.
#' @param tile_color_border Color border for matrix tiles.
#' @param tile_interpolate Whether to interpolate colors in matrix tiles.
#' @param tile_geom Geometry type for matrix tiles (e.g., "geom_tile", "geom_raster").
#' @param tile_cluster Whether to sort by clusters the matrix.
#' @param tile_na_rm Whether to remove NA values in matrix tiles.
#' @param tile_linejoin Line join type for matrix tiles.
#' @param matrix_diagonal_include Whether to include diagonal in matrix plots.
#' @param matrix_upper_triangle_include Whether to include upper triangle in matrix plots.
#' @param matrix_lower_triangle_include Whether to include lower triangle in matrix plots.
#' @param matrix_sparse Whether matrix input is sparse.
#' @param matrix_isChild_method Method used for isChild matrix derivation.
#' @param return_static Whether to return a static plot.
#' @param return_widget Whether to return a widget object.
#' @param return_interactive Whether to return an interactive plot.
#' @param return_mid_parent Whether to return mid_parent values in the plot.
#' @param optimize_plotly Whether to optimize the plotly output for speed.
#' @param override_many2many Whether to override many-to-many link logic.
#' @param hints Optional hints to pass along to kinship2::autohint
#' @param relation Optional relation to pass along to kinship2::pedigree
#' @param recode_missing_ids Whether to recode 0s as missing IDs in the pedigree.
#' @param debug Whether to enable debugging mode.
#' @param ... Additional arguments for future extensibility.
#' @return A named list of default plotting and layout parameters.
#' @export


getDefaultPlotConfig <- function(function_name = "getDefaultPlotConfig",
                                 personID = "personID",
                                 status_column = NULL,
                                 alpha_default = 1,
                                 # ---- General Appearance ----
                                 apply_default_scales = TRUE,
                                 apply_default_theme = TRUE,
                                 segment_default_color = "black",
                                 color_palette_default = c("#440154FF", "#FDE725FF", "#21908CFF"),
                                 color_palette_low = "#000004FF",
                                 color_palette_mid = "#56106EFF",
                                 color_palette_high = "#FCFDBFFF",
                                 color_scale_midpoint = 0.50,
                                 color_scale_theme = "ggthemes::calc", # only used in gg
                                 alpha = alpha_default,
                                 plot_title = NULL,
                                 plot_subtitle = NULL,
                                 value_rounding_digits = 5,
                                 # --- SEX ------------------------------------------------------------
                                 code_male = 1,
                                 code_na = NA,
                                 code_unknown = NULL,
                                 code_female = 0,
                                 #  code_unknown = NULL,
                                 #    recode_male = code_male,#"M",
                                 #    recode_female = code_female,# "F",
                                 #    recode_na = code_na, # NA_character,
                                 # recode_unknown = "U",
                                 # ---- Label Aesthetics ----
                                 label_include = TRUE,
                                 label_column = "personID",
                                 label_method = "geom_text", # "ggrepel",
                                 label_max_overlaps = 25,
                                 label_nudge_x = 0,
                                 label_nudge_y = 0.15,
                                 label_nudge_y_flip = TRUE, # flip the nudge y value to be negative
                                 label_segment_color = NA,
                                 label_text_angle = 0,
                                 label_text_size = 3,
                                 label_text_color = "black",
                                 label_text_family = "sans",
                                 # --- POINT / OUTLINE AESTHETICS ---------------------------------------
                                 point_size = 4,
                                 outline_include = FALSE,
                                 outline_multiplier = 1.25,
                                 outline_additional_size = 0,
                                 outline_alpha = 1,
                                 outline_color = "black",
                                 # ---- Tooltip Aesthetics ----
                                 tooltip_include = TRUE,
                                 tooltip_columns = c("ID1", "ID2", "value"),
                                 # ---- Axis and Layout Settings ----
                                 axis_x_label = NULL,
                                 axis_y_label = NULL,
                                 axis_text_angle_x = 90,
                                 axis_text_angle_y = 0,
                                 axis_text_size = 9,
                                 axis_text_color = "black",
                                 axis_text_family = "sans",
                                 # ---- Generation Scale Settings ----
                                 generation_height = 1,
                                 generation_width = 1,
                                 ped_packed = TRUE,
                                 ped_align = TRUE,
                                 ped_width = 15,
                                 # ---- Segment Drawing Options ----
                                 segment_linewidth = .5,
                                 segment_linetype = 1,
                                 segment_lineend = "round",
                                 segment_linejoin = "round",
                                 segment_offspring_color = segment_default_color,
                                 segment_parent_color = segment_default_color,
                                 segment_self_color = segment_default_color,
                                 segment_sibling_color = segment_default_color,
                                 segment_spouse_color = segment_default_color,
                                 segment_mz_color = segment_default_color,
                                 segment_mz_linetype = segment_linetype,
                                 segment_mz_alpha = 1,
                                 segment_mz_t = .6,
                                 segment_self_linetype = "dotdash",
                                 segment_self_linewidth = .5 * segment_linewidth,
                                 segment_self_alpha = 0.5,
                                 segment_self_angle = 90,
                                 segment_self_curvature = -0.2,
                                 # ---- Sex Legend and Appearance ----
                                 sex_color_include = TRUE,
                                 sex_legend_title = "Sex",
                                 sex_shape_labels = c("Female", "Male", "Unknown"),
                                 sex_color_palette = color_palette_default,
                                 sex_shape_female = 16,
                                 sex_shape_male = 15,
                                 sex_shape_unknown = 18,
                                 sex_shape_include = TRUE,
                                 sex_legend_show = TRUE,
                                 # ---- Affected Status Controls ----
                                 status_include = TRUE,
                                 status_code_affected = 1,
                                 status_code_unaffected = 0,
                                 status_label_affected = "Affected",
                                 status_label_unaffected = "Unaffected",
                                 status_alpha_affected = 1,
                                 status_alpha_unaffected = 0,
                                 status_color_palette = c(color_palette_default[1], color_palette_default[2]),
                                 # Use first color for affected,
                                 status_color_affected = "black",
                                 status_color_unaffected = color_palette_default[2],
                                 status_shape_affected = 4,
                                 status_legend_title = "Affected",
                                 status_legend_show = FALSE,
                                 # ----  overlay  Settings ----
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
                                 # ---- Focal Fill Settings ----
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
                                 focal_fill_shape = 21, # shape for focal fill points
                                 focal_fill_force_zero = FALSE, # work around that sets zero to NA so you can distinguish from low values
                                 focal_fill_use_log = FALSE,
                                 focal_fill_hue_range = c(0, 360),
                                 focal_fill_chroma = 50,
                                 focal_fill_lightness = 50,
                                 focal_fill_hue_direction = "horizontal",
                                 focal_fill_viridis_option = "D",
                                 focal_fill_viridis_begin = 0,
                                 focal_fill_viridis_end = 1,
                                 focal_fill_viridis_direction = 1, # 1 for left to right, -1 for right to left
                                 focal_fill_color_values = c( # okabe and ito
                                   "#052f60", "#e69f00", "#56b4e9", "#009e73",
                                   "#f0e442", "#0072b2", "#d55e00", "#cc79a7"
                                 ),
                                 focal_fill_labels = c("Low", "Mid", "High"),
                                 # Use first color for affected,
                                 # ---- correlation by bin ----
                                 ## ---- Filtering and Computation ----
                                 filter_n_pairs = 500,
                                 filter_degree_min = 0,
                                 filter_degree_max = 7,
                                 drop_classic_kin = FALSE,
                                 drop_non_classic_sibs = TRUE,
                                 use_only_classic_kin = TRUE,
                                 use_relative_degree = TRUE,
                                 group_by_kin = TRUE,
                                 ## ----Kinbin Settings ----
                                 match_threshold_percent = 10,
                                 max_degree_levels = 12,
                                 grouping_column = "mtdna_factor",
                                 ## ---- Annotation Settings ----
                                 annotate_include = TRUE,
                                 annotate_x_shift = -0.1,
                                 annotate_y_shift = 0.005,
                                 ## ---- Confidence Intervals
                                 ci_include = TRUE,
                                 ci_ribbon_alpha = .3,
                                 # ---- tile settings ----
                                 tile_color_palette = c("white", "gold", "red"),
                                 tile_interpolate = TRUE,
                                 tile_color_border = NA,
                                 tile_cluster = TRUE,
                                 tile_geom = "geom_tile",
                                 tile_na_rm = FALSE,
                                 tile_linejoin = "mitre",
                                 # ---- matrix settings ----
                                 matrix_diagonal_include = TRUE,
                                 matrix_upper_triangle_include = FALSE,
                                 matrix_lower_triangle_include = TRUE,
                                 matrix_sparse = FALSE,
                                 matrix_isChild_method = "partialparent",
                                 # -- Output Options ----
                                 return_static = TRUE,
                                 return_widget = FALSE,
                                 return_interactive = FALSE,
                                 return_mid_parent = FALSE,
                                 # ---- Kinship2 Options ----
                                 hints = NULL,
                                 relation = NULL,
                                 # ---- Debugging Options ----
                                 debug = FALSE,
                                 override_many2many = FALSE,
                                 optimize_plotly = TRUE,
                                 recode_missing_ids = TRUE,
                                 # ---- Future Extensibility ----
                                 ...) {
  # Ensure the color palette is a character vector
  if (!is.character(color_palette_default) ||
    length(color_palette_default) < 3) {
    stop("color_palette_default must be a character vector with at least 3 colors.")
  }
  if (!is.character(segment_default_color) ||
    length(segment_default_color) != 1) {
    stop("segment_default_color must be a single character string.")
  }

  if (!stringr::str_to_lower(function_name) %in% c(
    "ggrelatednessmatrix",
    "ggpedigree",
    "ggphenotypebydegree",
    "ggpedigreeinteractive",
    "getdefaultplotconfig"
  )) {
    stop(paste0(
      "The function ", function_name,
      " is not supported by getDefaultPlotConfig."
    ))
  }

  core_list <- list(
    # ---- General Appearance ----
    apply_default_scales = apply_default_scales,
    segment_default_color = segment_default_color,
    apply_default_theme = apply_default_theme,
    color_palette_default = color_palette_default,
    color_palette_low = color_palette_low,
    color_palette_mid = color_palette_mid,
    color_palette_high = color_palette_high,
    color_scale_midpoint = color_scale_midpoint,
    color_scale_theme = color_scale_theme, # only used in gg
    alpha = alpha,
    plot_title = plot_title,
    plot_subtitle = plot_subtitle,
    value_rounding_digits = value_rounding_digits,
    # --- SEX ------------------------------------------------------------
    code_male = code_male,
    code_na = code_na,
    code_female = code_female,
    code_unknown = ifelse(is.null(code_unknown), code_na, code_unknown),
    # recode_male = recode_male,
    #   recode_na =  recode_na,
    #  recode_female =  recode_female,
    # recode_unknown =  recode_unknown,
    # ---- Filtering and Computation ----
    filter_n_pairs = filter_n_pairs,
    filter_degree_min = filter_degree_min,
    filter_degree_max = filter_degree_max,
    drop_classic_kin = drop_classic_kin,
    drop_non_classic_sibs = drop_non_classic_sibs,
    use_only_classic_kin = use_only_classic_kin,
    use_relative_degree = use_relative_degree,
    group_by_kin = group_by_kin,

    # ----Kinbin Settings ----
    match_threshold_percent = match_threshold_percent,
    max_degree_levels = max_degree_levels,
    grouping_column = grouping_column,

    # ---- Annotation Settings ----
    annotate_include = annotate_include,
    annotate_x_shift = annotate_x_shift,
    annotate_y_shift = annotate_y_shift,

    # ---- Label Aesthetics ----
    label_include = label_include,
    label_column = label_column,
    label_method = label_method,
    label_max_overlaps = label_max_overlaps,
    label_nudge_x = label_nudge_x,
    label_nudge_y = label_nudge_y,
    label_nudge_y_flip = label_nudge_y_flip,
    label_segment_color = label_segment_color,
    label_text_angle = label_text_angle,
    label_text_size = label_text_size,
    label_text_color = label_text_color,
    label_text_family = label_text_family,

    # --- POINT / OUTLINE AESTHETICS ---------------------------------------
    point_size = point_size,
    outline_include = outline_include,
    outline_multiplier = outline_multiplier,
    outline_color = outline_color,
    outline_additional_size = outline_additional_size,
    outline_alpha = outline_alpha,

    # ---- Tooltip Aesthetics ----
    tooltip_include = tooltip_include,
    tooltip_columns = tooltip_columns,

    # ---- Axis and Layout Settings ----
    axis_x_label = axis_x_label,
    axis_y_label = axis_y_label,
    axis_text_angle_x = axis_text_angle_x,
    axis_text_angle_y = axis_text_angle_y,
    axis_text_size = axis_text_size,
    axis_text_color = axis_text_color,
    axis_text_family = axis_text_family,

    # ---- Generation Scale Settings ----
    generation_height = generation_height,
    generation_width = generation_width,


    # ---- Segment Drawing Options ----

    segment_linewidth = segment_linewidth,
    segment_linetype = segment_linetype,
    segment_lineend = segment_lineend,
    segment_linejoin = segment_linejoin,
    segment_offspring_color = ifelse(segment_default_color == "black", segment_offspring_color, segment_default_color),
    segment_parent_color = ifelse(segment_default_color == "black", segment_parent_color, segment_default_color),
    segment_self_color = ifelse(segment_default_color == "black", segment_self_color, segment_default_color),
    segment_sibling_color = ifelse(segment_default_color == "black", segment_sibling_color, segment_default_color),
    segment_spouse_color = ifelse(segment_default_color == "black", segment_spouse_color, segment_default_color),
    segment_mz_color = ifelse(segment_default_color == "black", segment_mz_color, segment_default_color),
    segment_mz_linetype = segment_mz_linetype,
    segment_mz_alpha = segment_mz_alpha,
    segment_mz_t = segment_mz_t,
    segment_self_linetype = segment_self_linetype,
    segment_self_alpha = segment_self_alpha,
    segment_self_angle = segment_self_angle,
    segment_self_curvature = segment_self_curvature,
    segment_self_linewidth = segment_self_linewidth,

    # ---- Sex Legend and Appearance ----
    sex_color_include = sex_color_include,
    sex_legend_title = sex_legend_title,
    sex_shape_labels = sex_shape_labels,
    sex_color_palette = sex_color_palette,
    sex_shape_female = sex_shape_female,
    sex_shape_male = sex_shape_male,
    sex_shape_unknown = sex_shape_unknown,
    sex_legend_show = sex_legend_show,
    sex_shape_include = sex_shape_include,
    # ---- Affected Status Controls ----
    status_include = status_include,
    status_code_affected = status_code_affected,
    status_code_unaffected = status_code_unaffected,
    status_label_affected = status_label_affected,
    status_label_unaffected = status_label_unaffected,
    status_alpha_affected = status_alpha_affected,
    status_alpha_unaffected = status_alpha_unaffected,
    status_color_palette = status_color_palette,
    status_color_affected = status_color_affected,
    status_color_unaffected = status_color_unaffected,
    status_shape_affected = status_shape_affected,
    status_legend_title = status_legend_title,
    status_legend_show = status_legend_show,

    # ----  overlay  Settings ----

    overlay_shape = overlay_shape,
    overlay_code_affected = overlay_code_affected,
    overlay_code_unaffected = overlay_code_unaffected,
    overlay_label_affected = overlay_label_affected,
    overlay_label_unaffected = overlay_label_unaffected,
    overlay_alpha_unaffected = overlay_alpha_unaffected,
    overlay_color = overlay_color,
    overlay_alpha_affected = overlay_alpha_affected,
    overlay_include = overlay_include,
    overlay_legend_title = overlay_legend_title,
    overlay_legend_show = overlay_legend_show,

    # ---- Focal Fill Settings ----
    focal_fill_include = focal_fill_include,
    focal_fill_legend_show = focal_fill_legend_show,
    focal_fill_personID = focal_fill_personID,
    focal_fill_legend_title = focal_fill_legend_title,
    focal_fill_high_color = focal_fill_high_color,
    focal_fill_mid_color = focal_fill_mid_color,
    focal_fill_low_color = focal_fill_low_color,
    focal_fill_scale_midpoint = focal_fill_scale_midpoint,
    focal_fill_method = focal_fill_method,
    focal_fill_component = focal_fill_component,
    focal_fill_n_breaks = focal_fill_n_breaks,
    focal_fill_shape = focal_fill_shape, # shape for focal fill points
    focal_fill_na_value = focal_fill_na_value,
    focal_fill_use_log = focal_fill_use_log, # use log scale for focal fill
    focal_fill_force_zero = focal_fill_force_zero, # work around that sets zero to NA so you can distinguish from low values
    focal_fill_hue_range = focal_fill_hue_range, # hue range for focal fill
    focal_fill_chroma = focal_fill_chroma, # chroma for focal fill
    focal_fill_lightness = focal_fill_lightness, # lightness for focal fill
    focal_fill_hue_direction = focal_fill_hue_direction, # direction for focal fill
    focal_fill_viridis_option = focal_fill_viridis_option,
    focal_fill_viridis_begin = focal_fill_viridis_begin,
    focal_fill_viridis_end = focal_fill_viridis_end,
    focal_fill_viridis_direction = focal_fill_viridis_direction,

    # ---- Confidence Intervals
    ci_include = ci_include,
    ci_ribbon_alpha = ci_ribbon_alpha,

    # ---- tile settings ----
    tile_color_palette = tile_color_palette,
    tile_color_border = tile_color_border,
    tile_cluster = tile_cluster,
    tile_interpolate = tile_interpolate,
    tile_geom = tile_geom,
    tile_na_rm = tile_na_rm,
    tile_linejoin = tile_linejoin,

    # ---- matrix settings ----
    matrix_sparse = matrix_sparse,
    matrix_isChild_method = matrix_isChild_method,
    matrix_diagonal_include = matrix_diagonal_include,
    matrix_upper_triangle_include = matrix_upper_triangle_include,
    matrix_lower_triangle_include = matrix_lower_triangle_include,

    # -- Output Options ----
    return_static = return_static,
    return_widget = return_widget,
    return_interactive = return_interactive,
    return_mid_parent = return_mid_parent,
    # ---- Kinship2 Options ----
    ped_packed = ped_packed,
    ped_align = ped_align,
    ped_width = ped_width,
    hints = hints,
    relation = relation,
    # ---- Debugging Options ----
    override_many2many = override_many2many,
    optimize_plotly = optimize_plotly,
    recode_missing_ids = recode_missing_ids,
    debug = debug
  )
  lc_function_name <- stringr::str_to_lower(function_name)
  if (lc_function_name %in% c("ggrelatednessmatrix")) {
    #   If the function is ggRelatednessMatrix, we need to adjust the tooltip columns
    core_list$tooltip_columns <- c("ID1", "ID2", "value")
    core_list$label_nudge_y_flip <- FALSE
    #  core_list$tile_color_palette <- c(
    #    core_list$color_palette_low,
    #   core_list$color_palette_mid,
    #   core_list$color_palette_high
    # )

    core_list$color_scale_midpoint <- 0.25
    core_list$plot_title <- "Relatedness Matrix"
    core_list$axis_x_label <- "Individual"
    core_list$axis_y_label <- core_list$axis_x_label
    core_list$label_include <- FALSE
    core_list$label_column <- "value"
    core_list$return_widget <- FALSE
    core_list$return_interactive <- FALSE
  } else if (lc_function_name %in%
    c("ggphenotypebydegree", "phenotypebydegree")) {
    core_list$point_size <- 1
    core_list$plot_title <- "Phenotypic Correlation vs Genetic Relatedness"
    core_list$return_static <- FALSE
    core_list$return_widget <- FALSE
    core_list$return_interactive <- FALSE
    core_list$label_nudge_y_flip <- FALSE
    core_list$axis_y_label <- "Phenotypic Correlation"
    core_list$axis_x_label <- "Coefficient of Genetic Variation"
    #  default_config <- list(
    #    apply_default_scales = TRUE,
    #    apply_default_theme = TRUE,
    #   point_size = 1,
    #    ci_ribbon_alpha = 0.3,

    # Filter parameters
    #   filter_n_pairs = 500,
    #  filter_degree_min = 0,
    #  filter_degree_max = 7,
    # Plotting parameters
    #    plot_title = "Phenotypic Correlation vs Genetic Relatedness",
    #    subtitle = NULL,
    #    color_scale = "ggthemes::calc",

    # Configuration parameters
    #   use_only_classic_kin = TRUE,
    #  group_by_kin = TRUE,
    #   drop_classic_kin = FALSE,
    #  drop_non_classic_sibs = TRUE,
    # Annotation parameters


    # Grouping and scaling parameters
    #  use_relative_degree = TRUE,
    #   grouping_column = "mtdna_factor",
    #    value_rounding_digits = 2,
    #   match_threshold_percent = 10,
    #    max_degree_levels = 12
    #  )
  }
  if (lc_function_name %in% c(
    "ggpedigree",
    "ggpedigreeinteractive"
  )) {
    core_list$label_method <- "geom_text" # "ggrepel"
    core_list$label_column <- personID
    core_list$label_nudge_y_flip <- TRUE
    core_list$value_rounding_digits <- 3
    # core_list$focal_fill_low_color <- core_list$color_palette_low
    # core_list$focal_fill_mid_color <- core_list$color_palette_mid
    # core_list$focal_fill_high_color <- core_list$color_palette_high
  }
  if (lc_function_name %in% c("ggpedigree")) {
    # core_list$label_method <- "ggrepel"
    core_list$return_static <- FALSE
    core_list$return_widget <- FALSE
    core_list$return_interactive <- FALSE
  }
  if (lc_function_name %in% c("ggpedigreeinteractive")) {
    core_list$tooltip_columns <- c(personID, "sex", status_column)
    core_list$label_method <- "geom_text"
    core_list$label_include <- FALSE # default to FALSE
    core_list$segment_linewidth <- 0.5 # too think
    core_list$segment_self_linewidth <- .5 * core_list$segment_linewidth
    core_list$tooltip_include <- TRUE
    core_list$return_static <- FALSE
    core_list$return_widget <- TRUE
    core_list$return_interactive <- TRUE
    core_list$segment_self_angle <- -75
    core_list$segment_self_curvature <- -0.15
  }

  return(core_list)
}

#' @title build Config
#' @description
#' This function builds a configuration list for ggPedigree plots.
#' It merges a default configuration with user-specified settings,
#' ensuring all necessary parameters are set.
#' @param default_config A list of default configuration parameters.
#' @param config A list of user-specified configuration parameters.
#' @param function_name The name of the function for which the configuration is being built.
#' @return A complete configuration list with all necessary parameters.
#'
buildPlotConfig <- function(default_config,
                            config,
                            function_name = "ggPedigree") {
  # -- Detect duplicate configuration entries --
  config_names <- names(config)
  duplicated_keys <- config_names[duplicated(config_names)]

  if (length(duplicated_keys) > 0) {
    warning(sprintf(
      "Duplicate config keys detected: %s. Later values will override earlier ones.",
      paste(unique(duplicated_keys), collapse = ", ")
    ))
  }
  # -- Detect unrecognized configuration entries --
  valid_keys <- names(formals(getDefaultPlotConfig))
  valid_keys <- setdiff(valid_keys, "function_name") # it's passed separately

  unrecognized_keys <- setdiff(config_names, valid_keys)
  if (length(unrecognized_keys) > 0) {
    warning(sprintf(
      "The following config values are not recognized by getDefaultPlotConfig(): %s",
      paste(unrecognized_keys, collapse = ", ")
    ))
  }

  # -- Merge user config with defaults --
  built_config <- utils::modifyList(default_config, config)

  built_config$label_nudge_y <- ifelse(built_config$label_nudge_y_flip,
    built_config$label_nudge_y * -1, built_config$label_nudge_y
  )

  if (stringr::str_to_lower(function_name) %in%
    c("ggpedigree", "ggpedigreeinteractive")) {
    # Set additional internal config values based on other entries
    if ("sex_shape_values" %in% names(built_config) == FALSE) {
      built_config$sex_shape_values <- c(
        built_config$sex_shape_female,
        built_config$sex_shape_male,
        built_config$sex_shape_unknown
      )
    }


    if ("status_labs" %in% names(built_config) == FALSE) {
      built_config$status_labs <- c(
        built_config$status_label_affected,
        built_config$status_label_unaffected
      )
    }
    if ("status_codes" %in% names(built_config) == FALSE) {
      built_config$status_codes <- c(
        built_config$status_code_affected,
        built_config$status_code_unaffected
      )
    }

    built_config$status_alpha_values <- stats::setNames(
      c(
        built_config$status_alpha_affected,
        built_config$status_alpha_unaffected
      ),
      built_config$status_labs
    )
    # Set color values for affected status
    built_config$status_color_values <- stats::setNames(
      c(
        built_config$status_color_palette[1],
        built_config$status_color_palette[2]
      ),
      built_config$status_labs
    )

    built_config$status_labels <- stats::setNames(
      c(
        built_config$status_label_affected,
        built_config$status_label_unaffected
      ),
      built_config$status_labs
    )
    if ("overlay_labs" %in% names(built_config) == FALSE) {
      built_config$overlay_labs <- c(
        built_config$overlay_label_affected,
        built_config$overlay_label_unaffected
      )
    }
    if ("overlay_codes" %in% names(built_config) == FALSE) {
      built_config$overlay_codes <- c(
        built_config$overlay_code_affected,
        built_config$overlay_code_unaffected
      )
    }
    built_config$overlay_alpha_values <- stats::setNames(
      c(
        built_config$overlay_alpha_affected,
        built_config$overlay_alpha_unaffected
      ),
      built_config$overlay_labs
    )
  } else if (stringr::str_to_lower(function_name) %in%
    c("ggphenotypebydegree", "phenotypebydegree")) {
    built_config$label_nudge_y_flip <- FALSE # default to TRUE for ggphenotypebydegree
  }

  return(built_config)
}
# -----
