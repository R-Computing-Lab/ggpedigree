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

#' @title Renumber Pedigree IDs
#' @description
#' Renumber pedigree identifiers to short sequential integer values while
#' preserving parent-child references.
#'
#' The function constructs a crosswalk from the original person identifiers to
#' new integer identifiers beginning at 1. The same crosswalk is then applied to
#' the person, mother, and father identifier columns, ensuring that references
#' remain internally consistent. For example, if an original `personID` is
#' recoded to 1, then any matching value in the mother or father identifier
#' columns is also recoded to 1.
#'
#' @param ped A data frame containing pedigree identifiers.
#' @param personID Character scalar. Name of the column containing unique person
#'   identifiers. Default is `"personID"`.
#' @param momID Character scalar. Name of the column containing maternal
#'   identifiers. Default is `"momID"`.
#' @param dadID Character scalar. Name of the column containing paternal
#'   identifiers. Default is `"dadID"`.
#' @param sort_ids Logical scalar. If `TRUE`, original identifiers are sorted
#'   before assigning new IDs. If `FALSE`, new IDs follow the order of first
#'   appearance in `ped[[personID]]`. Default is `TRUE`.
#' @param return_key Logical scalar. If `TRUE`, returns a list containing both
#'   the renumbered pedigree data frame and the ID crosswalk. If `FALSE`,
#'   returns only the renumbered pedigree data frame. Default is `FALSE`.
#' @keywords internal
#'
#' @return
#' If `return_key = FALSE`, a data frame with renumbered person, mother, and
#' father identifiers.
#'
#' If `return_key = TRUE`, a list with two elements:
#' \describe{
#'   \item{ped}{The renumbered pedigree data frame.}
#'   \item{id_key}{A data frame mapping original IDs to new IDs.}
#' }
#'
#' @details
#' * Only values appearing in the person identifier column are used to construct
#'   the ID crosswalk.
#' * Parent identifiers that do not appear in the person identifier column are
#'   recoded to `NA`, because they cannot be matched to a known individual in
#'   the data.
#' * Existing `NA` values in the mother and father identifier columns remain
#'   `NA`.
#' * The returned ID columns are integer vectors.
#'
#' @seealso
#' Related pedigree-cleaning helpers such as `recodeMissingIDs()`.
.renumberPedigreeIDs <- function(ped,
                                 personID = "personID",
                                 momID = "momID",
                                 dadID = "dadID",
                                 twinID = "twinID",
                                 spouseID = "spouseID",
                                 sort_ids = TRUE,
                                 return_key = FALSE) {
  # Check that ped is a data frame
  if (!is.data.frame(ped)) {
    stop("ped must be a data frame.")
  }

  # Check that column names are character scalars
  if (!is.character(personID) || length(personID) != 1) {
    stop("personID must be a character scalar.")
  }
  if (!is.character(momID) || length(momID) != 1) {
    stop("momID must be a character scalar.")
  }
  if (!is.character(dadID) || length(dadID) != 1) {
    stop("dadID must be a character scalar.")
  }

  # Check that required columns are present
  required_cols <- c(personID, momID, dadID)
  missing_cols <- required_cols[!required_cols %in% names(ped)]

  if (length(missing_cols) > 0) {
    stop(
      "ped is missing required column(s): ",
      paste(missing_cols, collapse = ", ")
    )
  }

  # Extract original person identifiers
  old_ids <- unique(ped[[personID]])

  # Remove missing person identifiers from the crosswalk
  old_ids <- old_ids[!is.na(old_ids)]

  # Optionally sort original identifiers before assigning new IDs
  if (sort_ids) {
    old_ids <- sort(old_ids)
  }

  # Construct the ID crosswalk
  id_key <- data.frame(
    oldID = old_ids,
    newID = seq_along(old_ids),
    stringsAsFactors = FALSE
  )

  # Construct a named lookup vector
  id_lookup <- stats::setNames(id_key$newID, as.character(id_key$oldID))

  # Apply the same lookup to person, mother, and father identifiers
  ped[[personID]] <- unname(id_lookup[as.character(ped[[personID]])])
  ped[[momID]] <- unname(id_lookup[as.character(ped[[momID]])])
  ped[[dadID]] <- unname(id_lookup[as.character(ped[[dadID]])])


  # Coerce recoded identifiers to integer
  ped[[personID]] <- as.integer(ped[[personID]])
  ped[[momID]] <- as.integer(ped[[momID]])
  ped[[dadID]] <- as.integer(ped[[dadID]])

    if (twinID %in% names(ped)) {
    ped[[twinID]] <- unname(id_lookup[as.character(ped[[twinID]])])
    ped[[twinID]] <- as.integer(ped[[twinID]])
  }
  if (spouseID %in% names(ped)) {
    ped[[spouseID]] <- unname(id_lookup[as.character(ped[[spouseID]])])
    ped[[spouseID]] <- as.integer(ped[[spouseID]])
  }


  # Return the crosswalk if requested
  if (return_key) {
    return(
      list(
        ped = ped,
        id_key = id_key
      )
    )
  }

  # Return the modified pedigree data frame
  ped
}

#' @rdname dot-renumberPedigreeIDs
renumberPedigreeIDs <- .renumberPedigreeIDs
