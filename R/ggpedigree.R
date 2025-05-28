#' Plot a custom pedigree diagram
#'
#' Generates a ggplot2-based diagram of a pedigree using custom coordinate layout,
#' calculated relationship connections, and flexible styling via `config`.
#' It processes the data using `ped2fam()`. This function
#' supports multiple families and optionally displays affected status and sex-based color/shape.
#'
#' @param ped A data frame containing the pedigree data. Needs personID, momID, and dadID columns
#' @param famID Character string specifying the column name for family IDs.
#' @param personID Character string specifying the column name for individual IDs.
#' @param momID Character string specifying the column name for mother IDs. Defaults to "momID".
#' @param dadID Character string specifying the column name for father IDs. Defaults to "dadID".
#' @param status_col Character string specifying the column name for affected status. Defaults to NULL.
#' @param debug Logical. If TRUE, prints debugging information. Default: FALSE.
#' @param hints Data frame with hints for layout adjustments. Default: NULL.
#' @param interactive Logical. If TRUE, generates an interactive plot using `plotly`. Default: FALSE.
#' @param tooltip_columns Character vector of column names to show when hovering.
#'        Defaults to c("personID", "sex").  Additional columns present in `ped`
#'        can be supplied – they will be added to the Plotly tooltip text.
#' @param as_widget Logical; if TRUE (default) returns a plotly htmlwidget.
#'        If FALSE, returns the underlying plotly object (useful for further
#'        customization before printing).
#' @param ... Additional arguments passed to `ggplot2` functions.
#' @param config A list of configuration options for customizing the plot. The list can include:
#'  \describe{
#'     \item{code_male}{Integer or string. Value identifying males in the sex column. (typically 0 or 1) Default: 1.}
#'     \item{segment_spouse_color, segment_self_color}{Character. Line colors for respective connection types.}
#'     \item{segment_sibling_color, segment_parent_color, segment_offspring_color}{Character. Line colors for respective connection types.}
#'     \item{label_text_size, point_size, segment_linewidth}{Numeric. Controls text size, point size, and line thickness.}
#'     \item{generation_height}{Numeric. Vertical spacing multiplier between generations. Default: 1.}
#'     \item{shape_unknown, shape_female, shape_male, affected_shape}{Integers. Shape codes for plotting each group.}
#'     \item{sex_shape_labs}{Character vector of labels for the sex variable. (default: c("Female", "Male", "Unknown")}
#'     \item{unaffected, affected}{Values indicating unaffected/affected status.}
#'     \item{sex_color_include}{Logical. If TRUE, uses color to differentiate sex.}
#'     \item{label_max_overlaps}{Maximum number of overlaps allowed in repelled labels.}
#'     \item{label_segment_color}{Color used for label connector lines.}
#'   }

#' @return A `ggplot` object rendering the pedigree diagram.
#' @examples
#' library(BGmisc)
#' data("potter")
#' ggPedigree(potter, famID = "famID", personID = "personID")
#'
#' data("hazard")
#' ggPedigree(hazard, famID = "famID", personID = "ID", config = list(code_male = 0))
#'
#' @export
#' @import ggplot2 dplyr BGmisc ggrepel
#' @importFrom rlang sym
#' @importFrom utils modifyList
#'
ggPedigree <- function(ped,
                       famID = "famID",
                       personID = "personID",
                       momID = "momID",
                       dadID = "dadID",
                       status_col = NULL,
                       tooltip_columns = NULL,
                       as_widget = FALSE,
                       config = list(),
                       debug = FALSE,
                       hints = NULL,
                       interactive = FALSE,
                       ...) {
  if (!inherits(ped, "data.frame")) {
    stop("ped should be a data.frame or inherit to a data.frame")
  }


  if (interactive == TRUE && requireNamespace("plotly", quietly = TRUE)) {
    # Call the interactive function with the provided arguments
    ggPedigreeInteractive(
      ped = ped,
      famID = famID,
      personID = personID,
      momID = momID,
      dadID = dadID,
      status_col = status_col,
      config = config,
      debug = debug,
      hints = hints,
      as_widget = as_widget,
      tooltip_columns = tooltip_columns,
      ...
    )
  } else {
    if (interactive == TRUE && !requireNamespace("plotly", quietly = TRUE)) {
      message("The 'plotly' package is required for interactive plots.")
    }
    # Call the core function with the provided arguments
    ggPedigree.core(
      ped = ped,
      famID = famID,
      personID = personID,
      momID = momID,
      dadID = dadID,
      status_col = status_col,
      config = config,
      debug = debug,
      hints = hints,
      ...
    )
  }
}

