#' Plot a custom pedigree diagram
#'
#' Generates a ggplot2-based diagram of a pedigree using custom coordinate layout,
#' calculated relationship connections, and flexible styling via `config`.
#' It processes the data using `ped2fam()`. This function
#' supports multiple families and optionally displays affected status and sex-based color/shape.
#'
#' @param ped A data frame containing the pedigree data. Needs personID, momID, and dadID columns
#' @param famID Character string specifying the column name for family IDs. Defaults to "famID".
#' @param personID Character string specifying the column name for individual IDs. Defaults to "personID".
#' @param momID Character string specifying the column name for mother IDs. Defaults to "momID".
#' @param dadID Character string specifying the column name for father IDs. Defaults to "dadID".
#' @param spouseID Character string specifying the column name for spouse IDs. Defaults to "spouseID".
#' @param matID Character string specifying the column name for maternal lines Defaults to "matID".
#' @param patID Character string specifying the column name for paternal lines Defaults to "patID".
#' @param twinID Character string specifying the column name for twin IDs. Defaults to "twinID".
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
#' @param phantoms Logical. If TRUE, adds phantom parents for individuals without parents.
#' @param ... Additional arguments passed to `ggplot2` functions.
#' @param config A list of configuration options for customizing the plot.
#'        See getDefaultPlotConfig for details. The list can include:
#'  \describe{
#'     \item{code_male}{Integer or string. Value identifying males in the sex column. (typically 0 or 1) Default: 1.}
#'     \item{segment_spouse_color, segment_self_color}{Character. Line colors for respective connection types.}
#'     \item{segment_sibling_color, segment_parent_color, segment_offspring_color}{Character. Line colors for respective connection types.}
#'     \item{label_text_size, point_size, segment_linewidth}{Numeric. Controls text size, point size, and line thickness.}
#'     \item{generation_height}{Numeric. Vertical spacing multiplier between generations. Default: 1.}
#'     \item{shape_unknown, shape_female, shape_male, status_shape_affected}{Integers. Shape codes for plotting each group.}
#'     \item{sex_shape_labels}{Character vector of labels for the sex variable. (default: c("Female", "Male", "Unknown"))}
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
#' @import ggplot2
#' @importFrom dplyr mutate filter left_join select join_by case_when rename
#' @importFrom BGmisc ped2fam ped2paternal ped2maternal recodeSex checkParentIDs
#' @importFrom rlang sym
#' @importFrom utils modifyList
#' @aliases ggpedigree
ggPedigree <- function(ped,
                       famID = "famID",
                       personID = "personID",
                       momID = "momID",
                       dadID = "dadID",
                       spouseID = "spouseID",
                       matID = "matID",
                       patID = "patID",
                       twinID = "twinID",
                       status_column = NULL,
                       focal_fill_column = NULL,
                       tooltip_columns = NULL,
                       overlay_column = NULL,
                       return_widget = FALSE,
                       config = list(),
                       debug = FALSE,
                       hints = NULL,
                       interactive = FALSE,
                       phantoms = FALSE,
                       ...) {
  if (!inherits(ped, "data.frame")) {
    if (rlang::inherits_any(ped, c("ped", "pedigree", "kinship2.pedigree"))) {
      # Convert ped object to data.frame
      ped <- as.data.frame(ped)
    } else if (rlang::inherits_any(ped, "pedigreeList")) {
      class(ped) <- "list"
      ped <- as.data.frame(ped)
    } else {
      # If not a data.frame or compatible type, throw an error
      stop("ped should be a data.frame or inherit to a data.frame")
    }
  }
  if (!all(c(personID, dadID, momID, "sex") %in% names(ped))) {
    stop("ped must contain personID, sex, dadID, and momID columns")
  }

  if (interactive == TRUE &&
    requireNamespace("plotly", quietly = TRUE)) {
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
      twinID = twinID,
      status_column = status_column,
      focal_fill_column = focal_fill_column,
      config = config,
      debug = debug,
      hints = hints,
      return_widget = return_widget,
      tooltip_columns = tooltip_columns,
      phantoms = phantoms,
      ...
    )
  } else {
    if (interactive == TRUE &&
      !requireNamespace("plotly", quietly = TRUE)) {
      message("The 'plotly' package is required for interactive plots.")
    }

    # Set default styling and layout parameters
    default_config <- getDefaultPlotConfig(function_name = "ggpedigree", personID = personID)

    # Merge with user-specified overrides
    # This allows the user to override any of the default values
    config <- buildPlotConfig(
      default_config = default_config,
      config = config,
      function_name = "ggpedigree",
      pedigree_size = nrow(ped)
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
      twinID = twinID,
      status_column = status_column,
      focal_fill_column = focal_fill_column,
      config = config,
      debug = debug,
      hints = hints,
      phantoms = phantoms,
      ...
    )
  }
}

#' @rdname ggPedigree
#' @export
ggpedigree <- ggPedigree


#' @title Core Function for ggPedigree
#' @description
#' This function is the core implementation of the ggPedigree function.
#' It handles the data preparation, layout calculation,
#' and plotting of the pedigree diagram.
#' It is not intended to be called directly by users.
#'
#' @inheritParams ggPedigree
#'
#' @keywords internal


