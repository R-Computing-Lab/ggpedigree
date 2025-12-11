#' Compute distance between two points
#'
#' This function calculates the distance between two points in a 2D space using
#' Minkowski distance. It can be used to compute Euclidean or Manhattan distance.
#' It is a utility function for calculating distances in pedigree layouts.
#' Defaults to Euclidean distance if no method is specified.
#'
#'
#' @param x1 Numeric. X-coordinate of the first point.
#' @param y1 Numeric. Y-coordinate of the first point.
#' @param x2 Numeric. X-coordinate of the second point.
#' @param y2 Numeric. Y-coordinate of the second point.
#' @param method Character. Method of distance calculation. Options are "euclidean", "cityblock", and "Minkowski".
#' @param p Numeric. The order of the Minkowski distance. If NULL, defaults to 2 for Euclidean and 1 for Manhattan. If
#' Minkowski method is used, p should be specified.

computeDistance <- function(method = "euclidean",
                            x1,
                            y1,
                            x2,
                            y2,
                            p = NULL) {
  method <- tolower(method)

  if (is.null(p)) {
    Min_p <- switch(method,
      euclidean = 2,
      cityblock = 1,
      manhattan = 1,
      stop(
        "Invalid distance method. Choose from 'euclidean', 'cityblock', or specify p."
      )
    )
  } else {
    Min_p <- p
  }
  # Calculate Minkowski distance

  ((abs(x1 - x2))^Min_p + (abs(y1 - y2))^Min_p)^(1 / Min_p)
}

#' Compute midpoints across grouped coordinates
#'
#' A flexible utility function to compute x and y midpoints for groups of individuals
#' using a specified method. Used to support positioning logic for sibling groups,
#' parental dyads, or spousal pairs in pedigree layouts.
#' @param data A `data.frame` containing the coordinate and grouping variables.
#' @param group_vars Character vector. Names of the grouping variables.
#' @param x_vars Character vector. Names of the x-coordinate variables to be averaged.
#' @param y_vars Character vector. Names of the y-coordinate variables to be averaged.
#' @param x_out Character. Name of the output column for the x-coordinate midpoint.
#' @param y_out Character. Name of the output column for the y-coordinate midpoint.
#' @param method Character. Method for calculating midpoints. Options include:
#'  \itemize{
#'  \item `"mean"`: Arithmetic mean of the coordinates.
#'  \item `"median"`: Median of the coordinates.
#'  \item `"weighted_mean"`: Weighted mean of the coordinates.
#'  \item `"first_pair"`: Mean of the first pair of coordinates.
#'  \item `"meanxfirst"`: Mean of the x-coordinates and first y-coordinate.
#'  \item `"meanyfirst"`: Mean of the y-coordinates and first x-coordinate.
#'  }
#' @param require_non_missing Character vector. Names of variables that must not be missing for the row to be included.

#' @return A `data.frame` grouped by `group_vars` with new columns `x_out` and `y_out` containing midpoint coordinates.
#' @keywords internal
#' @importFrom dplyr filter group_by summarize if_all
#' @importFrom stats weighted.mean  median