#' @title Core Function for ggPedigree
#' @description
#' This function is the core implementation of the ggPedigree function.
#' It handles the data preparation, layout calculation,
#' and plotting of the pedigree diagram.
#' It is not intended to be called directly by users.
#'
#' @inheritParams ggPedigree
#' @keywords internal


ggPedigree.core <- function(ped, famID = "famID",
                            personID = "personID",
                            momID = "momID",
                            dadID = "dadID",
                            status_col = NULL,
                            config = list(),
                            debug = FALSE,
                            hints = NULL,
                            ...) {
  # -----
  # STEP 1: Configuration and Preparation
  # -----
  if (!inherits(ped, "data.frame")) {
    stop("ped should be a data.frame or inherit to a data.frame")
  }

  # Set default styling and layout parameters
  default_config <- getDefaultPlotConfig()

  # Merge with user-specified overrides
  # This allows the user to override any of the default values
  config <- utils::modifyList(default_config, config)

  # Set additional internal config values based on other entries

  config$sex_shape_vals <- c(config$sex_shape_female, config$sex_shape_male, config$sex_shape_unknown)
  config$status_labs <- c(config$status_label_affected, config$status_label_unaffected)

  config$status_codes <- c(config$status_code_affected, config$status_code_unaffected)

  config$status_alpha_vals <- stats::setNames(c(
    config$status_alpha_affected,
    config$status_alpha_unaffected
  ), config$status_labs)
  config$status_color_vals <- stats::setNames(
    c(
      config$status_color_palette[1],
      config$status_color_palette[2]
    ),
    config$status_labs
  )

  config$status_labels <- stats::setNames(c(
    config$status_label_affected,
    config$status_label_unaffected
  ), config$status_labs)

  # -----
  # STEP 2: Pedigree Data Transformation
  # -----


  ds_ped <- BGmisc::ped2fam(ped,
    famID = famID,
    personID = personID,
    momID = momID,
    dadID = dadID
  )

  # Clean duplicated famID columns if present

  if ("famID.y" %in% names(ds_ped)) {
    ds_ped <- dplyr::select(.data = ds_ped, -"famID.y")
  }
  if ("famID.x" %in% names(ds_ped)) {
    ds_ped <- dplyr::rename(.data = ds_ped, famID = "famID.x")
  }

  # If personID is not "personID", rename to "personID" internally
  if (personID != "personID") {
    ds_ped <- dplyr::rename(ds_ped, personID = !!personID)
  }

  # Recode affected status into factor, if applicable
  if (!is.null(status_col)) {
    ds_ped[[status_col]] <- factor(
      ds_ped[[status_col]],
      levels = config$status_codes,
      labels = config$status_labels
    )
  }


  # -----
  # STEP 3: Sex Recode
  # -----

  # Standardize sex variable using code_male convention
  ds_ped <- BGmisc::recodeSex(ds_ped,
    recode_male = config$code_male
  )

  # -----
  # STEP 4: Coordinate Generation
  # -----

  # Compute layout coordinates using pedigree structure
  ds <- calculateCoordinates(ds_ped,
    personID = "personID",
    momID = momID,
    dadID = dadID,
    code_male = config$code_male,
    config = config
  )

  # Apply vertical spacing factor if generation_height ≠ 1
  if (!isTRUE(all.equal(config$generation_height, 1))) {
    ds$y_pos <- ds$y_pos * config$generation_height # expand/contract generations
  }
  # Apply horizontal spacing factor if generation_width ≠ 1
  if (!isTRUE(all.equal(config$generation_width, 1))) {
    ds$x_pos <- ds$x_pos * config$generation_width # expand/contract generations
  }
  # -----
  # STEP 5: Compute Relationship Connections
  # -----

  # Generate a connection table for plotting lines (parents, spouses, etc.)
  plot_connections <- calculateConnections(ds, config = config)

  connections <- plot_connections$connections
  # -----
  # STEP 6: Initialize Plot
  # -----

  gap_off <- 0.5 * config$generation_height # single constant for all “stub” offsets

  p <- ggplot2::ggplot(ds, ggplot2::aes(
    x = .data$x_pos,
    y = .data$y_pos
  ))


  # -----
  # STEP 7: Add Segments
  # -----

  # Spouse link between two parents
  p <- p +
    ggplot2::geom_segment(
      data = connections,
      ggplot2::aes(
        x = .data$x_spouse,
        xend = .data$x_pos,
        y = .data$y_spouse,
        yend = .data$y_pos
      ),
      linewidth = config$segment_linewidth,
      lineend = config$segment_lineend,
      linejoin = config$segment_linejoin,
      color = config$segment_spouse_color,
      linetype = config$segment_linetype,
      na.rm = TRUE
    )

  # Parent-child stub (child to mid-sibling point)

  p <- p + ggplot2::geom_segment(
    data = connections,
    ggplot2::aes(
      x = .data$x_mid_sib,
      xend = .data$x_midparent,
      y = .data$y_mid_sib - gap_off,
      yend = .data$y_midparent
    ),
    linewidth = config$segment_linewidth,
    linetype = config$segment_linetype,
    lineend = config$segment_lineend,
    linejoin = config$segment_linejoin,
    color = config$segment_parent_color,
    na.rm = TRUE
  ) +
    # Mid-sibling to parents midpoint
    ggplot2::geom_segment(
      data = connections,
      ggplot2::aes(
        x = .data$x_pos,
        xend = .data$x_mid_sib,
        y = .data$y_pos - gap_off,
        yend = .data$y_mid_sib - gap_off
      ),
      linewidth = config$segment_linewidth,
      lineend = config$segment_lineend,
      linejoin = config$segment_linejoin,
      linetype = config$segment_linetype,
      color = config$segment_offspring_color,
      na.rm = TRUE
    ) +
    # Sibling vertical drop line
    ggplot2::geom_segment(
      data = connections,
      ggplot2::aes(
        x = .data$x_pos,
        xend = .data$x_pos,
        y = .data$y_mid_sib - gap_off,
        yend = .data$y_pos
      ),
      linewidth = config$segment_linewidth,
      lineend = config$segment_lineend,
      linejoin = config$segment_linejoin,
      linetype = config$segment_linetype,
      color = config$segment_sibling_color,
      na.rm = TRUE
    )

  # -----
  # STEP 8: Add Points (nodes)
  # -----

  # Add point layers for each individual in the pedigree.
  # The appearance (color and shape) depends on two factors:
  # 1. Whether `sex_color` is enabled — this controls whether sex is encoded via both color and shape.
  # 2. Whether `status_col` is specified — this controls whether affected status is visualized.

  # There are three main rendering branches:
  #   1. If sex_color == TRUE: color and shape reflect sex, and affected status is shown with a second symbol.
  #   2. If sex_color == FALSE but status_col is present: shape reflects sex, and color reflects affected status.
  #   3. If neither is used: plot individuals using shape alone.


  if (config$outline_include == TRUE) {
    p <- p +
      ggplot2::geom_point(
        ggplot2::aes(
          shape = as.factor(.data$sex)
        ),
        size = config$point_size * config$outline_multiplier,
        na.rm = TRUE,
        color = config$outline_color,
        stroke = config$segment_linewidth
      )
  }

  if (config$sex_color_include == TRUE) {
    # Use color and shape to represent sex
    p <- p +
      ggplot2::geom_point(
        ggplot2::aes(
          color = as.factor(.data$sex),
          shape = as.factor(.data$sex)
        ),
        size = config$point_size,
        na.rm = TRUE,
        stroke = config$segment_linewidth
      )
    # If affected status is present, overlay an additional marker using alpha aesthetic
    if (!is.null(status_col)) {
      p <- p + ggplot2::geom_point(
        ggplot2::aes(alpha = !!rlang::sym(status_col)),
        shape = config$status_affected_shape,
        size = config$point_size,
        na.rm = TRUE
      )
    }
  } else if (!is.null(status_col)) {
    # If status_col is present but sex_color_include is FALSE,
    # use shape for sex and color for affected status
    p <- p +
      ggplot2::geom_point(
        ggplot2::aes(
          color = as.factor(!!rlang::sym(status_col)),
          shape = as.factor(.data$sex)
        ),
        size = config$point_size,
        na.rm = TRUE
      )
  } else {
    # If neither sex color nor status_col is active,
    # plot using shape (sex) only
    p <- p +
      ggplot2::geom_point(
        ggplot2::aes(
          shape = as.factor(.data$sex)
        ),
        size = config$point_size,
        na.rm = TRUE
      )
  }


  # -----
  # STEP 9: Add Labels
  # -----
  # Add labels to the points using ggrepel for better visibility

  if (config$label_include == TRUE) {
    p <- .addLabels(p = p, config = config)
  }

  # -----
  # STEP 10: Add optional self-segment lines
  # -----

  # Self-segment (for duplicate layout appearances of same person)
  if (inherits(plot_connections$self_coords, "data.frame")) {
    otherself <- plot_connections$self_coords |>
      dplyr::filter(!is.na(.data$x_otherself)) |>
      dplyr::mutate(
        otherself_xkey = makeSymmetricKey(.data$x_otherself, .data$x_pos) # ,
        #  otherself_ykey = makeSymmetricKey(.data$y_otherself, .data$y_pos)
      ) |>
      # unique combinations of x_otherself and x_pos and y_otherself and y_pos
      dplyr::distinct(.data$otherself_xkey, .keep_all = TRUE)


    p <- p + ggplot2::geom_curve(
      data = otherself,
      ggplot2::aes(
        x = .data$x_otherself,
        xend = .data$x_pos,
        y = .data$y_otherself,
        yend = .data$y_pos
      ),
      linewidth = config$segment_linewidth,
      color = config$segment_self_color,
      lineend = config$segment_lineend,
      linejoin = config$segment_linejoin,
      linetype = config$segment_self_linetype,
      angle = config$segment_self_angle,
      curvature = config$segment_self_curvature,
      na.rm = TRUE
    )
  }



  # -----
  # STEP 11: Scales, Theme
  # -----

  p <- p +
    ggplot2::scale_y_reverse()

  if (config$apply_default_theme == TRUE) {
    p <- p +
      ggplot2::theme_minimal() +
      ggplot2::theme(
        axis.title.y = ggplot2::element_blank(),
        axis.text.y = ggplot2::element_blank(),
        axis.ticks.y = ggplot2::element_blank(),
        panel.grid.major = ggplot2::element_blank(),
        panel.grid.minor = ggplot2::element_blank(),
        panel.background = ggplot2::element_blank(),
        axis.title.x = ggplot2::element_blank(),
        axis.text.x = ggplot2::element_blank(),
        axis.ticks.x = ggplot2::element_blank()
      )
  }

  # -----
  # STEP 12: Final Legend Adjustments
  # -----
  # Adjust legend labels and colors based on the configuration
  if (config$apply_default_scales == TRUE) {
    p <- .addScales(p = p, config = config, status_col = status_col)
  }

  if (debug == TRUE) {
    return(list(
      plot = p,
      data = ds,
      connections = connections,
      config = config
    ))
  } else {
    # If debug is FALSE, return only the plot
    return(p)
  }
}