ggPedigree.core <- function(ped,
                            famID = "famID",
                            personID = "personID",
                            momID = "momID",
                            dadID = "dadID",
                            spouseID = "spouseID",
                            matID = "matID",
                            patID = "patID",
                            twinID = "twinID",
                            focal_fill_column = NULL,
                            overlay_column = NULL,
                            status_column = NULL,
                            config = list(),
                            debug = FALSE,
                            hints = NULL,
                            function_name = "ggPedigree",
                            phantoms = FALSE,
                            ...) {
  # -----
  # STEP 1: Configuration and Preparation
  # -----
  if (!inherits(ped, "data.frame")) {
    stop("ped should be a data.frame or inherit to a data.frame")
  }

  config$debug <- isTRUE(debug) || isTRUE(config$debug)

  if (config$debug == TRUE) {
    message("Debug mode is ON. Debugging information will be printed.")
  }
  # add matches for fill groups
  fill_group_maternal <- c(
    "maternal",
    "matID",
    "mat ID",
    "maternal line",
    "maternal lineages",
    "maternal lines"
  )
  fill_group_paternal <- c(
    "paternal",
    "patID",
    "pat ID",
    "paternal line",
    "paternal lineages",
    "paternal lines"
  )
  fill_group_family <- c(
    "famID",
    "fam ID",
    "family",
    "family lineages",
    "family lines",
    "family line"
  )


  # -----
  # STEP 2+3: Pedigree Data Transformation and Data Cleaning and Recoding
  # -----
  # id type changer in this function
  ds_ped <- preparePedigreeData(
    famID = famID,
    patID = patID,
    matID = matID,
    ped = ped,
    personID = personID,
    momID = momID,
    dadID = dadID,
    config = config,
    fill_group_paternal = fill_group_paternal,
    fill_group_maternal = fill_group_maternal,
    fill_group_family = fill_group_family,
    status_column = status_column,
    phantoms = phantoms,
    focal_fill_column = focal_fill_column
  )

  if (config$debug == TRUE) {
    message("Pedigree data prepared. Number of individuals: ", nrow(ds_ped))

    # assign("DEBUG_ds_ped", ds_ped, envir = .GlobalEnv)
  }
  #  print(class(ped$spouseID))
  #  print(class(ped$personID))
  #  print(class(ped$momID))
  # print(class(ped$dadID))


  # -----
  # STEP 4: Coordinate Generation
  # -----

  # Compute layout coordinates using pedigree structure
  ds <- calculateCoordinates(
    ds_ped,
    personID = personID,
    momID = momID,
    dadID = dadID,
    spouseID = spouseID,
    code_male = config$code_male,
    config = config,
    twinID = twinID
  )
  if (config$debug == TRUE) {
    message("Coordinates calculated. Number of individuals: ", nrow(ds))

    # assign("DEBUG_ds", ds, envir = .GlobalEnv)
  }
  # Apply spacing factors
  ds <- .adjustSpacing(ds = ds, config = config)


  # -----
  # STEP 5: Compute Relationship Connections
  # -----

  # Generate a connection table for plotting lines (parents, spouses, etc.)
  plot_connections <- calculateConnections(
    ds,
    config = config,
    personID = personID,
    spouseID = spouseID,
    momID = momID,
    dadID = dadID,
    twinID = twinID
  )
  #  print(class(ped$spouseID))
  #  print(class(ped$personID))
  #  print(class(ped$momID))
  #  print(class(ped$dadID))
  connections <- plot_connections$connections

  if (config$debug == TRUE) {
    message(
      "Connections calculated. Number of connections: ",
      nrow(connections)
    )

    # assign("DEBUG_connections", connections, envir = .GlobalEnv)
  }
  # restore names
  connections <- .restoreNames(
    connections = connections,
    personID = personID,
    momID = momID,
    dadID = dadID,
    spouseID = spouseID,
    twinID = twinID,
    famID = famID
  )


  # -----
  # STEP 6: Initialize Plot
  # -----

  config$gap_hoff <- 0.5 * config$generation_height # single constant for all “stub” offsets
  config$gap_woff <- 0.5 * config$generation_width # single constant for all “stub” offsets

  # recode missing sex to "unknown"
  if (any(is.na(ds$sex)) && is.character(ds$sex)) {
    ds <- ds |>
      dplyr::mutate(sex = dplyr::case_when(
        is.na(.data$sex) ~ "unknown",
        TRUE ~ as.character(.data$sex)
      ))
  }
  p <- ggplot2::ggplot(
    ds,
    ggplot2::aes(
      x = .data$x_pos,
      y = .data$y_pos
    )
  )

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
      xend = .data$x_fam,
      y = .data$y_mid_sib - config$gap_hoff,
      yend = .data$y_fam
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
      data = connections |>
        dplyr::filter(.data$link_as_twin == FALSE),
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

  # if twins
  if (inherits(plot_connections$twin_coords, "data.frame")) {
    plot_connections$twin_coords <- plot_connections$twin_coords |>
      dplyr::mutate(
        x_start = .data$x_pos + config$segment_mz_t * (.data$x_mid_twin - .data$x_pos),
        y_start = .data$y_pos + config$segment_mz_t * ((.data$y_mid_twin - config$gap_hoff) - .data$y_pos),
        x_end   = .data$x_twin + config$segment_mz_t * (.data$x_mid_twin - .data$x_twin),
        y_end   = .data$y_twin + config$segment_mz_t * ((.data$y_mid_twin - config$gap_hoff) - .data$y_twin)
      ) |>
      left_join(
        connections |>
          dplyr::select(!!rlang::sym(personID), "x_mid_sib", "y_mid_sib"),
        # the twin_coords file didn't have its variables restored
        by = dplyr::join_by(personID == !!rlang::sym(personID))
      )

    p <- addTwins(
      plotObject = p,
      connections = connections,
      config = config,
      plot_connections = plot_connections,
      personID = personID
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
  p <- .addNodes(
    plotObject = p,
    config = config,
    focal_fill_column = focal_fill_column,
    status_column = status_column
  )

  # Add overlay points for affected status if applicable
  if (
    config$focal_fill_include == TRUE && config$sex_color_include == FALSE ||
      config$overlay_include == TRUE && !is.null(overlay_column) ||
      !is.null(status_column) && config$status_include == TRUE && config$sex_color_include == TRUE) {
    # If overlay_column is specified, use it for alpha aesthetic

    p <- .addOverlay(
      plotObject = p,
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
    p <- .addLabels(plotObject = p, config = config)
  }

  # -----
  # STEP 10: Add optional self-segment lines
  # -----

  # Self-segment (for duplicate layout appearances of same person)
  if (inherits(plot_connections$self_coords, "data.frame")) {
    p <- .addSelfSegment(
      plotObject = p,
      config = config,
      plot_connections = plot_connections
    )
  }

  # -----
  # STEP 11: Scales, Theme
  # -----

  p <- p +
    ggplot2::scale_y_reverse(limits = c(
      NA,
      min(ds$y_pos)
    ))

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
      plotObject = p,
      config = config,
      status_column = status_column,
      focal_fill_column = focal_fill_column
    )
  }
  # add plot_connections to the plot object
  attr(p, "connections") <- plot_connections
  if (config$debug == TRUE) {
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


#' @title Add Nodes to ggplot Pedigree Plot
#' @inheritParams ggPedigree
#' @param plotObject A ggplot object.
#' @keywords internal
#'
#'
.addNodes <- function(plotObject,
                      config,
                      focal_fill_column = NULL,
                      status_column = NULL) {
  # recode NA sex to "unknown"
  # plot points with appropriate aesthetics
  if (config$debug == TRUE) {
    message("Adding nodes to the plot...")
    message("Focal fill column: ", focal_fill_column)
    message("Status column: ", status_column)
  }

  if (config$outline_include == TRUE) {
    plotObject <- plotObject +
      ggplot2::geom_point(
        ggplot2::aes(shape = as.factor(.data$sex)),
        size = config$point_size * config$outline_multiplier + config$outline_additional_size,
        na.rm = TRUE,
        color = config$outline_color,
        alpha = config$outline_alpha,
        stroke = config$segment_linewidth
      )
  }

  if (config$sex_color_include == TRUE) {
    # Use color and shape to represent sex
    plotObject <- plotObject +
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
      plotObject <- plotObject +
        ggplot2::geom_point(
          ggplot2::aes(
            color = .data$focal_fill,
            shape = as.factor(.data$sex)
          ),
          size = config$point_size,
          na.rm = TRUE
        )
    } else {
      plotObject <- plotObject +
        ggplot2::geom_point(
          ggplot2::aes(
            color = !!rlang::sym(focal_fill_column),
            shape = as.factor(.data$sex)
          ),
          size = config$point_size,
          na.rm = TRUE
        )
    }
  } else if (config$status_include == TRUE &&
    !is.null(status_column)) {
    # If status_column is present but sex_color_include is FALSE,
    # use shape for sex and color for affected status
    plotObject <- plotObject +
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
    plotObject <- plotObject +
      ggplot2::geom_point(ggplot2::aes(shape = as.factor(.data$sex)),
        size = config$point_size,
        na.rm = TRUE
      )
  }


  return(plotObject)
}

#' @rdname dot-addNodes
addNodes <- .addNodes


#' @title Add Overlay to ggplot Pedigree Plot
#' @inheritParams ggPedigree
#' @param plotObject A ggplot object.
#' @keywords internal
#' @return A ggplot object with added overlay.
#'
.addOverlay <- function(plotObject,
                        config,
                        focal_fill_column = NULL,
                        status_column = NULL,
                        overlay_column = NULL) {
  # print("Adding overlay to the plot...")
  if (config$overlay_include == TRUE && !is.null(overlay_column)) {
    # If overlay_column is specified, use it for alpha aesthetic
    plotObject <- plotObject + ggplot2::geom_point(
      ggplot2::aes(alpha = !!rlang::sym(overlay_column)),
      # config$overlay_alpha_values), #
      shape = config$overlay_shape,
      size = config$point_size,
      color = config$overlay_color,
      na.rm = TRUE
    )
    # print("Overlay added using overlay_column.")
  } else if (config$status_include == TRUE &&
    !is.null(status_column) && config$sex_color_include == TRUE) {
    # If no overlay_column is specified, use status_column for alpha aesthetic
    #
    plotObject <- plotObject + ggplot2::geom_point(
      ggplot2::aes(alpha = !!rlang::sym(status_column)),
      # config$status_alpha_values),
      shape = config$status_shape_affected,
      size = config$point_size,
      color = config$status_color_affected,
      na.rm = TRUE
    )
    # print("Overlay added using status_column.")
  } else if (config$focal_fill_include == TRUE &&
    !is.null(focal_fill_column) && config$sex_color_include == FALSE) {
    # If focal_fill_column is specified, use it for alpha aesthetic
    plotObject <- plotObject + ggplot2::geom_point(
      ggplot2::aes(alpha = !!rlang::sym(focal_fill_column)),
      shape = config$focal_fill_shape,
      size = config$point_size,
      color = config$focal_fill_mid_color,
      na.rm = TRUE
    )

    # print("Overlay added using focal_fill_column.")
  }

  return(plotObject)
}

#' @rdname dot-addOverlay
addOverlay <- .addOverlay


#' @title Add Self Segments to ggplot Pedigree Plot
#' @inheritParams ggPedigree
#' @param plotObject A ggplot object.
#' @keywords internal
#' @return A ggplot object with added scales.

.addSelfSegment <- function(plotObject, config, plot_connections) {
  otherself <- plot_connections$self_coords |>
    dplyr::filter(!is.na(.data$x_otherself)) |>
    dplyr::mutate(otherself_xkey = .makeSymmetricKey(.data$x_otherself, .data$x_pos)) |>
    # unique combinations of x_otherself and x_pos and y_otherself and y_pos
    dplyr::distinct(.data$otherself_xkey, .keep_all = TRUE) |>
    unique()
  if (config$return_interactive == FALSE) {
    plotObject <- plotObject + ggplot2::geom_curve(
      data = otherself,
      ggplot2::aes(
        x = .data$x_otherself,
        xend = .data$x_pos,
        y = .data$y_otherself,
        yend = .data$y_pos
      ),
      linewidth = config$segment_self_linewidth,
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
        midpoint = .computeCurvedMidpoint(
          x0 = .data$x_otherself,
          y0 = .data$y_otherself,
          x1 = .data$x_pos,
          y1 = .data$y_pos,
          curvature = config$segment_self_curvature,
          angle = config$segment_self_angle,
          t = .35
        ),
        x_1midpoint = .data$midpoint$x,
        y_1midpoint = .data$midpoint$y
      ) |>
      dplyr::mutate(
        midpoint = .computeCurvedMidpoint(
          x0 = .data$x_otherself,
          y0 = .data$y_otherself,
          x1 = .data$x_pos,
          y1 = .data$y_pos,
          curvature = config$segment_self_curvature,
          angle = config$segment_self_angle,
          t = .5
        ),
        x_2midpoint = .data$midpoint$x,
        y_2midpoint = .data$midpoint$y
      ) |>
      dplyr::mutate(
        midpoint = .computeCurvedMidpoint(
          x0 = .data$x_otherself,
          y0 = .data$y_otherself,
          x1 = .data$x_pos,
          y1 = .data$y_pos,
          curvature = config$segment_self_curvature,
          angle = config$segment_self_angle,
          t = .7
        ),
        x_3midpoint = .data$midpoint$x,
        y_3midpoint = .data$midpoint$y
      ) |>
      dplyr::select(-"midpoint")


    plotObject <- plotObject + ggplot2::geom_segment(
      data = otherself,
      ggplot2::aes(
        x = .data$x_otherself,
        xend = .data$x_1midpoint,
        y = .data$y_otherself,
        yend = .data$y_1midpoint
      ),
      linewidth = config$segment_self_linewidth,
      color = config$segment_self_color,
      lineend = config$segment_lineend,
      linejoin = config$segment_linejoin,
      linetype = config$segment_self_linetype,
      alpha = config$segment_self_alpha,
      na.rm = TRUE
    ) + ggplot2::geom_segment(
      data = otherself,
      ggplot2::aes(
        xend = .data$x_2midpoint,
        x = .data$x_1midpoint,
        yend = .data$y_2midpoint,
        y = .data$y_1midpoint
      ),
      linewidth = config$segment_self_linewidth,
      color = config$segment_self_color,
      lineend = config$segment_lineend,
      linejoin = config$segment_linejoin,
      linetype = config$segment_self_linetype,
      alpha = config$segment_self_alpha,
      na.rm = TRUE
    ) + ggplot2::geom_segment(
      data = otherself,
      ggplot2::aes(
        xend = .data$x_3midpoint,
        x = .data$x_2midpoint,
        yend = .data$y_3midpoint,
        y = .data$y_2midpoint
      ),
      linewidth = config$segment_self_linewidth,
      color = config$segment_self_color,
      lineend = config$segment_lineend,
      linejoin = config$segment_linejoin,
      linetype = config$segment_self_linetype,
      alpha = config$segment_self_alpha,
      na.rm = TRUE
    ) + ggplot2::geom_segment(
      data = otherself,
      ggplot2::aes(
        x = .data$x_3midpoint,
        xend = .data$x_pos,
        y = .data$y_3midpoint,
        yend = .data$y_pos
      ),
      linewidth = config$segment_self_linewidth,
      color = config$segment_self_color,
      lineend = config$segment_lineend,
      linejoin = config$segment_linejoin,
      linetype = config$segment_self_linetype,
      alpha = config$segment_self_alpha,
      na.rm = TRUE
    )
  }
  plotObject
}

#' @rdname dot-addSelfSegment
addSelfSegment <- .addSelfSegment

#' @title Add Scales to ggplot Pedigree Plot
#' @inheritParams ggPedigree
#' @param plotObject A ggplot object.
#' @keywords internal
#' @return A ggplot object with added scales.

.addScales <- function(plotObject,
                       config,
                       status_column = NULL,
                       focal_fill_column = NULL) {
  plotObject <- plotObject + ggplot2::scale_shape_manual(
    values = config$sex_shape_values,
    labels = config$sex_shape_labels
  )

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

  # Add color scale for sex or affected status if applicable
  if (config$sex_color_include == TRUE
  ) {
    if (!is.null(config$sex_color_palette)) {
      plotObject <- plotObject + ggplot2::scale_color_manual(
        values = config$sex_color_palette,
        labels = config$sex_shape_labels
      )
    } else {
      plotObject <- plotObject +
        ggplot2::scale_color_discrete(labels = config$sex_shape_labels)
    }

    plotObject <- plotObject +
      ggplot2::labs(
        color = config$sex_legend_title,
        shape = config$sex_legend_title
      )
    if (config$sex_legend_show == FALSE) {
      plotObject <- plotObject + ggplot2::guides(color = "none")
    }
  } else if (config$focal_fill_include == TRUE) {
    if (config$focal_fill_method %in% c("steps", "steps2", "step", "step2")) {
      plotObject <- plotObject + ggplot2::scale_colour_steps2(
        low = config$focal_fill_low_color,
        mid = config$focal_fill_mid_color,
        high = config$focal_fill_high_color,
        midpoint = config$focal_fill_scale_midpoint,
        n.breaks = config$focal_fill_n_breaks,
        na.value = config$focal_fill_na_value,
        transform = ifelse(config$focal_fill_use_log, "log2", "identity")
      )
    } else if (config$focal_fill_method %in% c("gradient2", "gradient")) {
      plotObject <- plotObject + ggplot2::scale_colour_gradient2(
        low = config$focal_fill_low_color,
        mid = config$focal_fill_mid_color,
        high = config$focal_fill_high_color,
        midpoint = config$focal_fill_scale_midpoint,
        n.breaks = config$focal_fill_n_breaks,
        na.value = config$focal_fill_na_value,
        transform = ifelse(config$focal_fill_use_log, "log2", "identity")
      )
    } else if (config$focal_fill_method %in% c("hue")) {
      plotObject <- plotObject + ggplot2::scale_color_hue(
        h = config$focal_fill_hue_range,
        c = config$focal_fill_chroma,
        l = config$focal_fill_lightness,
        direction = config$focal_fill_hue_direction,
        na.value = config$focal_fill_na_value # ,
        #  transform = ifelse(config$focal_fill_use_log,"log2","identity")
      )
    } else if (config$focal_fill_method %in% c("viridis_c")) {
      plotObject <- plotObject + ggplot2::scale_colour_viridis_c(
        option = config$focal_fill_viridis_option,
        begin = config$focal_fill_viridis_begin,
        end = config$focal_fill_viridis_end,
        direction = config$focal_fill_viridis_direction,
        na.value = config$focal_fill_na_value,
        transform = ifelse(config$focal_fill_use_log, "log2", "identity")
      )
    } else if (config$focal_fill_method %in% c("viridis_d")) {
      plotObject <- plotObject + ggplot2::scale_colour_viridis_d(
        option = config$focal_fill_viridis_option,
        begin = config$focal_fill_viridis_begin,
        end = config$focal_fill_viridis_end,
        direction = config$focal_fill_viridis_direction,
        na.value = config$focal_fill_na_value # ,
        #   transform = ifelse(config$focal_fill_use_log,"log2","identity")
      )
    } else if (config$focal_fill_method %in% c("viridis_b")) {
      plotObject <- plotObject + ggplot2::scale_colour_viridis_b(
        option = config$focal_fill_viridis_option,
        begin = config$focal_fill_viridis_begin,
        end = config$focal_fill_viridis_end,
        direction = config$focal_fill_viridis_direction,
        na.value = config$focal_fill_na_value,
        transform = ifelse(config$focal_fill_use_log, "log2", "identity")
      )
    } else if (config$focal_fill_method %in% c("manual")) {
      plotObject <- plotObject + ggplot2::scale_color_manual(
        values = config$focal_fill_color_values,
        labels = config$focal_fill_labels
      )
    } else {
      focal_fill_methods <- c(
        "steps", "steps2", "step", "step2",
        "viridis_c", "viridis_d", "viridis_b",
        "manual",
        "hue",
        "gradient2", "gradient"
      )
      stop(paste("focal_fill_method must be one of", paste(focal_fill_methods, collapse = ", ")))
    }
    plotObject <- plotObject +
      ggplot2::labs(
        color = if (config$focal_fill_legend_show == TRUE) {
          config$focal_fill_legend_title
        } else {
          NULL
        },
        shape = config$sex_legend_title
      )
    if (config$focal_fill_legend_show == FALSE) {
      plotObject <- plotObject + ggplot2::guides(color = "none")
    }
  } else if (!is.null(status_column) &&
    config$status_include == TRUE) {
    if (!is.null(config$status_color_palette)) {
      plotObject <- plotObject + ggplot2::scale_color_manual(
        values = config$status_color_values,
        labels = config$status_labels
      )
    } else {
      plotObject <- plotObject +
        ggplot2::scale_color_discrete(labels = config$status_labels)
    }
    plotObject <- plotObject +
      ggplot2::labs(
        color = config$status_legend_title,
        shape = config$sex_legend_title
      )
  } else {
    plotObject <- plotObject + ggplot2::labs(shape = config$sex_legend_title)
  }
  return(plotObject)
}

#' @rdname dot-addScales
addScales <- .addScales

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
      "The 'ggrepel' package is required for label methods 'geom_text_repel', 'ggrepel', and 'geom_label_repel'. Please install it using install.packages('ggrepel')."
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
      "Invalid label_method specified in config. Must be one of 'geom_text_repel', 'ggrepel', 'geom_label_repel', 'geom_label', or 'geom_text'."
    )
  }
  plotObject
}

