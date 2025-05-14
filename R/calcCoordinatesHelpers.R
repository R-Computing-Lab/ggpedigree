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

computeDistance <- function(x1, y1, x2, y2,
                            method = "euclidean", p = NULL) {

  method <- tolower(method)

  if(is.null(p)) {
    p <- switch(method,
                euclidean = 2,
                cityblock = 1,
                stop("Invalid distance method. Choose from 'euclidean', 'cityblock', or specify p.")
    )
  }
  # Calculate Minkowski distance

  ((abs(x1 - x2))^p + (abs(y1 - y2))^p)^(1 / p)

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

getMidpoints <- function(data, group_vars,
                         x_vars, y_vars,
                         x_out, y_out, method = "mean",
                         require_non_missing = group_vars) {
  # -----
  # Filter for complete data if requested
  if (!is.null(require_non_missing)) {
    data <- data |>
      dplyr::filter(
        dplyr::if_all(!!!rlang::syms(require_non_missing), ~ !is.na(.))
      )
  }

  # -----
  # Apply selected midpoint method
  # -----

  if (method == "mean") {
    # Average all xs and Average of all y values

    data |>
      dplyr::group_by(!!!rlang::syms(group_vars)) |>
      dplyr::summarize(
        !!x_out := mean(c(!!!rlang::syms(x_vars)), na.rm = TRUE),
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
  } else if (method == "first_pair") {
    # Use only the first value in each pair of x/y coordinates
    # This is useful for spousal pairs or sibling groups
    data |>
      dplyr::group_by(!!!rlang::syms(group_vars)) |>
      dplyr::summarize(
        !!x_out := mean(c(
          dplyr::first(.data[[x_vars[1]]]),
          dplyr::first(.data[[x_vars[2]]])
        ), na.rm = TRUE),
        !!y_out := mean(c(
          dplyr::first(.data[[y_vars[1]]]),
          dplyr::first(.data[[y_vars[2]]])
        ), na.rm = TRUE),
        .groups = "drop"
      )
  } else if (method == "meanxfirst") {
    # Use the mean of all x coordinates and the first y coordinate
    data |>
      dplyr::group_by(!!!rlang::syms(group_vars)) |>
      dplyr::summarize(
        !!x_out := mean(c(!!!rlang::syms(x_vars)), na.rm = TRUE),
        !!y_out := mean(c(
          dplyr::first(.data[[y_vars[1]]]),
          dplyr::first(.data[[y_vars[2]]])
        ), na.rm = TRUE),
        .groups = "drop"
      )
  } else if (method == "meanyfirst") {
    # First x, mean of all y
    data |>
      dplyr::group_by(!!!rlang::syms(group_vars)) |>
      dplyr::summarize(
        !!x_out := mean(c(
          dplyr::first(.data[[x_vars[1]]]),
          dplyr::first(.data[[x_vars[2]]])
        ), na.rm = TRUE),
        !!y_out := mean(c(!!!rlang::syms(y_vars)), na.rm = TRUE),
        .groups = "drop"
      )
  } else {
    # Handle unsupported method argument
    stop("Unsupported method.")
  }
}
