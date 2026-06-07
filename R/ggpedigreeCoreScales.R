#' @title Add Scales to ggplot Pedigree Plot
#' @inheritParams ggPedigree
#' @param plotObject A ggplot object.
#' @keywords internal
#' @return A ggplot object with added scales.

.addScales <- function(plotObject,
                       config,
                       status_column = NULL,
                       focal_fill_column = NULL,
                       affected_fill_column = NULL,
                       outline_color_column = NULL) {
  # Handle affected fill mode: use fillable shapes and fill scale
  if (!is.null(affected_fill_column)) {
    affected_fill_code <- config$affected_fill_code_affected
    fill_color_affected <- config$affected_fill_color_affected
    fill_color_unaffected <- config$affected_fill_color_unaffected

    # Use fillable shapes (21=circle, 22=square, 23=diamond) for affected fill mode
    fill_shape_values <- c(
      config$affected_fill_shape_female,
      config$affected_fill_shape_male,
      config$affected_fill_shape_unknown
    )
    plotObject <- plotObject + ggplot2::scale_shape_manual(
      values = fill_shape_values,
      labels = config$sex_shape_labels
    )
    # Build fill scale: affected code gets affected color; all other levels get unaffected color
    all_levels <- levels(plotObject$data[[affected_fill_column]])
    if (is.null(all_levels)) {
      all_levels <- unique(as.character(plotObject$data[[affected_fill_column]]))
    }
    fill_vals <- stats::setNames(
      ifelse(
        all_levels == as.character(affected_fill_code),
        fill_color_affected,
        fill_color_unaffected
      ),
      all_levels
    )
    plotObject <- plotObject + ggplot2::scale_fill_manual(
      values = fill_vals,
      na.value = NA,
      guide = "none"
    )
  } else {
    # Standard shape scale
    plotObject <- plotObject + ggplot2::scale_shape_manual(
      values = config$sex_shape_values,
      labels = config$sex_shape_labels
    )
  }

  # Handle outline color column
  if (!is.null(outline_color_column)) {
    highlight_val <- as.character(config$outline_color_code_affected)
    highlight_color <- config$outline_color_affected
    default_color <- config$outline_color_unaffected

    all_levels <- levels(plotObject$data[[outline_color_column]])
    if (is.null(all_levels)) {
      all_levels <- unique(as.character(plotObject$data[[outline_color_column]]))
    }
    color_vals <- stats::setNames(
      ifelse(all_levels == highlight_val, highlight_color, default_color),
      all_levels
    )
    plotObject <- plotObject + ggplot2::scale_color_manual(
      values = color_vals,
      guide = "none"
    )
    plotObject <- plotObject + ggplot2::labs(
      shape = if (isTRUE(config$sex_legend_show)) config$sex_legend_title else NULL
    )
    return(plotObject)
  }

  # Add alpha scale for affected status if applicable
  if (!is.null(status_column) &&
    config$sex_color_include == TRUE &&
    config$status_include == TRUE) {
    plotObject <- plotObject + ggplot2::scale_alpha_manual(
      name = if (config$status_legend_show) {
        config$status_legend_title
      } else {
        NULL
      },
      values = config$status_alpha_values,
      na.translate = FALSE
    )
    if (config$status_legend_show == FALSE) {
      plotObject <- plotObject + ggplot2::guides(alpha = "none")
    }
  }


  color_mode <- .get_color_mode(config, status_column, focal_fill_column)

  plotObject <- switch(color_mode,
    sex = .add_sex_scales(plotObject, config),
    focal_fill = .add_focal_fill_scales(plotObject, config),
    status = .add_status_scales(plotObject, config),
    none = {
      plotObject + ggplot2::labs(
        shape = if (isTRUE(config$sex_legend_show)) config$sex_legend_title else NULL
      )
    }
  )

  plotObject
}


.add_sex_scales <- function(p, config) {
  if (!is.null(config$sex_color_palette)) {
    p <- p + ggplot2::scale_color_manual(
      values = config$sex_color_palette,
      labels = config$sex_shape_labels
    )
  } else {
    p <- p + ggplot2::scale_color_discrete(labels = config$sex_shape_labels)
  }

  p <- p + ggplot2::labs(
    color = config$sex_legend_title,
    shape = config$sex_legend_title
  )

  if (isFALSE(config$sex_legend_show)) {
    p <- p + ggplot2::guides(color = "none", shape = "none")
  }
  p
}