#' @rdname dot-addLabels
addLabels <- .addLabels

#' @title Prepare Pedigree Data
#' @description
#' This function checks and prepares the pedigree data frame for use in ggPedigree.
#'
#' @inheritParams ggPedigree
#' @inheritParams transformPed
#' @param fill_group_family A character vector specifying the family fill group names.
#' @keywords internal
#' @return A data frame with the prepared pedigree data.
#'
#'
preparePedigreeData <- function(ped,
                                famID = "famID",
                                personID = "personID",
                                momID = "momID",
                                dadID = "dadID",
                                matID = "matID",
                                patID = "patID",
                                config = list(
                                  focal_fill_include = TRUE,
                                  focal_fill_component = "maternal",
                                  recode_missing_ids = TRUE
                                ),
                                fill_group_paternal = c(
                                  "paternal",
                                  "patID",
                                  "paternal line",
                                  "paternal lineages",
                                  "paternal lines"
                                ),
                                fill_group_maternal = c(
                                  "maternal",
                                  "matID",
                                  "maternal line",
                                  "maternal lineages",
                                  "maternal lines"
                                ),
                                fill_group_family = c(
                                  "family",
                                  "famID",
                                  "family line",
                                  "family lineages",
                                  "family lines"
                                ),
                                status_column = NULL,
                                phantoms = FALSE,
                                focal_fill_column = NULL) {
  # -----
  # STEP 2: Pedigree Data Transformation
  # -----

  # Transform the pedigree data frame to include family, paternal, and maternal IDs
  ds_ped <- transformPed(
    ped = ped,
    famID = famID,
    personID = personID,
    momID = momID,
    dadID = dadID,
    matID = matID,
    patID = patID,
    config = config,
    fill_group_paternal = fill_group_paternal,
    fill_group_maternal = fill_group_maternal
  )

  # ----
  # STEP 3: Data Cleaning and Recoding
  # ----

  # Recode affected status into factor, if applicable

  if (!is.null(status_column)) {
    ds_ped[[status_column]] <- factor(ds_ped[[status_column]],
      levels = config$status_codes,
      labels = config$status_labels
    )
  }

  # Standardize sex variable using code_male convention

  ds_ped <- BGmisc::recodeSex(ds_ped,
    recode_male = config$code_male,
    recode_na = config$code_na,
    recode_female = config$code_female
  )

  if (phantoms == TRUE) {
    # If phantoms are requested, add phantom parents
    ds_ped <- BGmisc::checkParentIDs(
      ds_ped,
      addphantoms = TRUE,
      repair = TRUE,
      parentswithoutrow = FALSE,
      repairsex = FALSE,
      personID = personID,
      momID = momID,
      dadID = dadID,
      famID = famID
    )
  }

  # Add focal fill column if specified

  ds_ped <- addFocalFillColumn(
    ds_ped = ds_ped,
    config = config,
    focal_fill_column = focal_fill_column,
    famID = famID,
    matID = matID,
    patID = patID,
    personID = personID,
    fill_group_family = fill_group_family,
    fill_group_maternal = fill_group_maternal,
    fill_group_paternal = fill_group_paternal
  )

  return(ds_ped)
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

  # Generate the coefficient of relationship matrix
  com_mat <- BGmisc::ped2com(
    ped = ped,
    component = component,
    personID = personID,
    isChild_method = config$matrix_isChild_method,
    sparse = config$matrix_sparse
  )

  if (config$matrix_sparse == TRUE) {
    warning(
      "Sparse matrix detected. Converting to data frame. Currently, sparse matrices are not supported for ggPedigree processing."
    )
    com_mat <- as.matrix(com_mat)
  }
  # find the row index of  ped that matches focal_fill_personID
  row_index <- which(ped[[personID]] == focal_fill_personID)
  if (length(row_index) == 0) {
    stop(paste(
      "focal_fill_personID",
      focal_fill_personID,
      "not found in ped$personID."
    ))
  }
  fill_df <- data.frame(
    focal_fill = round(com_mat[row_index, ], digits = config$value_rounding_digits),
    personID = rownames(com_mat)
  ) # needs to match the same data type

  remove(com_mat) # remove the focal_fill_personID column
  # Ensure fill_df$personID is of the same type as ped$personID
  if (is.numeric(ped$personID)) {
    fill_df$personID <- as.numeric(fill_df$personID)
  }
  if (config$focal_fill_force_zero == TRUE) {
    # If focal_fill_force_zero is TRUE, replace 0 with NA
    fill_df$focal_fill[fill_df$focal_fill == 0] <- NA_real_
  }
  fill_df
}

