# defaultPlotConfig.R
#' @title Shared Default Plotting Configuration
#' @description Centralized configuration list used by all gg-based plotting functions.
#' @param color_palette_default A character vector of default colors for the plot.
#' @param segment_default_color A character string for the default color of segments in the plot.
#' @param function_name The name of the function calling this configuration.
#' @param personID The column name for person identifiers in the data.
#' @param status_column The column name for affected status in the data.
#' @param ... Additional arguments for future extensibility.
#' @return A named list of default plotting and layout parameters.
#' @export


getDefaultPlotConfig <- function(color_palette_default =
                                   c("#440154FF", "#FDE725FF", "#21908CFF"),
                                 segment_default_color = "black",
                                 function_name = "getDefaultPlotConfig",
                                 personID = NULL,
                                 status_column = NULL,
                                 ...
                                 ) {
  # Ensure the color palette is a character vector
  if (!is.character(color_palette_default) || length(color_palette_default) < 3) {
    stop("color_palette_default must be a character vector with at least 3 colors.")
  }
  if (!is.character(segment_default_color) || length(segment_default_color) != 1) {
    stop("segment_default_color must be a single character string.")
  }
  core_list <- list(
    # ---- General Appearance ----
    apply_default_scales       = TRUE,
    apply_default_theme        = TRUE,
    color_palette_default      = color_palette_default,
    plot_title                 = NULL,
    plot_subtitle              = NULL,
    value_rounding_digits      = 2,
    # --- SEX ------------------------------------------------------------
    code_male = 1,

    # ---- Filtering and Computation ----
    filter_n_pairs             = 500,
    filter_degree_min          = 0,
    filter_degree_max          = 7,

    drop_classic_kin           = FALSE,
    drop_non_classic_sibs      = TRUE,

    only_classic_kin           = TRUE,
    use_relative_degree        = TRUE,

    # ----Kinbin Settings ----
    match_threshold_percent    = 10,
    max_degree_levels          = 12,

    grouping_column            = "mtdna_factor",


    # ---- Annotation Settings ----
    annotate_include           = TRUE,
    annotate_x_shift           = -0.1,
    annotate_y_shift           = 0.005,

    # ---- Label Aesthetics ----
    label_include              = TRUE,
    label_column               = "personID",
    label_method               = "ggrepel",
    label_max_overlaps         = 15,
    label_nudge_x              = 0,
    label_nudge_y              = -0.10,
    label_segment_color        = NA,
    label_text_angle           = 0,
    label_text_size            = 2,
    label_text_color           = "black",

    # --- POINT / OUTLINE AESTHETICS ---------------------------------------
    point_size                 = 4,
    outline_include = FALSE,
    outline_multiplier         = 1.25,
    outline_color             = "black",

    # ---- Tooltip Aesthetics ----
    tooltip_include            = TRUE,
    tooltip_columns            = c("ID1", "ID2", "value"),

    # ---- Axis and Layout Settings ----
    axis_x_label               = NULL,
    axis_y_label               = NULL,
    axis_text_angle_x          = 90,
    axis_text_angle_y          = 0,
    axis_text_size             = 8,
    axis_text_color            = "black",
    generation_height = 1,
    generation_width = 1,


    # ---- Segment Drawing Options ----
    segment_linewidth          = 0.5,
    segment_linetype           = 1,
    segment_lineend            = "round",
    segment_linejoin           = "round",
    segment_offspring_color    = segment_default_color,
    segment_parent_color       = segment_default_color,
    segment_self_color         = segment_default_color,
    segment_sibling_color      = segment_default_color,
    segment_spouse_color       = segment_default_color,
    segment_self_linetype      = "dotdash",
    segment_self_angle         = 90,
    segment_self_curvature     = -0.2,

    # ---- Sex Legend and Appearance ----
    sex_color_include          = TRUE,
    sex_legend_title           = "Sex",
    sex_shape_labels           = c("Female", "Male", "Unknown"),
    sex_color_palette          = color_palette_default,
    sex_shape_female           = 16,
    sex_shape_male             = 15,
    sex_shape_unknown          = 18,

    # ---- Affected Status Controls ----
    status_include             = TRUE,
    status_code_affected       = 1,
    status_code_unaffected     = 0,
    status_label_affected      = "Affected",
    status_label_unaffected    = "Unaffected",
    status_alpha_affected      = 1,
    status_alpha_unaffected    = 0,
    status_color_palette       = c(color_palette_default[1], color_palette_default[2]),# Use first color for affected,
    status_affected_shape      = 4,
    status_legend_title        = "Affected",
    status_legend_show         = FALSE,

    # -- Output Options ----
    return_static              = TRUE,
    return_widget              = FALSE,
    return_interactive         = FALSE
  )

 if(stringr::str_to_lower(function_name) %in% c( "ggrelatednessmatrix")) {
#   If the function is ggRelatednessMatrix, we need to adjust the tooltip columns
    core_list$tooltip_columns <- c("ID1", "ID2", "value")
 }
  if (stringr::str_to_lower(function_name)  %in% c("ggpedigree","ggpedigreeinteractive") ){
    core_list$label_method <-  "ggrepel"
  }

  if (stringr::str_to_lower(function_name) %in% c("ggpedigreeinteractive")) {
    core_list$tooltip_columns <- c(personID, "sex", status_column)
    core_list$label_method <-  "geom_text"
    core_list$label_include <-  FALSE # default to FALSE
    core_list$tooltip_include <-  TRUE
    core_list$return_static <-  FALSE
    core_list$return_widget <- TRUE
    core_list$return_interactive <- TRUE
  }
  return(core_list)
}