.add_status_scales <- function(p, config) {
  if (!is.null(config$status_color_palette)) {
    p <- p + ggplot2::scale_color_manual(
      values = config$status_color_values,
      labels = config$status_labels
    )
  } else {
    p <- p + ggplot2::scale_color_discrete(labels = config$status_labels)
  }

  p <- p + ggplot2::labs(
    color = config$status_legend_title,
    shape = if (isTRUE(config$sex_legend_show)) config$sex_legend_title else NULL
  )
  p
}

.add_focal_fill_scales <- function(p, config) {
  method <- config$focal_fill_method

  scale_fun <- .pick_first(
    rules = list(
      list(
        when = function() method %in% c("steps", "steps2", "step", "step2"),
        do = function() {
          ggplot2::scale_colour_steps2(
            low = config$focal_fill_low_color,
            mid = config$focal_fill_mid_color,
            high = config$focal_fill_high_color,
            midpoint = config$focal_fill_scale_midpoint,
            n.breaks = config$focal_fill_n_breaks,
            na.value = config$focal_fill_na_value,
            transform = ifelse(config$focal_fill_use_log, "log2", "identity")
          )
        }
      ),
      list(
        when = function() method %in% c("gradient2", "gradient"),
        do = function() {
          ggplot2::scale_colour_gradient2(
            low = config$focal_fill_low_color,
            mid = config$focal_fill_mid_color,
            high = config$focal_fill_high_color,
            midpoint = config$focal_fill_scale_midpoint,
            n.breaks = config$focal_fill_n_breaks,
            na.value = config$focal_fill_na_value,
            transform = ifelse(config$focal_fill_use_log, "log2", "identity")
          )
        }
      ),
      list(
        when = function() method %in% c("hue"),
        do = function() {
          ggplot2::scale_color_hue(
            h = config$focal_fill_hue_range,
            c = config$focal_fill_chroma,
            l = config$focal_fill_lightness,
            direction = config$focal_fill_hue_direction,
            na.value = config$focal_fill_na_value
          )
        }
      ),
      list(
        when = function() method %in% c("viridis_c"),
        do = function() {
          ggplot2::scale_colour_viridis_c(
            option = config$focal_fill_viridis_option,
            begin = config$focal_fill_viridis_begin,
            end = config$focal_fill_viridis_end,
            direction = config$focal_fill_viridis_direction,
            na.value = config$focal_fill_na_value,
            transform = ifelse(config$focal_fill_use_log, "log2", "identity")
          )
        }
      ),
      list(
        when = function() method %in% c("viridis_d"),
        do = function() {
          ggplot2::scale_colour_viridis_d(
            option = config$focal_fill_viridis_option,
            begin = config$focal_fill_viridis_begin,
            end = config$focal_fill_viridis_end,
            direction = config$focal_fill_viridis_direction,
            na.value = config$focal_fill_na_value
          )
        }
      ),
      list(
        when = function() method %in% c("viridis_b"),
        do = function() {
          ggplot2::scale_colour_viridis_b(
            option = config$focal_fill_viridis_option,
            begin = config$focal_fill_viridis_begin,
            end = config$focal_fill_viridis_end,
            direction = config$focal_fill_viridis_direction,
            na.value = config$focal_fill_na_value,
            transform = ifelse(config$focal_fill_use_log, "log2", "identity")
          )
        }
      ),
      list(
        when = function() method %in% c("manual"),
        do = function() {
          ggplot2::scale_color_manual(
            values = config$focal_fill_color_values,
            labels = config$focal_fill_labels
          )
        }
      )
    ),
    default = NULL
  )

  if (is.null(scale_fun)) {
    focal_fill_methods <- c(
      "steps", "steps2", "step", "step2",
      "viridis_c", "viridis_d", "viridis_b",
      "manual",
      "hue",
      "gradient2", "gradient"
    )
    stop(paste("focal_fill_method must be one of", paste(focal_fill_methods, collapse = ", ")))
  }

  p <- p + scale_fun()

  p <- p + ggplot2::labs(
    color = if (isTRUE(config$focal_fill_legend_show)) config$focal_fill_legend_title else NULL,
    shape = if (isTRUE(config$sex_legend_show)) config$sex_legend_title else NULL
  )

  if (isFALSE(config$focal_fill_legend_show)) {
    p <- p + ggplot2::guides(color = "none")
  }
  if (isFALSE(config$sex_legend_show)) {
    p <- p + ggplot2::guides(shape = "none")
  }
  p
}