getMidpoints <- function(data,
                         group_vars,
                         x_vars,
                         y_vars,
                         x_out,
                         y_out,
                         method = "mean",
                         require_non_missing = group_vars) {
  # -----
  # Filter for complete data if requested
  # -----
  if (!is.null(require_non_missing)) {
    data <- data |>
      dplyr::filter(dplyr::if_all(
        !!!rlang::syms(require_non_missing),
        ~ !is.na(.)
      ))
  }

  # -----
  # Apply selected midpoint method
  # -----

  if (method == "mean") {
    # Average all xs and Average of all y values
    data |>
      dplyr::group_by(!!!rlang::syms(group_vars)) |>
      dplyr::summarize(!!x_out := mean(c(!!!rlang::syms(x_vars)), na.rm = TRUE),
        !!y_out := mean(c(!!!rlang::syms(y_vars)), na.rm = TRUE),
        .groups = "drop"
      )
  } else if (method == "median") {
    # Median of all xs and Median of all y values
    data |>
      dplyr::group_by(!!!rlang::syms(group_vars)) |>
      dplyr::summarize(
        !!x_out := stats::median(c(!!!rlang::syms(x_vars)), na.rm = TRUE),
        !!y_out := stats::median(c(!!!rlang::syms(y_vars)), na.rm = TRUE),
        .groups = "drop"
      )
  } else if (method == "weighted_mean") {
    # Weighted average (same weight for all unless specified externally)
    data |>
      dplyr::group_by(!!!rlang::syms(group_vars)) |>
      dplyr::summarize(
        !!x_out := stats::weighted.mean(c(!!!rlang::syms(x_vars)), na.rm = TRUE),
        !!y_out := stats::weighted.mean(c(!!!rlang::syms(y_vars)), na.rm = TRUE),
        .groups = "drop"
      )
    # } else if (method == "first_pair") {
    #   # Use only the first value in each pair of x/y coordinates
    #   # This is useful for spousal pairs or sibling groups
    #   data |> dplyr::filter(!is.na(.data[[group_vars]])) |>
    #     dplyr::group_by(!!!rlang::syms(group_vars)) |>
    #     dplyr::summarize(
    #       !!x_out := mean(
    #         c(
    #           dplyr::first(.data[[x_vars[1]]]),
    #          dplyr::first(.data[[x_vars[2]]])
    #         ),
    #         na.rm = TRUE
    #       ),
    #      !!y_out := mean(
    #         c(
    #          dplyr::first(.data[[y_vars[1]]]),
    #           dplyr::first(.data[[y_vars[2]]])
    #         ),
    #         na.rm = TRUE
    #       ),
    #       .groups = "drop"
    #     )
    # } else if (method == "meanxfirst") {
    #   # Use the mean of all x coordinates and the first y coordinate
    #   data |> dplyr::filter(!is.na(.data[[group_vars]])) |>
    #     dplyr::group_by(!!!rlang::syms(group_vars)) |>
    #     dplyr::summarize(!!x_out := mean(c(!!!rlang::syms(x_vars)), na.rm = TRUE), !!y_out := mean(c(
    #       dplyr::first(.data[[y_vars[1]]]), dplyr::first(.data[[y_vars[2]]])
    #     ), na.rm = TRUE),
    #     .groups = "drop"
    #     )
    # } else if (method == "meanyfirst") {
    #   # First x, mean of all y
    #   data |> dplyr::filter(!is.na(.data[[group_vars]])) |>
    #     dplyr::group_by(!!!rlang::syms(group_vars)) |>
    #     dplyr::summarize(
    #       !!x_out := mean(c(
    #         dplyr::first(.data[[x_vars[1]]]), dplyr::first(.data[[x_vars[2]]])
    #       ), na.rm = TRUE), !!y_out := mean(c(!!!rlang::syms(y_vars)), na.rm = TRUE),
    #       .groups = "drop"
    #     )
  } else {
    # Handle unsupported method argument
    stop("Unsupported method.")
  }
}


#' Get coordinate positions of relatives for each individual
#'
#' Helper function used to retrieve the x and y coordinates of a specified relative
#' (e.g., mom, dad, spouse) and join them into the main connection table. This supports
#' relative-specific positioning in downstream layout functions like `calculateConnections()`.
#'
#' @inheritParams ggPedigree
#' @param connections A `data.frame` containing the individuals and their associated relative IDs.
#' @param relativeIDvar Character. Name of the column in `connections` for the relative ID variable.
#' @param x_name Character. Name of the new column to store the x-coordinate of the relative.
#' @param y_name Character. Name of the new column to store the y-coordinate of the relative.
#' @param multiple Character. Specifies how to handle multiple matches. Options are "all" or "any".
#' @param only_unique Logical. If TRUE, return only unique rows. Defaults to TRUE.
#'
#' @return A `data.frame` with columns:
#'   \itemize{
#'     \item `personID`, `relativeIDvar`
#'     \item `x_name`, `y_name`: Coordinates of the specified relative
#'     \item Optionally, `newID` if present in `ped`
#'   }
#' @keywords internal
#' @importFrom dplyr filter left_join rename select
#' @importFrom stats setNames