#' @rdname ggPedigree
#' @export
ggpedigree <- ggPedigree


#' @title Add Scales to ggplot Pedigree Plot
#' @inheritParams ggPedigree
#' @param p A ggplot object.
#' @keywords internal
#' @return A ggplot object with added scales.
.addScales <- function(p, config, status_col = NULL) {
  p <- p + ggplot2::scale_shape_manual(
    values = config$sex_shape_vals,
    labels = config$sex_shape_labs
  )

  # Add alpha scale for affected status if applicable
  if (!is.null(status_col) && config$sex_color_include == TRUE) {
    p <- p + ggplot2::scale_alpha_manual(
      name = if (config$status_legend_show) {
        config$status_affected_legend_title
      } else {
        NULL
      },
      values = config$status_alpha_vals,
      na.translate = FALSE
    )
    if (config$status_legend_show == FALSE) {
      p <- p + ggplot2::guides(alpha = "none")
    }
  }

  # Add color scale for sex or affected status if applicable
  if (config$sex_color_include == TRUE) {
    if (!is.null(config$sex_color_palette)) {
      p <- p + ggplot2::scale_color_manual(
        values = config$sex_color_palette,
        labels = config$sex_shape_labs
      )
    } else {
      p <- p +
        ggplot2::scale_color_discrete(labels = config$sex_shape_labs)
    }

    p <- p +
      ggplot2::labs(
        color = config$sex_legend_title,
        shape = config$sex_legend_title
      )
  } else if (!is.null(status_col)) {
    if (!is.null(config$status_color_palette)) {
      p <- p + ggplot2::scale_color_manual(
        values = config$status_color_vals,
        labels = config$status_labels
      )
    } else {
      p <- p +
        ggplot2::scale_color_discrete(labels = config$status_labels)
    }
    p <- p +
      ggplot2::labs(
        color = config$status_affected_legend_title,
        shape = config$sex_legend_title
      )
  } else {
    p <- p + ggplot2::labs(shape = config$sex_legend_title)
  }
  return(p)
}

