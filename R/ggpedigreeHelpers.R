#' @title Compute point along a curved segment (quadratic Bézier)
#' @description
#' Computes the x–y coordinates of a point along a curved segment connecting
#' (x0, y0) to (x1, y1) using a quadratic Bézier construction. The control
#' point is defined by an orthogonal offset from the straight-line midpoint,
#' scaled by curvature * len and rotated by angle + shift (degrees).
#' Vectorized over input coordinates and t.
#'
#' @param x0 Numeric vector. X-coordinates of start points.
#' @param y0 Numeric vector. Y-coordinates of start points.
#' @param x1 Numeric vector. X-coordinates of end points.
#' @param y1 Numeric vector. Y-coordinates of end points.
#' @param t  Numeric scalar or vector in [0, 1]. Bézier parameter where 0 is the start point,
#' 1 is the end point; default 0.5.
#' @param curvature Curvature scale factor (as in
#'   *geom_curve*-style helpers): the control point is placed at a distance
#'   `curvature * len` from the segment midpoint in the rotated-perpendicular
#'   direction. Changing the sign flips the bend to the opposite side (after
#'   rotation).
#' @param angle Scalar numeric. Base rotation in degrees applied to the perpendicular before offsetting.
#' @param shift Scalar numeric. Additional rotation in degrees (default 0). Effective rotation is angle + shift.
#' @keywords internal
#'
#' @return A data frame with columns x, y, and t representing the coordinates along the curved segment.
#'
#' @details
#' * The unit perpendicular is constructed from the segment direction
#'   `(dx, dy)` as `(-uy, ux)` where `(ux, uy) = (dx, dy) / len`.
#' * If an input pair yields `len = 0` (identical endpoints), the unit
#'   direction is undefined and the resulting coordinates will be `NA`
#'   due to division by zero; inputs should avoid zero-length segments.
#' * Inputs of unequal length are recycled by base R. Prefer supplying
#'   conformable vectors to avoid unintended recycling.
#'
#' @seealso
#' Related drawing helpers such as `ggplot2::geom_curve()` for visual
#' reference on curvature semantics.
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
#' @rdname dot-computeCurvedMidpoint

computeCurvedMidpoint <- .computeCurvedMidpoint


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

  .to_angle <- function(x) {
    if (diff(x_range) == 0) return(rep((start_rad + end_rad) / 2, length(x)))
    start_rad + (x - x_range[1]) / diff(x_range) * (end_rad - start_rad)
  }

  .to_radius <- function(y) (y - y_range[1] + 1) * config$coord_radial_scale

  angle  <- .to_angle(ds$x_pos)
  radius <- .to_radius(ds$y_pos)
  ds$x_pos <- radius * cos(angle)
  ds$y_pos <- radius * sin(angle)

  # spread out the distance as we radiate outwards y_order tells you what generation you're in, so you can use that to spread out the
  # adjust x positions by multiplying by a factor that increases with y_order
  if(config$spread_out_generations == TRUE) {
   ds$x_pos <- ds$x_pos * (1 + (y_order_max/ds$y_order ))
  }

  if (FALSE & all(c("x_fam", "y_fam") %in% names(ds))) {
    valid_fam  <- !is.na(ds$x_fam) & !is.na(ds$y_fam)
    angle_fam  <- .to_angle(ifelse(valid_fam, ds$x_fam, ds$x_pos))
    radius_fam <- .to_radius(ifelse(valid_fam, ds$y_fam, ds$y_pos))
    ds$x_fam   <- ifelse(valid_fam, radius_fam * cos(angle_fam), NA_real_)
    ds$y_fam   <- ifelse(valid_fam, radius_fam * sin(angle_fam), NA_real_)
  }

  ds
}

#' @rdname dot-applyRadialLayout
applyRadialLayout <- .applyRadialLayout

#' @title Restore user-specified column names in a connections data frame
#' @description
#'
#' Rename standard internal columns in a pedigree connections data frame
#' back to user-specified names.
#' @param connections A data frame containing connection identifiers whose
#'   columns may currently be named with internal defaults such as
#'   `personID`, `momID`, `dadID`, `spouseID`, `twinID`, `famID`, and `sex`.
#' @inheritParams ggPedigree
#' @keywords internal

.restoreNames <- function(connections,
                          personID = "personID",
                          momID = "momID",
                          dadID = "dadID",
                          spouseID = "spouseID",
                          twinID = "twinID",
                          famID = "famID",
                          sexVar = "sex") {
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
  # instead this just duplicates the sex variable under a new name
  #  if ("sex" %in% names(connections) &&
  #   sexVar != "sex") {
  # Rename sex to the user-specified name
  #   names(connections)[names(connections) == "sex"] <- sexVar
  # }

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

#' @rdname dot-restoreNames
restoreNames <- .restoreNames


#' @title Recode Missing IDs in Pedigree Data
#' @description
#' This function recodes missing IDs in the pedigree data frame to NA.
#' It checks for specified missing codes (both numeric and character) in their respective columns.
#' @inheritParams ggPedigree
#' @param missing_code_numeric Numeric code representing missing IDs (default is 0).
#' @param missing_code_character Character vector representing missing IDs (default is c("0", "NA", "na", "")).
#' @return A data frame with missing IDs recoded to NA.
#' @keywords internal
recodeMissingIDs <- function(ped, momID = "momID", dadID = "dadID",
                             personID = "personID",
                             famID = "famID", matID = "matID", patID = "patID",
                             missing_code_numeric = 0,
                             missing_code_character = c("0", "NA", "na", ""),
                             config = list()) {
  # Which columns are treated as ID fields
  ids_to_check <- c(momID, dadID, personID, famID, matID, patID)
  if ("twinID" %in% names(ped)) {
    ids_to_check <- c(ids_to_check, "twinID")
  }
  ids_to_check <- unique(ids_to_check)

  # Loop through each ID column and recode missing codes to NA
  for (col_name in ids_to_check) {
    # Skip if the column is not present in the data
    if (!col_name %in% names(ped)) next

    # Work on a local copy of the column, then write it back once
    column_values <- ped[[col_name]]

    if (is.numeric(column_values) || is.integer(column_values)) {
      # Numeric column: replace missing_code_numeric with NA
      column_values[column_values == missing_code_numeric] <- NA
    } else {
      # Character or factor column: replace missing_code_character with NA
      column_values[column_values %in% missing_code_character] <- NA
    }
    # Write back the modified column
    ped[[col_name]] <- column_values
  }


  # Return the modified pedigree data frame

  ped
}