#' @title Add Segment Lineage Color Scale
#' @description
#' Builds and appends the color scale used for lineage-colored segments. The
#' scale type is chosen by `config$segment_lineage_method`. Discrete methods
#' (`"viridis_d"`, `"hue"`, `"manual"`) suit lineage-group coloring; continuous
#' methods (`"viridis_c"`, `"viridis_b"`, `"gradient"`, `"gradient2"`, `"steps"`)
#' suit focal/relatedness-based coloring.
#' @param p A ggplot object.
#' @param config A configuration list.
#' @keywords internal
#' @return A ggplot object with the segment lineage color scale added.
.add_segment_lineage_scales <- function(p, config) {
  method <- config$segment_lineage_method

  discrete_methods <- c("viridis_d", "hue", "manual")
  continuous_methods <- c("viridis_c", "viridis_b", "gradient", "gradient2", "steps")


  component <- config$segment_lineage_component
  focal_id <- config$segment_lineage_focal_personID

  is_continuous_component <- component %in% c("additive", "common nuclear") ||
    (!is.null(focal_id) && component %in% c("mitochondrial", "mtdna", "mitochondria"))

  if (is_continuous_component && method %in% discrete_methods) {
    warn("Continuous segment_lineage_component requires a continuous segment_lineage_method (e.g., viridis_c, viridis_b, gradient, gradient2, steps).")
  }
  if (!is_continuous_component && method %in% continuous_methods) {
    warn("Discrete lineage groups require a discrete segment_lineage_method (e.g., viridis_d, hue, manual).")
  }
  if (identical(method, "manual") && is.null(config$segment_lineage_palette)) {
    warn("segment_lineage_method = 'manual' requires segment_lineage_palette to be provided.")
  }

  na_color <- config$segment_lineage_na_color
  title <- if (isTRUE(config$segment_lineage_legend_show)) {
    config$segment_lineage_legend_title
  } else {
    NULL
  }

  scale_fun <- .pick_first(
    rules = list(
      list(
        when = function() method %in% c("viridis_d"),
        do = function() {
          ggplot2::scale_colour_viridis_d(
            na.value = na_color, name = title
          )
        }
      ),
      list(
        when = function() method %in% c("viridis_c"),
        do = function() {
          ggplot2::scale_colour_viridis_c(
            na.value = na_color, name = title
          )
        }
      ),
      list(
        when = function() method %in% c("viridis_b"),
        do = function() {
          ggplot2::scale_colour_viridis_b(
            na.value = na_color, name = title
          )
        }
      ),
      list(
        when = function() method %in% c("hue"),
        do = function() {
          ggplot2::scale_colour_hue(na.value = na_color, name = title)
        }
      ),
      list(
        when = function() method %in% c("manual"),
        do = function() {
          ggplot2::scale_colour_manual(
            values = config$segment_lineage_palette,
            na.value = na_color, name = title
          )
        }
      ),
      list(
        when = function() method %in% c("gradient"),
        do = function() {
          ggplot2::scale_colour_gradient(na.value = na_color, name = title)
        }
      ),
      list(
        when = function() method %in% c("gradient2"),
        do = function() {
          ggplot2::scale_colour_gradient2(na.value = na_color, name = title)
        }
      ),
      list(
        when = function() method %in% c("steps", "steps2", "step", "step2"),
        do = function() {
          ggplot2::scale_colour_steps(na.value = na_color, name = title)
        }
      )
    ),
    default = NULL
  )

  if (is.null(scale_fun)) {
    segment_lineage_methods <- c(
      "viridis_d", "viridis_c", "viridis_b",
      "hue", "manual",
      "gradient", "gradient2", "steps"
    )
    warn(paste(
      "segment_lineage_method must be one of",
      paste(segment_lineage_methods, collapse = ", ")
    ))
  }

  p <- p + scale_fun()

  if (isFALSE(config$segment_lineage_legend_show)) {
    p <- p + ggplot2::guides(colour = "none")
  }
  p
}


#' @rdname dot-addScales
addScales <- .addScales