#' @title Process Pedigree Data
#' @description
#' This function processes the pedigree data frame to ensure it is in the correct format for ggPedigree.
#' It checks for the presence of family, paternal, and maternal IDs, and fills in missing components based on the configuration.
#' @inheritParams ggPedigree
#' @param fill_group_paternal A character vector specifying which paternal components to fill.
#' @param fill_group_maternal A character vector specifying which maternal components to fill.
#' @return A data frame with the processed pedigree data.
#' @keywords internal


transformPed <- function(ped,
                         famID = "famID",
                         personID = "personID",
                         momID = "momID",
                         dadID = "dadID",
                         matID = "matID",
                         patID = "patID",
                         config = list(
                           focal_fill_include = TRUE,
                           focal_fill_component = "maternal",
                           recode_missing_ids = TRUE
                         ),
                         fill_group_paternal = c(
                           "paternal",
                           "patID",
                           "paternal line",
                           "paternal lineages",
                           "paternal lines"
                         ),
                         fill_group_maternal = c(
                           "maternal",
                           "matID",
                           "maternal line",
                           "maternal lineages",
                           "maternal lines"
                         )) {
  if (config$recode_missing_ids == TRUE) {
    # handle 0 as missing IDs
    ped <- recodeMissingIDs(
      ped = ped,
      personID = personID,
      momID = momID,
      dadID = dadID,
      famID = famID,
      matID = matID,
      patID = patID,
      config = config
    )
  }
  # Check if famID, patID, matID are present; if not, create them
  if (!all(c(famID, patID, matID) %in% names(ped)) &&
    !famID %in% names(ped)) {
    ds_ped <- BGmisc::ped2fam(
      ped,
      famID = famID,
      personID = personID,
      momID = momID,
      dadID = dadID
    )
    if (!class(ped[[personID]]) %in% c("numeric", "integer") &&
      class(ds_ped[[personID]]) %in% c("numeric", "integer")
    ) {
      # fix strange converse of cases
      ds_ped[[personID]] <- as.character(ds_ped[[personID]])
    }
    if (!class(ped[[momID]]) %in% c("numeric", "integer") &&
      class(ds_ped[[momID]]) %in% c("numeric", "integer")
    ) {
      # fix strange converse of cases
      ds_ped[[momID]] <- as.character(ds_ped[[momID]])
    }
    if (!class(ped[[dadID]]) %in% c("numeric", "integer") &&
      class(ds_ped[[dadID]]) %in% c("numeric", "integer")
    ) {
      # fix strange converse of cases
      ds_ped[[dadID]] <- as.character(ds_ped[[dadID]])
    }
  } else {
    ds_ped <- ped
  }


  if (config$focal_fill_include == TRUE) {
    if (!patID %in% names(ds_ped) &&
      config$focal_fill_component %in% fill_group_paternal) {
      ds_ped <- BGmisc::ped2paternal(
        ds_ped,
        patID = patID,
        personID = personID,
        momID = momID,
        dadID = dadID
      )
      if (!class(ped[[personID]]) %in% c("numeric", "integer") &&
        class(ds_ped[[personID]]) %in% c("numeric", "integer")
      ) {
        # fix strange converse of cases
        ds_ped[[personID]] <- as.character(ds_ped[[personID]])
      }
    }

    if (!matID %in% names(ds_ped) &&
      config$focal_fill_component %in% fill_group_maternal) {
      ds_ped <- BGmisc::ped2maternal(
        ds_ped,
        matID = matID,
        personID = personID,
        momID = momID,
        dadID = dadID
      )
      if (!class(ped[[personID]]) %in% c("numeric", "integer") &&
        class(ds_ped[[personID]]) %in% c("numeric", "integer")
      ) {
        # fix strange converse of cases
        ds_ped[[personID]] <- as.character(ds_ped[[personID]])
      }
    }
  }
  return(ds_ped)
}


