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
#' @param spouseID Character string specifying the column name for spouse IDs. Defaults to "spouseID".
#' @param matID Character string specifying the column name for maternal lines Defaults to "matID".
#' @param patID Character string specifying the column name for paternal lines Defaults to "patID".
#' @param status_column Character string specifying the column name for affected status. Defaults to NULL.
#' @param debug Logical. If TRUE, prints debugging information. Default: FALSE.
#' @param hints Data frame with hints for layout adjustments. Default: NULL.
#' @param interactive Logical. If TRUE, generates an interactive plot using `plotly`. Default: FALSE.
#' @param overlay_column Character string specifying the column name for overlay alpha values.
#' @param tooltip_columns Character vector of column names to show when hovering.
#'        Defaults to c("personID", "sex").  Additional columns present in `ped`
#'        can be supplied – they will be added to the Plotly tooltip text.
#'        Defaults to NULL, which uses the default tooltip columns.
#' @param return_widget Logical; if TRUE (default) returns a plotly htmlwidget.
#'        If FALSE, returns the underlying plotly object (useful for further
#'        customization before printing).
#' @param focal_fill_column Character string specifying the column name for focal fill color.
#'
#' @param ... Additional arguments passed to `ggplot2` functions.
#' @param config A list of configuration options for customizing the plot. The list can include:
#'  \describe{
#'     \item{code_male}{Integer or string. Value identifying males in the sex column. (typically 0 or 1) Default: 1.}
#'     \item{segment_spouse_color, segment_self_color}{Character. Line colors for respective connection types.}
#'     \item{segment_sibling_color, segment_parent_color, segment_offspring_color}{Character. Line colors for respective connection types.}
#'     \item{label_text_size, point_size, segment_linewidth}{Numeric. Controls text size, point size, and line thickness.}
#'     \item{generation_height}{Numeric. Vertical spacing multiplier between generations. Default: 1.}
#'     \item{shape_unknown, shape_female, shape_male, status_affected_shape}{Integers. Shape codes for plotting each group.}
#'     \item{sex_shape_labels}{Character vector of labels for the sex variable. (default: c("Female", "Male", "Unknown")}
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
                       spouseID = "spouseID",
                       matID = "matID",
                       patID = "patID",
                       status_column = NULL,
                       focal_fill_column = NULL,
                       tooltip_columns = NULL,
                       overlay_column = NULL,
                       return_widget = FALSE,
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
      spouseID = spouseID,
      momID = momID,
      dadID = dadID,
      matID = matID,
      patID = patID,
      overlay_column = overlay_column,
      status_column = status_column,
      focal_fill_column = focal_fill_column,
      config = config,
      debug = debug,
      hints = hints,
      return_widget = return_widget,
      tooltip_columns = tooltip_columns,
      ...
    )
  } else {
    if (interactive == TRUE && !requireNamespace("plotly", quietly = TRUE)) {
      message("The 'plotly' package is required for interactive plots.")
    }
    # Set default styling and layout parameters
    default_config <- getDefaultPlotConfig(
      function_name = "ggpedigree",
      personID = personID
    )

    # Merge with user-specified overrides
    # This allows the user to override any of the default values
    config <- buildPlotConfig(
      default_config = default_config,
      config = config,
      function_name = "ggpedigree"
    )
    # Call the core function with the provided arguments
    ggPedigree.core(
      ped = ped,
      famID = famID,
      personID = personID,
      spouseID = spouseID,
      momID = momID,
      dadID = dadID,
      matID = matID,
      patID = patID,
      overlay_column = overlay_column,
      status_column = status_column,
      focal_fill_column = focal_fill_column,
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
                            spouseID = "spouseID",
                            matID = "matID",
                            patID = "patID",
                            focal_fill_column = NULL,
                            overlay_column = NULL,
                            status_column = NULL,
                            config = list(),
                            debug = FALSE,
                            hints = NULL,
                            function_name = "ggPedigree",
                            ...) {
  # -----
  # STEP 1: Configuration and Preparation
  # -----
  if (!inherits(ped, "data.frame")) {
    stop("ped should be a data.frame or inherit to a data.frame")
  }

  # -----
  # STEP 2: Pedigree Data Transformation
  # -----

  if (all(c(famID, patID, matID) %in% names(ped))) {
    ds_ped <- ped
  } else {
    if (!famID %in% names(ped)) {
      ds_ped <- BGmisc::ped2fam(ped,
        famID = famID,
        personID = personID,
        momID = momID,
        dadID = dadID
      )
    } else {
      ds_ped <- ped
    }
    if (!patID %in% names(ds_ped)) {
      ds_ped <- BGmisc::ped2paternal(ds_ped,
        patID = patID,
        personID = personID,
        momID = momID,
        dadID = dadID
      )
    }
    if (!matID %in% names(ds_ped)) {
      ds_ped <- BGmisc::ped2maternal(ds_ped,
        matID = matID,
        personID = personID,
        momID = momID,
        dadID = dadID
      )
    }
  }

  # Clean duplicated famID columns if present

  #  if ("famID.y" %in% names(ds_ped)) {
  #   ds_ped <- dplyr::select(.data = ds_ped, -"famID.y")
  #  }
  #  if ("famID.x" %in% names(ds_ped)) {
  #    ds_ped <- dplyr::rename(.data = ds_ped, famID = "famID.x")
  # }

  # ----
  # STEP 3: Data Cleaning and Recoding
  # ----


  # Standardize sex variable using code_male convention
  ds_ped <- BGmisc::recodeSex(ds_ped,
    recode_male = config$code_male
  )

  # If personID is not "personID", rename to "personID" internally
  #  if (personID != "personID") {
  #   ds_ped <- dplyr::rename(ds_ped, personID = !!personID)
  #  }


  # Recode affected status into factor, if applicable
  if (!is.null(status_column)) {
    ds_ped[[status_column]] <- factor(
      ds_ped[[status_column]],
      levels = config$status_codes,
      labels = config$status_labels
    )
  }
  if (config$focal_fill_include == TRUE && is.null(focal_fill_column)) {
    # If fill_column is specified but not in ds_ped, use personID as fill
    if (config$focal_fill_component %in% c(
      "additive",
      "common nuclear",
      "mitochondrial",
      "mtdna", "mitochondria"
    )) {
      # If focal_fill_component is specified, create fill column based on component
      # This will create a fill column based on the component specified in the config
      # and the personID.
      # The function createFillColumn will handle the logic of creating the fill column
      # based on the component and personID.
      ds_ped <- ds_ped %>%
        left_join(
          createFillColumn(
            ped = ds_ped,
            focal_fill_personID = config$focal_fill_personID,
            personID = personID,
            component = config$focal_fill_component,
            config = config
          ),
          by = "personID"
        )
    } else if (config$focal_fill_component %in% c(
      "maternal",
      "matID", matID, patID, famID,
      "patID",
      "paternal",
      "famID",
      "paternal line", "maternal line",
      "maternal lineages", "paternal lineages",
      "family", "family lineages"
    )
    ) {
      config$focal_fill_component_recode <- switch(config$focal_fill_component,
        "maternal" = matID,
        "paternal" = patID,
        "famID" = famID,
        "matID" = matID,
        "patID" = patID,
        "paternal line" = patID,
        "maternal line" = matID,
        "paternal lineages" = patID,
        "maternal lineages" = matID,
        "family" = famID,
        "family lineages" = famID,
        matID = matID,
        patID = patID,
        famID = famID
      )
      # If focal_fill_component is specified, create fill column based on component
      # This will create a fill column based on the component specified in the config

      switch(config$focal_fill_component_recode,
        matID = {
          # If focal_fill_component is maternal, use matID as fill
          ds_ped <- ds_ped %>%
            dplyr::mutate(focal_fill = as.factor(.data[[matID]]))
          focal_fill_column <- "matID"
        },
        patID = {
          # If focal_fill_component is paternal, use patID as fill
          ds_ped <- ds_ped %>%
            dplyr::mutate(focal_fill = as.factor(.data[[patID]]))
          focal_fill_column <- "patID"
        },
        famID = {
          # If focal_fill_component is famID, use famID as fill
          ds_ped <- ds_ped %>%
            dplyr::mutate(focal_fill = as.factor(.data[[famID]]))
          focal_fill_column <- "famID"
        }
      )
    }
  } else if (config$focal_fill_include == TRUE && !is.null(focal_fill_column)) {
    # If fill_column is specified, use it directly
    ds_ped <- ds_ped %>%
      dplyr::mutate(focal_fill = !!rlang::sym(focal_fill_column))
  }
  # -----
  # STEP 4: Coordinate Generation
  # -----

  # Compute layout coordinates using pedigree structure
  ds <- calculateCoordinates(ds_ped,
    personID = personID,
    momID = momID,
    dadID = dadID,
    spouseID = spouseID,
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
  plot_connections <- calculateConnections(ds,
    config = config,
    personID = personID,
    spouseID = spouseID,
    momID = momID,
    dadID = dadID
  )

  connections <- plot_connections$connections
  # restore names
  if (personID != "personID") {
    # Rename personID to the user-specified name
    names(connections)[names(connections) == "personID"] <- personID
  }
  if (momID != "momID") {
    # Rename momID to the user-specified name
    names(connections)[names(connections) == "momID"] <- momID
  }
  if (dadID != "dadID") {
    # Rename dadID to the user-specified name
    names(connections)[names(connections) == "dadID"] <- dadID
  }
  if ("spouseID" %in% names(connections) && spouseID != "spouseID") {
    # Rename spouseID to the user-specified name
    names(connections)[names(connections) == "spouseID"] <- spouseID
  }
  # Rename famID to the user-specified name
  if (famID != "famID") {
    # Rename famID to the user-specified name
    names(connections)[names(connections) == "famID"] <- famID
  }


  # -----
  # STEP 6: Initialize Plot
  # -----

  config$gap_hoff <- 0.5 * config$generation_height # single constant for all “stub” offsets
  config$gap_woff <- 0.5 * config$generation_width # single constant for all “stub” offsets

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
      y = .data$y_mid_sib - config$gap_hoff,
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
        y = .data$y_pos - config$gap_hoff,
        yend = .data$y_mid_sib - config$gap_hoff
      ),
      linewidth = config$segment_linewidth,
      lineend = config$segment_lineend,
      linejoin = config$segment_linejoin,
      linetype = config$segment_linetype,
      color = config$segment_offspring_color,
      na.rm = TRUE
    )
  # Sibling vertical drop line
  # special handling for twin siblings
  if (inherits(plot_connections$twin_coords, "data.frame")) {
    plot_connections$twin_coords <- plot_connections$twin_coords |>
      dplyr::mutate(
        x_start = .data$x_pos + config$segment_mz_t * (.data$x_mid_twin - .data$x_pos),
        y_start = .data$y_pos + config$segment_mz_t * ((.data$y_mid_twin - config$gap_hoff) - .data$y_pos),
        x_end   = .data$x_twin + config$segment_mz_t * (.data$x_mid_twin - .data$x_twin),
        y_end   = .data$y_twin + config$segment_mz_t * ((.data$y_mid_twin - config$gap_hoff) - .data$y_twin)
      )

    p <- p +
      ggplot2::geom_segment(
        data = plot_connections$twin_coords,
        ggplot2::aes(
          x = .data$x_pos,
          xend = .data$x_mid_twin,
          y = .data$y_pos,
          yend = .data$y_mid_twin - config$gap_hoff
        ),
        linewidth = config$segment_linewidth,
        lineend = config$segment_lineend,
        linejoin = config$segment_linejoin,
        linetype = config$segment_linetype,
        color = config$segment_sibling_color,
        na.rm = TRUE
      ) + # horizontal line to twin midpoint for MZ twins
      ggplot2::geom_segment(
        data = plot_connections$twin_coords |>
          dplyr::filter(.data$mz == TRUE),
        ggplot2::aes(
          x = .data$x_start,
          xend = .data$x_end,
          y = .data$y_start,
          yend = .data$y_end
        ),
        linewidth = config$segment_linewidth,
        lineend = config$segment_lineend,
        linejoin = config$segment_linejoin,
        linetype = config$segment_mz_linetype,
        color = config$segment_mz_color,
        alpha = config$segment_mz_alpha,
        na.rm = TRUE
      )
  }
  p <- p +
    ggplot2::geom_segment(
      data = connections |>
        dplyr::filter(.data$link_as_twin == FALSE),
      ggplot2::aes(
        x = .data$x_pos,
        xend = .data$x_pos,
        y = .data$y_mid_sib - config$gap_hoff,
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
  # 1. Whether `sex_color_include` is enabled — this controls whether sex is encoded via both color and shape.
  # 2. Whether `status_column` is specified — this controls whether affected status is visualized.

  # There are three main rendering branches:
  #   1. If sex_color_include == TRUE: color and shape reflect sex, and affected status is shown with a second symbol.
  #   2. If sex_color_include == FALSE but status_column is present: shape reflects sex, and color reflects affected status.
  #   3. If neither is used: plot individuals using shape alone.
  p <- .addNodes(
    p = p,
    config = config,
    focal_fill_column = focal_fill_column,
    status_column = status_column
  )
  # Add overlay points for affected status if applicable
  if (config$sex_color_include == TRUE ||
    config$focal_fill_include == TRUE ||
    config$overlay_include == TRUE) {
    # If overlay_column is specified, use it for alpha aesthetic

    p <- .addOverlay(
      p = p,
      config = config,
      focal_fill_column = focal_fill_column,
      status_column = status_column,
      overlay_column = overlay_column
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
    p <- .addSelfSegment(
      p = p,
      config = config,
      plot_connections = plot_connections
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
    p <- .addScales(
      p = p,
      config = config,
      status_column = status_column,
      focal_fill_column = focal_fill_column
    )
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

#' @title Add Nodes to ggplot Pedigree Plot
#' @inheritParams ggPedigree
#' @param p A ggplot object.
#' @keywords internal
#'
.addNodes <- function(p,
                      config,
                      focal_fill_column = NULL,
                      status_column = NULL) {
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
        na.rm = TRUE
      )
  } else if (config$focal_fill_include == TRUE) {
    # If status_column is not present but status_include is TRUE,
    # use alpha aesthetic to show affected status
    if (is.null(focal_fill_column)) {
      p <- p +
        ggplot2::geom_point(
          ggplot2::aes(
            color = .data$focal_fill,
            shape = as.factor(.data$sex)
          ),
          size = config$point_size,
          na.rm = TRUE
        )
    } else {
      p <- p +
        ggplot2::geom_point(
          ggplot2::aes(
            color = !!rlang::sym(focal_fill_column),
            shape = as.factor(.data$sex)
          ),
          size = config$point_size,
          na.rm = TRUE
        )
    }
  } else if (config$status_include == TRUE && !is.null(status_column)) {
    # If status_column is present but sex_color_include is FALSE,
    # use shape for sex and color for affected status
    p <- p +
      ggplot2::geom_point(
        ggplot2::aes(
          color = as.factor(!!rlang::sym(status_column)),
          shape = as.factor(.data$sex)
        ),
        size = config$point_size,
        na.rm = TRUE
      )
  } else {
    # If neither sex color nor status_column is active,
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


  return(p)
}

#' @title Add Overlay to ggplot Pedigree Plot
#' @inheritParams ggPedigree
#' @param p A ggplot object.
#' @keywords internal
#' @return A ggplot object with added overlay.
#'
.addOverlay <- function(p, config,
                        focal_fill_column = NULL,
                        status_column = NULL,
                        overlay_column = NULL) {
  if (config$overlay_include == TRUE & !is.null(overlay_column)) {
    # If overlay_column is specified, use it for alpha aesthetic
    p <- p + ggplot2::geom_point(
      ggplot2::aes(alpha = !!rlang::sym(overlay_column)),
      shape = config$overlay_shape,
      size = config$point_size,
      color = config$overlay_color,
      na.rm = TRUE
    )
  } else if (config$status_include == TRUE && !is.null(status_column)) {
    # If no overlay_column is specified, use status_column for alpha aesthetic
    #
    p <- p + ggplot2::geom_point(
      ggplot2::aes(alpha = !!rlang::sym(status_column)),
      shape = config$status_shape_affected,
      size = config$point_size,
      color = config$status_color_affected,
      na.rm = TRUE
    )
  } else if (config$focal_fill_include == TRUE && !is.null(focal_fill_column)) {
    # If focal_fill_column is specified, use it for alpha aesthetic
    p <- p + ggplot2::geom_point(
      ggplot2::aes(alpha = !!rlang::sym(focal_fill_column)),
      shape = config$focal_fill_shape,
      size = config$point_size,
      color = config$focal_fill_mid_color,
      na.rm = TRUE
    )
  }

  return(p)
}

#' @title Add Self Segments to ggplot Pedigree Plot
#' @inheritParams ggPedigree
#' @param p A ggplot object.
#' @keywords internal
#' @return A ggplot object with added scales.

.addSelfSegment <- function(p,
                            config,
                            plot_connections) {
  otherself <- plot_connections$self_coords |>
    dplyr::filter(!is.na(.data$x_otherself)) |>
    dplyr::mutate(
      otherself_xkey = makeSymmetricKey(.data$x_otherself, .data$x_pos)
    ) |>
    # unique combinations of x_otherself and x_pos and y_otherself and y_pos
    dplyr::distinct(.data$otherself_xkey, .keep_all = TRUE) |>
    unique()
  if (config$return_interactive == FALSE) {
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
      #  linejoin = config$segment_linejoin,
      linetype = config$segment_self_linetype,
      angle = config$segment_self_angle,
      curvature = config$segment_self_curvature,
      alpha = config$segment_self_alpha,
      na.rm = TRUE
    )
  } else if (config$return_interactive == TRUE) {
    # For interactive plots, use geom_segment instead of geom_curve
    # to avoid issues with plotly rendering curves

    otherself <- otherself |>
      dplyr::mutate(
        midpoint = computeCurvedMidpoint(
          x0 = .data$x_otherself,
          y0 = .data$y_otherself,
          x1 = .data$x_pos,
          y1 = .data$y_pos,
          curvature = config$segment_self_curvature,
          angle = config$segment_self_angle
        ),
        x_midpoint = .data$midpoint$x,
        y_midpoint = .data$midpoint$y
      ) |>
      dplyr::select(-"midpoint")

    p <- p + ggplot2::geom_segment(
      data = otherself,
      ggplot2::aes(
        x = .data$x_otherself,
        xend = .data$x_midpoint,
        y = .data$y_otherself,
        yend = .data$y_midpoint
      ),
      linewidth = config$segment_linewidth,
      color = config$segment_self_color,
      lineend = config$segment_lineend,
      linejoin = config$segment_linejoin,
      linetype = config$segment_self_linetype,
      alpha = config$segment_self_alpha,
      na.rm = TRUE
    ) + ggplot2::geom_segment(
      data = otherself,
      ggplot2::aes(
        x = .data$x_midpoint,
        xend = .data$x_pos,
        y = .data$y_midpoint,
        yend = .data$y_pos
      ),
      linewidth = config$segment_linewidth,
      color = config$segment_self_color,
      lineend = config$segment_lineend,
      linejoin = config$segment_linejoin,
      linetype = config$segment_self_linetype,
      alpha = config$segment_self_alpha,
      na.rm = TRUE
    )
  }
  return(p)
}


#' @title Add Scales to ggplot Pedigree Plot
#' @inheritParams ggPedigree
#' @param p A ggplot object.
#' @keywords internal
#' @return A ggplot object with added scales.

.addScales <- function(p, config,
                       status_column = NULL,
                       focal_fill_column = NULL) {
  p <- p + ggplot2::scale_shape_manual(
    values = config$sex_shape_values,
    labels = config$sex_shape_labels
  )

  # Add alpha scale for affected status if applicable
  if (!is.null(status_column) && config$sex_color_include == TRUE && config$status_include == TRUE) {
    p <- p + ggplot2::scale_alpha_manual(
      name = if (config$status_legend_show) {
        config$status_legend_title
      } else {
        NULL
      },
      values = config$status_alpha_values,
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
        labels = config$sex_shape_labels
      )
    } else {
      p <- p +
        ggplot2::scale_color_discrete(labels = config$sex_shape_labels)
    }

    p <- p +
      ggplot2::labs(
        color = config$sex_legend_title,
        shape = config$sex_legend_title
      )
  } else if (config$focal_fill_include == TRUE) {
    if (config$focal_fill_method %in% c("steps", "steps2")) {
      p <- p + ggplot2::scale_colour_steps2(
        low = config$focal_fill_low_color,
        mid = config$focal_fill_mid_color,
        high = config$focal_fill_high_color,
        midpoint = config$focal_fill_scale_midpoint,
        n.breaks = config$focal_fill_n_breaks,
        na.value = config$focal_fill_na_value
      )
    } else if (config$focal_fill_method %in% c("gradient2", "gradient")) {
      p <- p + ggplot2::scale_colour_gradient2(
        low = config$focal_fill_low_color,
        mid = config$focal_fill_mid_color,
        high = config$focal_fill_high_color,
        midpoint = config$focal_fill_scale_midpoint,
        n.breaks = config$focal_fill_n_breaks,
        na.value = config$focal_fill_na_value
      )
    } else {
      stop("focal_fill_method must be one of 'steps', 'steps2', 'gradient2', or 'gradient'")
    }
    p <- p +
      ggplot2::labs(
        color = if (config$focal_fill_legend_show == TRUE) {
          config$focal_fill_legend_title
        } else {
          NULL
        },
        shape = config$sex_legend_title
      )
    if (config$focal_fill_legend_show == FALSE) {
      p <- p + ggplot2::guides(color = "none")
    }
  } else if (!is.null(status_column) && config$status_include == TRUE) {
    if (!is.null(config$status_color_palette)) {
      p <- p + ggplot2::scale_color_manual(
        values = config$status_color_values,
        labels = config$status_labels
      )
    } else {
      p <- p +
        ggplot2::scale_color_discrete(labels = config$status_labels)
    }
    p <- p +
      ggplot2::labs(
        color = config$status_legend_title,
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



# @title Prepare Pedigree Data
# @description
# This function checks and prepares the pedigree data frame for use in ggPedigree.
#
#
#
# .preparePedigreeData <- function(ped, famID = "famID",
#                                  personID = "personID",
#                                  momID = "momID",
#                                  dadID = "dadID",
#                                  spouseID = "spouseID",
#                                  status_column = NULL,
#                                  focal_fill_column = NULL,
#                                  config = list(),
#                                  function_name = "ggPedigree") {
#
#   default_config <- getDefaultPlotConfig()
#
#   config <- utils::modifyList(default_config, config)
#
# }
#' @title Compute midpoint coordinate for curved segment
#' @description Returns either x or y midpoint using vectorized curved offset
#' @param x0 Numeric vector of x coordinates for start points
#' @param y0 Numeric vector of y coordinates for start points
#' @param x1 Numeric vector of x coordinates for end points
#' @param y1 Numeric vector of y coordinates for end points
#' @param t Scalar value between 0 and 1 for interpolation (default is 0.5) setting the midpoint
#' @param curvature Scalar curvature (geom_curve style)
#' @param angle Scalar angle in degrees
#' @param component Either "x" or "y"
#' @return Numeric vector of midpoints (x or y)
#'  @keywords internal
computeCurvedMidpoint <- function(x0, y0, x1, y1,
                                  curvature, angle,
                                  component = NULL,
                                  t = 0.5) {
  dx <- x1 - x0
  dy <- y1 - y0
  len <- sqrt(dx^2 + dy^2)

  # Midpoint of the segment

  px <- (x0 + x1) * t
  py <- (y0 + y1) * t

  # Unit perpendicular vector
  ux <- dx / len
  uy <- dy / len

  # Rotate perpendicular vector by (angle - 90) degrees
  theta <- angle * pi / 180 - 2 * 90 * pi / 180 #
  #   (angle* pi / 180 - 90) * pi / 180

  # Perpendicular direction
  perp_x <- -uy * cos(theta) - ux * sin(theta)
  perp_y <- -uy * sin(theta) + ux * cos(theta)

  offset <- curvature * len

  midpoint <- data.frame(
    x = px + offset * perp_x,
    y = py + offset * perp_y
  )

  midpoint
}

#' @title Get fill column for ggPedigree
#' @description
#' This function creates a fill column for ggPedigree plots as a function of
#' the focal person relative to everyone else in the tree.
#' @param ped A data frame containing the pedigree data.
#' @param focal_fill_personID Numeric ID of the person to use as the focal point for fill.
#' @param personID Character string specifying the column name for individual IDs.
#' @param component Character string specifying the component type (e.g., "additive").
#' @param config A list of configuration options for customizing the fill column.
#' @return A data frame with two columns: `fill` and `personID`.
#' @keywords internal
createFillColumn <- function(ped,
                             focal_fill_personID = 2,
                             personID = "personID",
                             component = "additive",
                             config = list()) {
  default_config <- getDefaultPlotConfig()

  config <- utils::modifyList(default_config, config)

  com_mat <- BGmisc::ped2com(
    ped = ped,
    component = component,
    personID = personID,
    isChild_method = config$matrix_isChild_method,
    sparse = config$matrix_sparse
  )
  if (config$matrix_sparse == FALSE) {
    fill_df <- data.frame(
      focal_fill = com_mat[focal_fill_personID, ],
      personID = rownames(com_mat)
    ) # needs to match the same data type
    remove(com_mat) # remove the focal_fill_personID column
  } else if (config$matrix_sparse == TRUE) {
    warning("Sparse matrix detected. Converting to data frame. Currently, sparse matrices are not supported for ggPedigree processing.")
    com_mat <- as.matrix(com_mat)
    fill_df <- data.frame(
      focal_fill = com_mat[focal_fill_personID, ],
      personID = rownames(com_mat)
    ) # needs to match the same data type
    remove(com_mat)
  }
  # Ensure fill_df$personID is of the same type as ped$personID
  if (is.numeric(ped$personID)) {
    fill_df$personID <- as.numeric(fill_df$personID)
  }
  if (config$focal_fill_force_zero == TRUE) {
    # If focal_fill_force_zero is TRUE, replace 0 with NA
    fill_df$focal_fill[fill_df$focal_fill == 0] <- NA_real_
  }
  return(fill_df)
}
