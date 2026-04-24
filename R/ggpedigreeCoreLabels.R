
#' @title Add Labels to ggplot Pedigree Plot
#' @inheritParams ggPedigree
#' @inheritParams .addScales
#'
#' @return A ggplot object with added labels.
#' @keywords internal
#'
.addLabels <- function(plotObject, config) {
  ggrepel_label_methods <- c("geom_text_repel", "ggrepel", "geom_label_repel")
  if (!requireNamespace("ggrepel", quietly = TRUE) &&
      config$label_method %in% ggrepel_label_methods) {
    warning(
      "The 'ggrepel' package is required for label methods ",
      "'geom_text_repel', 'ggrepel', and 'geom_label_repel'. ",
      "Please install it using install.packages('ggrepel')."
    )

    config$label_method <- "geom_text" # fallback to geom_text if ggrepel is not available
  }

  if (config$label_method %in% ggrepel_label_methods &&
      requireNamespace("ggrepel", quietly = TRUE)) {
    # If ggrepel is available, use geom_text_repel or geom_label_repel
    # for better label placement and avoidance of overlaps
    plotObject <- plotObject +
      ggrepel::geom_text_repel(
        ggplot2::aes(label = !!rlang::sym(config$label_column)),
        nudge_y = config$label_nudge_y * config$generation_height,
        nudge_x = config$label_nudge_x * config$generation_width,
        size = config$label_text_size,
        color = config$label_text_color,
        na.rm = TRUE,
        max.overlaps = config$label_max_overlaps,
        segment.size = config$segment_linewidth * .5,
        angle = config$label_text_angle,
        family = config$label_text_family,
        segment.color = config$label_segment_color
      )
  } else if (config$label_method == "geom_label") {
    plotObject <- plotObject +
      ggplot2::geom_label(
        ggplot2::aes(label = !!rlang::sym(config$label_column)),
        nudge_y = config$label_nudge_y * config$generation_height,
        nudge_x = config$label_nudge_x * config$generation_width,
        color = config$label_text_color,
        size = config$label_text_size,
        family = config$label_text_family,
        angle = config$label_text_angle,
        na.rm = TRUE
      )
  } else if (config$label_method == "geom_text") {
    plotObject <- plotObject +
      ggplot2::geom_text(
        ggplot2::aes(label = !!rlang::sym(config$label_column)),
        nudge_y = config$label_nudge_y * config$generation_height,
        nudge_x = config$label_nudge_x * config$generation_width,
        color = config$label_text_color,
        family = config$label_text_family,
        size = config$label_text_size,
        angle = config$label_text_angle,
        na.rm = TRUE
      )
  } else {
    warning(
      "Invalid label_method specified in config. Must be one of ",
      "'geom_text_repel', 'ggrepel', 'geom_label_repel', 'geom_label', or 'geom_text'."
    )
  }
  plotObject
}

#' @rdname dot-addLabels
addLabels <- .addLabels