#' @title Add Focal Fill Column to Pedigree Data
#' @description
#' Adds a `focal_fill` column to the pedigree data based on configuration input.
#' Supports additive, mitochondrial, and line-based modes. If `focal_fill_column`
#' is specified, it takes priority over inferred modes.
#'
#' @inheritParams ggPedigree
#' @param ds_ped A data frame already processed by `transformPed()`.
#' @param fill_group_family Character vector specifying fill types for family lineage.
#' @param fill_group_maternal Character vector specifying fill types for maternal lineage.
#' @param fill_group_paternal Character vector specifying fill types for paternal lineage.
#' @return A data frame with a `focal_fill` column added if applicable.
#' @keywords internal
addFocalFillColumn <- function(ds_ped,
                               config,
                               focal_fill_column = NULL,
                               famID = "famID",
                               matID = "matID",
                               patID = "patID",
                               personID = "personID",
                               fill_group_family = c(
                                 "famID",
                                 "family",
                                 "family lineages",
                                 "family lines",
                                 "family line"
                               ),
                               fill_group_maternal = c(
                                 "maternal",
                                 "matID",
                                 "maternal line",
                                 "maternal lineages",
                                 "maternal lines"
                               ),
                               fill_group_paternal = c(
                                 "paternal",
                                 "patID",
                                 "paternal line",
                                 "paternal lineages",
                                 "paternal lines"
                               )) {
  # -----
  # STEP 1: Compute inferred fill column from component if no user-specified fill
  # -----
  if (config$focal_fill_include == TRUE &&
    is.null(focal_fill_column)) {
    # -----
    # CASE 1: Component-based fill (e.g., additive, mtDNA)
    # -----
    if (config$focal_fill_component %in% c(
      "additive",
      "common nuclear",
      "mitochondrial",
      "mtdna",
      "mitochondria"
    )) {
      # Use component matrix to generate fill values relative to focal individual
      # The function createFillColumn will handle the logic of creating the fill column
      ds_ped <- ds_ped |>
        dplyr::left_join(
          createFillColumn(
            ped = ds_ped,
            focal_fill_personID = config$focal_fill_personID,
            personID = personID,
            component = config$focal_fill_component,
            config = config
          ),
          by = dplyr::join_by(personID == !!rlang::sym(personID))
        )

      # -----
      # CASE 2: Lineage-based fill (family, maternal, paternal)
      # -----
    } else if (config$focal_fill_component %in% c(
      fill_group_family,
      fill_group_maternal,
      fill_group_paternal,
      matID,
      patID,
      famID
    )) {
      # Maternal fill → use matID
      if (config$focal_fill_component %in% fill_group_maternal) {
        config$focal_fill_component_recode <- matID
        ds_ped <- ds_ped |>
          dplyr::mutate(focal_fill = as.factor(.data[[matID]]))
      }

      # Paternal fill → use patID
      if (config$focal_fill_component %in% fill_group_paternal) {
        config$focal_fill_component_recode <- patID
        ds_ped <- ds_ped |>
          dplyr::mutate(focal_fill = as.factor(.data[[patID]]))
      }

      # Family fill → use famID
      if (config$focal_fill_component %in% fill_group_family) {
        config$focal_fill_component_recode <- famID
        ds_ped <- ds_ped |>
          dplyr::mutate(focal_fill = as.factor(.data[[famID]]))
      }
    }

    # -----
    # STEP 2: Use explicitly supplied fill column
    # -----
  } else if (config$focal_fill_include == TRUE &&
    !is.null(focal_fill_column)) {
    # Use column directly from pedigree data
    ds_ped <- ds_ped |>
      dplyr::mutate(focal_fill = !!rlang::sym(focal_fill_column))
  }

  # -----
  # STEP 3: Return modified data frame with focal_fill (if applicable)
  # -----
  return(ds_ped)
}
#' @title Add Twins to ggplot Pedigree Plot
#' @description
#' Adds twin connections to the ggplot pedigree plot.
#' This function modifies the `plotObject` by adding segments
#' to represent twin relationships.
#' @inheritParams ggPedigree
#' @param plotObject A ggplot object to which twin segments will be added.
#' @param connections A data frame containing twin connection coordinates.
#' @param plot_connections A data frame containing the coordinates for twin segments.
#' @keywords internal
#' @return A ggplot object with twin segments added.

addTwins <- function(plotObject,
                     connections,
                     config,
                     plot_connections,
                     personID = "personID") {
  # Sibling vertical drop line
  # special handling for twin sibling

  plotObject <- plotObject + ggplot2::geom_segment(
    data = plot_connections$twin_coords,
    ggplot2::aes(
      x = .data$x_mid_twin,
      xend = .data$x_mid_sib,
      y = .data$y_mid_twin - config$gap_hoff,
      yend = .data$y_mid_sib - config$gap_hoff
    ),
    linewidth = config$segment_linewidth,
    lineend = config$segment_lineend,
    linejoin = config$segment_linejoin,
    linetype = config$segment_linetype,
    color = config$segment_offspring_color,
    na.rm = TRUE
  ) +
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
    )

  if ("mz" %in% names(plot_connections$twin_coords) &&
    any(plot_connections$twin_coords$mz == TRUE, na.rm = TRUE)) {
    plotObject <- plotObject + # horizontal line to twin midpoint for MZ twins
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

  return(plotObject)
}