#' @title Add Labels to ggplot Pedigree Plot
#' @inheritParams ggPedigree
#' @inheritParams .addScales
#'
#' @return A ggplot object with added labels.
#' @keywords internal
#'
.addLabels <- function(p, config) {
  if (config$label_method %in% c("geom_text_repel", "ggrepel", "geom_label_repel")
  ) {
    p <- p +
      ggrepel::geom_text_repel(ggplot2::aes(label = !!rlang::sym(config$label_column)),
        nudge_y = config$label_nudge_y * config$generation_height,
        nudge_x = config$label_nudge_x * config$generation_width,
        size = config$label_text_size,
        na.rm = TRUE,
        max.overlaps = config$label_max_overlaps,
        segment.size = config$segment_linewidth * .5,
        angle = config$label_text_angle,
        segment.color = config$label_segment_color
      )
  } else if (config$label_method == "geom_label") {
    p <- p +
      ggplot2::geom_label(ggplot2::aes(label = !!rlang::sym(config$label_column)),
        nudge_y = config$label_nudge_y * config$generation_height,
        nudge_x = config$label_nudge_x * config$generation_width,
        size = config$label_text_size,
        angle = config$label_text_angle,
        na.rm = TRUE
      )
  } else if (config$label_method == "geom_text") {
    p <- p +
      ggplot2::geom_text(ggplot2::aes(label = !!rlang::sym(config$label_column)),
        nudge_y = config$label_nudge_y * config$generation_height,
        nudge_x = config$label_nudge_x * config$generation_width,
        size = config$label_text_size,
        angle = config$label_text_angle,
        na.rm = TRUE
      )
  }
  return(p)
}
#' @title Prepare Pedigree Data
#' @description
#' This function checks and prepares the pedigree data frame for use in ggPedigree.
#'


# .preparePedigreeData <- function(ped, famID, personID, momID, dadID) {
#
# }