getRelativeCoordinates <- function(ped,
                                   connections,
                                   relativeIDvar,
                                   x_name,
                                   y_name,
                                   #  relationship = "one-to-one",
                                   personID = "personID",
                                   multiple = "all",
                                   only_unique = TRUE) {
  # Filter only rows where the relative ID is not missing
  # and join with the main pedigree data frame
  tem_connections <- connections |>
    dplyr::filter(!is.na(.data[[relativeIDvar]]))
  if (only_unique == TRUE) {
    tem_connections <- unique(tem_connections)
  }
  rel_connections <- tem_connections |>
    # Join in the relative's coordinates from `ped`, based on relative ID
    dplyr::left_join(
      ped,
      by = stats::setNames(personID, relativeIDvar),
      suffix = c("", "_rel"),
      #    relationship = relationship,
      multiple = multiple
    ) |>
    unique() |>
    # Rename the joined coordinate columns to the specified x/y output names
    dplyr::rename(
      !!x_name := "x_pos_rel",
      !!y_name := "y_pos_rel"
    )
  # If the ped includes a 'newID' column (used to track duplicates), retain it in the result
  if ("newID" %in% names(ped)) {
    rel_connections <- rel_connections |>
      dplyr::select(
        !!personID, "newID",
        !!relativeIDvar,
        !!x_name,
        !!y_name
      )
  } else {
    rel_connections <- rel_connections |>
      dplyr::select(
        !!personID,
        !!relativeIDvar,
        !!x_name,
        !!y_name
      )
  }
  if (only_unique == TRUE) {
    rel_connections <- unique(rel_connections)
  }

  return(rel_connections)
}


#' Generate a symmetric key for two IDs
#'
#' This function generates a symmetric key for two IDs, ensuring that the order of the IDs does not matter.
#'
#' @param id1 First ID
#' @param id2 Second ID
#' @param sep Separator to use between the IDs
#'
#' @return A string representing the symmetric key
#' @keywords internal
#' @importFrom dplyr if_else
#' @aliases makeSymmetricKey
.makeSymmetricKey <- function(id1, id2, sep = ".") {
  if (missing(id1) || missing(id2)) {
    stop("Both id1 and id2 must be provided.")
  }
  # Require same type
  if (mode(id1) != mode(id2)) {
    # if they're both a number type, allow it
    if (mode(id1) %in% c("integer", "double") &&
      mode(id2) %in% c("integer", "double")) {
      # Numeric comparison
    } else {
      stop(paste0(
        "id1 and id2 must be of the same variable class. Please check if you have a mixture of strings and numerics in your ID variables. ",
        " id1 is ", mode(id1), " and id2 is ", mode(id2)
      ))
    }
  }
  if (is.character(id1) || is.character(id2)) {
    #  byte-wise comparison
    # Assign stable, reproducible numeric codes to each string
    levels_all <- sort(unique(c(id1, id2)))
    id1_num <- match(id1, levels_all)
    id2_num <- match(id2, levels_all)
  } else {
    # Numeric comparison
    id1_num <- as.numeric(id1)
    id2_num <- as.numeric(id2)
  }
  dplyr::if_else(id1_num < id2_num,
    paste0(id1, sep, id2),
    paste0(id2, sep, id1)
  )
}

#' @rdname dot-makeSymmetricKey
makeSymmetricKey <- .makeSymmetricKey
