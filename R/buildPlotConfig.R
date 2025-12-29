#' @title build Config
#' @description
#' This function builds a configuration list for ggPedigree plots.
#' It merges a default configuration with user-specified settings,
#' ensuring all necessary parameters are set.
#' @param default_config A list of default configuration parameters.
#' @param config A list of user-specified configuration parameters.
#' @param function_name The name of the function for which the configuration is being built.
#' @param pedigree_size Size of the pedigree, used for point scaling.
#' @return A complete configuration list with all necessary parameters.
#'
buildPlotConfig <- function(default_config,
                            config,
                            function_name = "ggPedigree",
                            pedigree_size = NULL) {
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


  # -- Post-process certain config entries --


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
    if (built_config$point_scale_by_pedigree == TRUE) {
      if (is.null(pedigree_size) || pedigree_size <= 0) {
        warning("pedigree_size must be provided in config when point_scale_by_pedigree is TRUE. Defaulting to 1.")
        pedigree_size <- 1
      }
      if (pedigree_size <= 3) {
        built_config$point_size <- built_config$point_size * 2
      } else if (pedigree_size <= 50) {
        built_config$point_size <- built_config$point_size
      } else if (pedigree_size <= 100) {
        built_config$point_size <- max(built_config$point_size / sqrt(pedigree_size), 0.5)
      } else if (pedigree_size <= 500) {
        built_config$point_size <- max(built_config$point_size / sqrt(pedigree_size) * 1.5, 0.5)
      } else {
        built_config$point_size <- max(built_config$point_size / sqrt(pedigree_size) * 2.5, 0.5)
      }
    }
    if (built_config$segment_scale_by_pedigree == TRUE) {
      if (is.null(pedigree_size) || pedigree_size <= 0) {
        warning("pedigree_size must be provided in config when point_scale_by_pedigree is TRUE. Defaulting to 1.")
        pedigree_size <- 1
      }
      if (pedigree_size <= 50) {
        built_config$segment_linewidth <- built_config$segment_linewidth
        built_config$segment_self_linewidth <- built_config$segment_self_linewidth
      } else if (pedigree_size <= 100) {
        built_config$segment_linewidth <- max(built_config$segment_linewidth / sqrt(pedigree_size), 0.5)
        built_config$segment_self_linewidth <- max(built_config$segment_self_linewidth / sqrt(pedigree_size), 0.5 * .5)
      } else if (pedigree_size <= 500) {
        built_config$segment_linewidth <- max(built_config$segment_linewidth / sqrt(pedigree_size) * 1.5, 0.5)
        built_config$segment_self_linewidth <- max(built_config$segment_self_linewidth / sqrt(pedigree_size) * 1.5, 0.5 * .5)
      } else {
        built_config$segment_linewidth <- max(built_config$segment_linewidth / sqrt(pedigree_size) * 2.5, 0.5)
        built_config$segment_self_linewidth <- max(built_config$segment_self_linewidth / sqrt(pedigree_size) * 2.5, 0.5 * .5)
      }
    }
    if (!isTRUE(built_config$apply_default_color)) {
      # Color palette default
      if (#!is.null(built_config$color_palette_default) &&
          length(built_config$color_palette_default) > 0) {
        built_config$color_palette_default <- rep("black", length(built_config$color_palette_default))
      }

      # Sex palette
      if (!is.null(built_config$sex_color_palette) &&
          length(built_config$sex_color_palette) > 0) {
        built_config$sex_color_palette <- rep("black", length(built_config$sex_color_palette))
      }

      # Status palette (should be length 2)
      if (!is.null(built_config$status_color_palette) &&
          length(built_config$status_color_palette) >= 2) {
        built_config$status_color_palette <- rep("black", length(built_config$status_color_palette))
      } else {
        built_config$status_color_palette <- c("black", "grey")
      }

      # Status colors if used directly anywhere
      built_config$status_color_affected <- "black"
      built_config$status_color_unaffected <- "grey"



      # Focal fill palette values (if used by a manual scale)
      #   if (!is.null(built_config$focal_fill_color_values) &&
      #     length(built_config$focal_fill_color_values) > 0) {
      #     built_config$focal_fill_color_values <- rep("black", length(built_config$focal_fill_color_values))
      #   }
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
