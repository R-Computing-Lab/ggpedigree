#' @title Adjust spacing in ggPedigree coordinate columns
#' @description
#' Uniformly expands or contracts the horizontal (`x_*`) and vertical (`y_*`)
#' configuration settings for generation height and width.
#' @param ds A data frame containing the ggPedigree data.
#' @inheritParams ggPedigree
#' @return A data frame with adjusted x and y positions.
#' @keywords internal

.adjustSpacing <- function(ds, config) {
  # set shift y to have min at zero
  min_y <- min(ds$y_pos, na.rm = TRUE)
  if (min_y > 0) {
    ds$y_pos <- ds$y_pos - min_y
    ds$y_fam <- ds$y_fam - min_y
  }

  # Adjust vertical spacing factor if generation_height ≠ 1
  if (!isTRUE(all.equal(config$generation_height, 1))) {
    ds$y_pos <- ds$y_pos * config$generation_height # expand/contract generations
    ds$y_fam <- ds$y_fam * config$generation_height
  }
  # Adjust horizontal spacing factor if generation_width ≠ 1
  if (!isTRUE(all.equal(config$generation_width, 1))) {
    ds$x_pos <- ds$x_pos * config$generation_width # expand/contract generations
    ds$x_fam <- ds$x_fam * config$generation_width
  }
  ds
}

#' @rdname dot-adjustSpacing
adjustSpacing <- .adjustSpacing

#' @title Apply radial layout transformation to pedigree coordinates
#' @description
#' Transforms Cartesian pedigree coordinates (x_pos = horizontal slot,
#' y_pos = generation) into Cartesian coordinates derived from a polar mapping,
#' producing a circular or fan-shaped layout. The transformation maps x_pos to
#' an angular position and y_pos to a radial distance, then converts back to
#' (x, y) via standard polar-to-Cartesian conversion.
#' Family bar positions (x_fam, y_fam) are transformed using the same mapping.
#' @param ds A data frame containing at minimum x_pos, y_pos, x_fam, and y_fam columns,
#'   as produced by calculateCoordinates and .adjustSpacing.
#' @inheritParams ggPedigree
#' @return The input data frame with x_pos, y_pos, x_fam, and y_fam replaced by
#'   their radially transformed equivalents.
#' @keywords internal
.applyRadialLayout <- function(ds, config) {
  start_rad <- config$coord_radial_start_angle * pi / 180
  end_rad   <- config$coord_radial_end_angle   * pi / 180

  x_range <- range(ds$x_pos, na.rm = TRUE)
  y_range <- range(ds$y_pos, na.rm = TRUE)

  y_order_range <- range(ds$y_order, na.rm = TRUE)
  y_order_max <- y_order_range[2]

  # how many in gen 0, gen 1, gen 2, etc. use that to spread out the distance as we radiate outwards



  .to_angle <- function(x) {
    if (diff(x_range) == 0) return(rep((start_rad + end_rad) / 2, length(x)))
    start_rad + (x - x_range[1]) / diff(x_range) * (end_rad - start_rad)
  }

  .to_radius <- function(y) (y_range[1]-y + 1) * config$coord_radial_scale

  angle  <- .to_angle(ds$x_pos)
  radius <- .to_radius(ds$y_pos)
  ds$x_pos <- radius * cos(angle)
  ds$y_pos <- radius * sin(angle)
  ds$y_pos[ds$y_pos==0] <- 0.001 # avoid zero y positions to prevent issues with family bars
  ds$x_pos[ds$x_pos==0] <- 0.001 # avoid zero x positions to prevent issues with family bars
  # spread out the distance as we radiate outwards y_order tells you what generation you're in, so you can use that to spread out the
  # adjust x positions by multiplying by a factor that increases with y_order
#  if(config$spread_out_generations == TRUE) {

 # if (config$spread_out_generations == TRUE) {
    spread_factor <- 1 + (ds$y_order / y_order_max) * config$spread_out_generations_factor
    ds$x_pos <- ds$x_pos * spread_factor
    ds$y_pos <- ds$y_pos * spread_factor
#  }

#  }

  ds
}

#' @rdname dot-applyRadialLayout
applyRadialLayout <- .applyRadialLayout
