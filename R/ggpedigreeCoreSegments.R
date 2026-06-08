#' @title Add a single (possibly lineage-colored) segment layer
#' @description
#' Internal helper that appends a `geom_segment` layer to a ggplot object. When
#' `lineage_active` is `TRUE` and the segment `type` participates in lineage
#' coloring (and the data carries a `segment_lineage` column), the layer maps the
#' `colour` aesthetic to `segment_lineage`. Otherwise it uses the fixed per-type
#' color `config[["segment_<type>_color"]]`, preserving the original behavior.
#' @param plotObject A ggplot object.
#' @param data A data frame supplying the segment endpoints.
#' @param mapping An `aes()` mapping for the segment geometry (x/xend/y/yend).
#' @param type Segment type, one of "spouse", "parent", "offspring", "sibling", "mz".
#' @param config A configuration list.
#' @param lineage_active Logical; whether lineage coloring is in effect for this plot.
#' @param ... Additional arguments passed to `ggplot2::geom_segment()`.
#' @keywords internal
#' @return A ggplot object with the segment layer added.
.addSegmentLayer <- function(plotObject, data, mapping, type, config,
                             lineage_active = FALSE, ...) {
  dots <- list(...)
  use_lineage <- isTRUE(lineage_active) &&
    type %in% config$segment_lineage_types &&
    "segment_lineage" %in% names(data)

  if (isTRUE(use_lineage)) {
    mapping <- utils::modifyList(
      mapping,
      ggplot2::aes(colour = .data$segment_lineage)
    )
    layer <- do.call(
      ggplot2::geom_segment,
      c(list(data = data, mapping = mapping), dots)
    )
  } else {
    fixed_color <- config[[paste0("segment_", type, "_color")]]
    layer <- do.call(
      ggplot2::geom_segment,
      c(list(data = data, mapping = mapping, colour = fixed_color), dots)
    )
  }
  plotObject + layer
}

#' @title Add Self Segments to ggplot Pedigree Plot
#' @inheritParams ggPedigree
#' @param plotObject A ggplot object.
#' @keywords internal
#' @return A ggplot object with added scales.

.addSelfSegment <- function(plotObject, config = list(
  return_interactive = FALSE,
  segment_self_linewidth = 0.5,
  segment_self_color = "grey50",
  segment_lineend = "round",
  segment_linejoin = "round",
  segment_self_linetype = "solid",
  segment_self_angle = 90,
  segment_self_curvature = 0.5,
  segment_self_alpha = 1

  )
                            , plot_connections) {
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
  } else if (isTRUE(config$return_interactive)) {
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
          t = .15
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
          t = .30
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
          t = .5
        ),
        x_3midpoint = .data$midpoint$x,
        y_3midpoint = .data$midpoint$y
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
      dplyr::select(-"midpoint")  |>
      dplyr::mutate(
        midpoint = .computeCurvedMidpoint(
          x0 = .data$x_otherself,
          y0 = .data$y_otherself,
          x1 = .data$x_pos,
          y1 = .data$y_pos,
          curvature = config$segment_self_curvature,
          angle = config$segment_self_angle,
          t = .85
        ),
        x_4midpoint = .data$midpoint$x,
        y_4midpoint = .data$midpoint$y
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
        xend = .data$x_4midpoint,
        y = .data$y_3midpoint,
        yend = .data$y_4midpoint
      ),
      linewidth = config$segment_self_linewidth,
      color = config$segment_self_color,
      lineend = config$segment_lineend,
      linejoin = config$segment_linejoin,
      linetype = config$segment_self_linetype,
      alpha = config$segment_self_alpha,
      na.rm = TRUE
    )  + ggplot2::geom_segment(
      data = otherself,
      ggplot2::aes(
        x = .data$x_4midpoint,
        xend = .data$x_pos,
        y = .data$y_4midpoint,
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
#' @param lineage_active Logical; whether lineage coloring is in effect for this plot.
#' @keywords internal
#' @return A ggplot object with twin segments added.

.addTwins <- function(plotObject,
                      connections,
                      config,
                      plot_connections,
                      personID = "personID",
                      lineage_active = FALSE) {
  # Sibling vertical drop line
  # special handling for twin sibling

  plotObject <- .addSegmentLayer(
    plotObject,
    data = plot_connections$twin_coords,
    mapping = ggplot2::aes(
      x = .data$x_mid_twin,
      xend = .data$x_mid_sib,
      y = .data$y_mid_twin - config$gap_hoff,
      yend = .data$y_mid_sib - config$gap_hoff
    ),
    type = "offspring",
    config = config,
    lineage_active = lineage_active,
    linewidth = config$segment_linewidth,
    lineend = config$segment_lineend,
    linejoin = config$segment_linejoin,
    linetype = config$segment_linetype,
    na.rm = TRUE
  )

  plotObject <- .addSegmentLayer(
    plotObject,
    data = plot_connections$twin_coords,
    mapping = ggplot2::aes(
      x = .data$x_pos,
      xend = .data$x_mid_twin,
      y = .data$y_pos,
      yend = .data$y_mid_twin - config$gap_hoff
    ),
    type = "sibling",
    config = config,
    lineage_active = lineage_active,
    linewidth = config$segment_linewidth,
    lineend = config$segment_lineend,
    linejoin = config$segment_linejoin,
    linetype = config$segment_linetype,
    na.rm = TRUE
  )

  if ("mz" %in% names(plot_connections$twin_coords) &&
    any(plot_connections$twin_coords$mz == TRUE, na.rm = TRUE)) {
    plotObject <- .addSegmentLayer(
      plotObject,
      data = plot_connections$twin_coords |>
        dplyr::filter(.data$mz == TRUE),
      mapping = ggplot2::aes(
        x = .data$x_start,
        xend = .data$x_end,
        y = .data$y_start,
        yend = .data$y_end
      ),
      type = "mz",
      config = config,
      lineage_active = lineage_active,
      linewidth = config$segment_linewidth,
      lineend = config$segment_lineend,
      linejoin = config$segment_linejoin,
      linetype = config$segment_mz_linetype,
      alpha = config$segment_mz_alpha,
      na.rm = TRUE
    )
  }

  plotObject
}
#' @rdname dot-addTwins
addTwins <- .addTwins
