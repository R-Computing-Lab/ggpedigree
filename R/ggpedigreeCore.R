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
                            overlays = NULL,
                            status_column = NULL,
                            code_male = NULL,
                            config = list(),
                            debug = FALSE,
                            hints = NULL,
                            sexVar = "sex",
                            function_name = "ggPedigree",
                            affected_fill_column = NULL,
                            outline_color_column = NULL) {
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

  if (sexVar != "sex" && sexVar %in% names(ped)) {
    # names(ped)[names(ped) == sexVar] <- "sex"
    ped$sex <- ped[[sexVar]]
  }

  if(config$coord_layout == "radial"){
    # In radial layout, the generation axis is reversed (older generations have higher y values)
    config$generation_height <- -1 * config$generation_height
  }

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
    focal_fill_column = focal_fill_column
  )

  if (config$debug == TRUE) {
    message("Pedigree data prepared. Number of individuals: ", nrow(ds_ped))

    # assign("DEBUG_ds_ped", ds_ped, envir = .GlobalEnv)
  }


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
    famID = famID # ,
    #   sexVar = sexVar
  )


  # -----
  # STEP 6: Initialize Plot
  # -----

  # In radial mode stubs are meaningless (y is no longer the generation axis)
  config$gap_hoff <- if (isTRUE(config$coord_layout == "radial")){
    0
  #  0.5 *config$generation_height
    } else {
      0.5 * config$generation_height
      }
  config$gap_woff <- if (isTRUE(config$coord_layout == "radial")){
  #  0
    0.5 *config$generation_width
  }else {0.5 * config$generation_width
      }

  # recode missing sex to "unknown"
  if (config$recode_missing_sex == TRUE && any(is.na(ds$sex))) {
    non_na_sex <- unique(ds$sex)[!is.na(ds$sex)]
    n_unique_sex <- length(non_na_sex)

    if (is.character(ds$sex) || is.factor(ds$sex)) {
      ds <- ds |>
        dplyr::mutate(sex = dplyr::case_when(
          is.na(.data$sex) ~ "Unknown",
          TRUE ~ as.character(.data$sex)
        ))
    } else if (is.numeric(ds$sex) || is.integer(ds$sex)) {
      max_sex <- max(ds$sex, na.rm = TRUE)

      if (n_unique_sex == 3 && (max_sex == 3 || max_sex == 2)) {
        ds <- ds |>
          dplyr::mutate(sex = dplyr::case_when(
            is.na(.data$sex) ~ 3,
            TRUE ~ as.numeric(.data$sex)
          ))
      } else if (n_unique_sex == 2) {
        ds <- ds |>
          dplyr::mutate(sex = dplyr::case_when(
            is.na(.data$sex) ~ max(ds$sex, na.rm = TRUE) + 1,
            TRUE ~ as.numeric(.data$sex)
          ))
      }
    }
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

    p <- .addTwins(
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
    status_column = status_column,
    affected_fill_column = affected_fill_column,
    outline_color_column = outline_color_column
  )

  # Add overlay points for affected status if applicable
  # Normalize overlays: if overlays list is provided, use it; otherwise fall back
  # to single overlay_column for backward compatibility
  overlay_specs <- NULL

  if (!is.null(overlays) && is.list(overlays) && length(overlays) > 0) {
    overlay_specs <- overlays
  } else if (!is.null(overlay_column)) {
    # Wrap single overlay_column into a one-element list using config defaults
    overlay_specs <- list(list(column = overlay_column))
  }

  if (!is.null(overlay_specs)) {
    for (spec in overlay_specs) {
      spec_column <- spec$column
      if (is.null(spec_column) || !spec_column %in% names(ds)) next

      spec_mode <- if (!is.null(spec$mode)) spec$mode else config$overlay_mode

      if (spec_mode == "shape") {
        # Shape-mode overlay: draw a shape (e.g., cross) on matching individuals
        p <- .addShapeOverlay(
          plotObject = p,
          config = config,
          overlay_column = spec_column,
          overlay_spec = spec
        )
      } else {
        # Alpha-mode overlay (default): use alpha transparency mapping
        p <- .addOverlay(
          plotObject = p,
          config = config,
          focal_fill_column = focal_fill_column,
          status_column = status_column,
          overlay_column = spec_column
        )
      }
    }
  } else if (.should_add_overlay(config, overlay_column, status_column, focal_fill_column)) {
    # Legacy alpha overlay fallback (status/focal_fill driven, no overlay_column)
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
  # scale min


  if (is.na(min(ds$y_pos, na.rm = TRUE))) {
    warning(
      "y_pos contains all NA values, cannot set y-axis limits. ",
      "This occurs when there are less than two people in the pedigree."
    )
    p <- p +
      ggplot2::scale_y_reverse()
  } else {
    p <- p +
      ggplot2::scale_y_reverse(limits = c(
        NA,
        min(ds$y_pos, na.rm = TRUE)
      ))
  }
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
      focal_fill_column = focal_fill_column,
      affected_fill_column = affected_fill_column,
      outline_color_column = outline_color_column
    )
  }
  if (isTRUE(config$coord_layout == "radial")){
    p <- p + ggplot2::coord_polar()
  }


  # add plot_connections to the plot object
  attr(p, "connections") <- plot_connections
  if (config$debug == TRUE) {
    list(
      plot = p,
      data = ds,
      connections = connections,
      config = config
    )
  } else {
    # If debug is FALSE, return only the plot

    p
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
                      status_column = NULL,
                      affected_fill_column = NULL,
                      outline_color_column = NULL) {
  # plot points with appropriate aesthetics
  if (config$debug == TRUE) {
    message("Adding nodes to the plot...")
    message("Focal fill column: ", focal_fill_column)
    message("Status column: ", status_column)
    message("Affected fill column: ", affected_fill_column)
    message("Outline color column: ", outline_color_column)
  }

  # Handle outline: either column-based or config-based
  if (!is.null(outline_color_column)) {
    # Column-based outline coloring (independent from other aesthetics)
    plotObject <- plotObject +
      ggplot2::geom_point(
        ggplot2::aes(
          shape = as.factor(.data$sex),
          color = as.factor(!!rlang::sym(outline_color_column))
        ),
        size = config$point_size * config$outline_multiplier + config$outline_additional_size,
        na.rm = TRUE,
        alpha = config$outline_alpha,
        stroke = config$segment_linewidth
      )
  } else if (isTRUE(config$outline_include)) {
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

  # Handle affected fill column (clinical pedigree conditional fill)
  if (!is.null(affected_fill_column)) {
    # Determine node border color for filled shapes
    node_border_color <- if (!is.null(config$outline_color_unaffected)) config$outline_color_unaffected else config$outline_color

    # Use filled shapes for affected, unfilled for unaffected
    plotObject <- plotObject +
      ggplot2::geom_point(
        ggplot2::aes(
          shape = as.factor(.data$sex),
          fill = as.factor(!!rlang::sym(affected_fill_column))
        ),
        size = config$point_size,
        na.rm = TRUE,
        color = node_border_color,
        stroke = config$segment_linewidth * 0.5
      )
    return(plotObject)
  }

  # 2) Determine which "node mode" to use (exactly one)
  node_mode <- .pick_first(
    rules = list(
      list(
        when = function() isTRUE(config$sex_color_include),
        do   = "sex_color"
      ),
      list(
        when = function() isTRUE(config$focal_fill_include),
        do   = "focal_fill"
      ),
      list(
        when = function() isTRUE(config$status_include) && !is.null(status_column),
        do   = "status"
      )
    ),
    default = "shape_only"
  )


  # 3) Add the selected layer
  if (node_mode == "sex_color") {
    plotObject <- plotObject +
      ggplot2::geom_point(
        ggplot2::aes(
          color = as.factor(.data$sex),
          shape = as.factor(.data$sex)
        ),
        size = config$point_size,
        na.rm = TRUE
      )
  } else if (node_mode == "focal_fill") {
    # Preserve your original "if focal_fill_column is NULL, use .data$focal_fill"
    color_expr <- if (is.null(focal_fill_column)) rlang::expr(.data$focal_fill) else rlang::sym(focal_fill_column)

    plotObject <- plotObject +
      ggplot2::geom_point(
        ggplot2::aes(
          color = !!color_expr,
          shape = as.factor(.data$sex)
        ),
        size = config$point_size,
        na.rm = TRUE
      )
  } else if (node_mode == "status") {
    plotObject <- plotObject +
      ggplot2::geom_point(
        ggplot2::aes(
          color = as.factor(!!rlang::sym(status_column)),
          shape = as.factor(.data$sex)
        ),
        size = config$point_size,
        na.rm = TRUE
      )
  } else { # "shape_only"
    plotObject <- plotObject +
      ggplot2::geom_point(
        ggplot2::aes(shape = as.factor(.data$sex)),
        size = config$point_size,
        na.rm = TRUE
      )
  }

  plotObject
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
                        config = list(
                          overlay_include = FALSE,
                          status_include = FALSE,
                          focal_fill_include = FALSE,
                          sex_color_include = FALSE
                        ),
                        focal_fill_column = NULL,
                        status_column = NULL,
                        overlay_column = NULL) {
  # print("Adding overlay to the plot...")

  overlay_spec <- .pick_first(
    rules = list(
      list(
        when = function() isTRUE(config$overlay_include) && !is.null(overlay_column),
        do = list(
          alpha_var = overlay_column,
          shape = config$overlay_shape,
          color = config$overlay_color
        )
      ),
      list(
        when = function() {
          isTRUE(config$status_include) &&
            !is.null(status_column) &&
            isTRUE(config$sex_color_include)
        },
        do = list(
          alpha_var = status_column,
          shape = config$status_shape_affected,
          color = config$status_color_affected
        )
      ),
      list(
        when = function() {
          isTRUE(config$focal_fill_include) &&
            exists("focal_fill_column") && !is.null(focal_fill_column) &&
            !isTRUE(config$sex_color_include)
        },
        do = list(
          alpha_var  = focal_fill_column,
          shape      = config$focal_fill_shape,
          color      = config$focal_fill_mid_color
        )
      )
    ),
    default = NULL
  )

  if (!is.null(overlay_spec)) {
    # Convert to symbol only after a rule has been selected
    overlay_spec$alpha_expr <- rlang::sym(overlay_spec$alpha_var)

    plotObject <- plotObject +
      ggplot2::geom_point(
        ggplot2::aes(alpha = !!overlay_spec$alpha_expr),
        shape = overlay_spec$shape,
        size = config$point_size,
        color = overlay_spec$color,
        na.rm = TRUE
      )
  }

  plotObject
}

#' @rdname dot-addOverlay
addOverlay <- .addOverlay

#' @title Add Shape Overlay to ggplot Pedigree Plot
#' @description Draws a shape (cross, slash, or x) over symbols of matching individuals.
#'   Used when overlay_mode is "shape" to draw markers on top of pedigree symbols
#'   (e.g., cross for deceased individuals).
#' @inheritParams ggPedigree
#' @param plotObject A ggplot object.
#' @param overlay_column Character string specifying the column name for overlay status.
#' @param overlay_spec Optional list of per-overlay settings that override config defaults.
#'   Recognized keys: \code{shape}, \code{color}, \code{size}, \code{stroke}, \code{code_affected}.
#' @keywords internal
#' @return A ggplot object with shape overlay markers added.
#'
.addShapeOverlay <- function(plotObject, config, overlay_column, overlay_spec = NULL) {
  # Per-overlay spec overrides config defaults
  overlay_shape <- if (!is.null(overlay_spec$shape)) overlay_spec$shape else config$overlay_shape
  # Support named shape strings for convenience
  if (is.character(overlay_shape)) {
    shape_code <- switch(overlay_shape,
      "cross" = 4L, # x cross (conventional deceased marker)
      "slash" = 47L, # / slash
      "x"     = 8L, # asterisk-like x mark
      4L # default to cross
    )
  } else {
    shape_code <- as.integer(overlay_shape)
  }
  spec_size <- if (!is.null(overlay_spec$size)) overlay_spec$size else config$overlay_size
  shape_size <- if (!is.null(spec_size)) spec_size else config$point_size
  shape_color <- if (!is.null(overlay_spec$color)) overlay_spec$color else config$overlay_color
  shape_stroke <- if (!is.null(overlay_spec$stroke)) overlay_spec$stroke else config$overlay_stroke
  overlay_code <- if (!is.null(overlay_spec$code_affected)) overlay_spec$code_affected else config$overlay_code_affected
  col <- overlay_column

  plotObject <- plotObject +
    ggplot2::geom_point(
      data = function(d) d[d[[col]] == overlay_code, , drop = FALSE],
      ggplot2::aes(x = .data$x_pos, y = .data$y_pos),
      shape = shape_code,
      size = shape_size,
      color = shape_color,
      stroke = shape_stroke,
      na.rm = TRUE,
      inherit.aes = FALSE
    )

  plotObject
}

#' @rdname dot-addShapeOverlay
addShapeOverlay <- .addShapeOverlay


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

    # Add segments in four parts to approximate a curve
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

.addTwins <- function(plotObject,
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

  plotObject
}
#' @rdname dot-addTwins
addTwins <- .addTwins
