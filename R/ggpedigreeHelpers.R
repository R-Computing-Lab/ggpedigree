#' @title Compute midpoint coordinate for curved segment
#' @description Returns x and y midpoint using vectorized curved offset
#' @param x0 Numeric vector of x coordinates for start points
#' @param y0 Numeric vector of y coordinates for start points
#' @param x1 Numeric vector of x coordinates for end points
#' @param y1 Numeric vector of y coordinates for end points
#' @param t Scalar value between 0 and 1 for interpolation (default is 0.5) setting the midpoint
#' @param curvature Scalar curvature (geom_curve style)
#' @param angle Scalar angle in degrees
#' @param shift Scalar shift in degrees (default is 0)
#' @return Numeric vector of midpoints (x or y)
#' @keywords internal
.computeCurvedMidpoint <- function(x0,
                                   y0,
                                   x1,
                                   y1,
                                   curvature,
                                   angle,
                                   shift = 0,
                                   t = 0.5) {
  # Ensure t is a numeric vector
  t <- as.numeric(t)

  # Vector from start to end
  dx <- x1 - x0
  dy <- y1 - y0
  len <- sqrt(dx^2 + dy^2)

  # Midpoint of the segment
  mx <- (x0 + x1) / 2
  my <- (y0 + y1) / 2

  # Unit direction vector
  ux <- dx / len
  uy <- dy / len

  # Perpendicular unit vector
  perp_x <- -uy
  perp_y <- ux

  # Apply rotation: angle + shift
  theta <- (angle + shift) * pi / 180

  rot_x <- perp_x * cos(theta) - perp_y * sin(theta)
  rot_y <- perp_x * sin(theta) + perp_y * cos(theta)

  # Control point (defines curvature)
  cx <- mx + curvature * len * rot_x
  cy <- my + curvature * len * rot_y

  # Quadratic Bezier formula, vectorized
  x_vals <- (1 - t)^2 * x0 + 2 * (1 - t) * t * cx + t^2 * x1
  y_vals <- (1 - t)^2 * y0 + 2 * (1 - t) * t * cy + t^2 * y1

  # Return as a data frame with x and y coordinates
  data.frame(x = x_vals, y = y_vals, t = t)
}
#' @title Adjust Spacing in ggPedigree Data
#' @description
#' This function adjusts the vertical and horizontal spacing of the ggPedigree data
#' based on the configuration settings for generation height and width.
#' @param ds A data frame containing the ggPedigree data.
#' @inheritParams ggPedigree
#' @return A data frame with adjusted x and y positions.
#' @keywords internal

.adjustSpacing <- function(ds, config) {
  # Adjust vertical spacing factor if generation_height ≠ 1
  if (!isTRUE(all.equal(config$generation_height, 1))) {
    ds$y_pos <- ds$y_pos * config$generation_height # expand/contract generations
    ds$y_fam <- ds$y_fam * config$generation_height # expand/contract generations
  }
  # Adjust horizontal spacing factor if generation_width ≠ 1
  if (!isTRUE(all.equal(config$generation_width, 1))) {
    ds$x_pos <- ds$x_pos * config$generation_width # expand/contract generations
    ds$x_fam <- ds$x_fam * config$generation_width # expand/contract generations
  }
  ds
}

#' @title Restore Names in Connections Data Frame
#' @description
#'
#' This function restores the names of the columns in the connections data frame
#' to the user-specified names.
#' @param connections A data frame containing the connections data.
#' @inheritParams ggPedigree
#' @keywords internal

.restoreNames <- function(connections,
                          personID = "personID",
                          momID = "momID",
                          dadID = "dadID",
                          spouseID = "spouseID",
                          twinID = "twinID",
                          famID = "famID") {
  # Restore the names of the columns in connections
  # to the user-specified names
  if (!is.data.frame(connections)) {
    stop("connections must be a data frame.")
  }

  if (twinID != "twinID" && "twinID" %in% names(connections)) {
    # If twin coordinates are present, restore the twinID name
    # Rename twinID to the user-specified name
    names(connections)[names(connections) == "twinID"] <- twinID
  }

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
  if ("spouseID" %in% names(connections) &&
    spouseID != "spouseID") {
    # Rename spouseID to the user-specified name
    names(connections)[names(connections) == "spouseID"] <- spouseID
  }
  # Rename famID to the user-specified name
  if (famID != "famID") {
    # Rename famID to the user-specified name
    names(connections)[names(connections) == "famID"] <- famID
  }

  # Return the modified connections data frame
  connections
}
