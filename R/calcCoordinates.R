utils::globalVariables(c(":="))

#' Calculate coordinates for plotting individuals in a pedigree
#'
#' Extracts and modifies the x and y positions for each individual in a
#' pedigree data frame using the align.pedigree function from the `kinship2` package.
#' It returns a data.frame with positions for plotting.
#'
#' @param sexVar Character. Name of the column in `ped` for the sex variable.
#' @param spouseID Character. Name of the column in `ped` for the spouse ID variable.
#' @param code_male Value used to indicate male sex. Defaults to NULL.
#' @param config List of configuration options:
#'   \describe{
#'     \item{code_male}{Default is 1. Used by BGmisc::recodeSex().}
#'     \item{ped_packed}{Logical, default TRUE. Passed to `kinship2::align.pedigree`.}
#'     \item{ped_align}{Logical, default TRUE. Align generations.}
#'     \item{ped_width}{Numeric, default 15. Controls spacing.}
#'   }
#' @inheritParams ggpedigree
#'
#' @return A data frame with one or more rows per person, each containing:
#'   \itemize{
#'     \item `x_order`, `y_order`: Grid indices representing layout rows and columns.
#'     \item `x_pos`, `y_pos`: Continuous coordinate positions used for plotting.
#'     \item `nid`: Internal numeric identifier for layout mapping.
#'     \item `extra`: Logical flag indicating whether this row is a secondary appearance.
#'   }
#' @export
calculateCoordinates <- function(ped, personID = "ID", momID = "momID",
                                 dadID = "dadID",
                                 spouseID = "spouseID", sexVar = "sex",
                                 code_male = NULL,
                                 config = list()) {
  if (!inherits(ped, "data.frame")) {
    stop("ped should be a data.frame or inherit to a data.frame")
  }

  if (!all(c(personID, momID, dadID) %in% names(ped))) {
    stop("At least one of the required ID variables (personID, momID, dadID) was not found in `ped`")
  }

  # -----
  # Set up
  # -----

  # Fill missing configuration values with defaults
  default_config <- list(
    code_male = 1,
    ped_packed = TRUE,
    ped_align = TRUE,
    ped_width = 15
  )
  config <- utils::modifyList(default_config, config)

  # Recode sex values in case non-standard codes are used (e.g., "M"/"F")
  ped_recode <- BGmisc::recodeSex(ped,
    code_male = code_male
  )

  # Construct a pedigree object to compute layout coordinates
  ped_ped <- kinship2::pedigree(
    id = ped[[personID]],
    dadid = ped[[dadID]],
    momid = ped[[momID]],
    sex = ped_recode[[sexVar]],
  )

  # -----
  # Extract layout information
  # -----


  # Align pedigree for plotting
  pos <- kinship2::align.pedigree(ped_ped,
    packed = config$ped_packed,
    align = config$ped_align,
    width = config$ped_width
  )

  # Extract layout information
  nid_vector <- as.vector(pos$nid)
  nid_vector <- nid_vector[nid_vector != 0] # Remove zero entries (empty cells)


  # Flatten coordinate matrix
 # pos_vector <- as.vector(pos$pos)
#  spouse_vector <- as.vector(pos$spouse)


  # Initialize coordinate columns in the data frame
  ped$nid <- NA
  ped$x_pos <- NA
  ped$x_order <- NA
  ped$y_order <- NA


  # Determine matrix indices for all non-zero entries
  nid_pos <- which(pos$nid != 0, arr.ind = TRUE)

  # Allocate coordinate vectors
  x_coords <- rep(NA, length(nid_vector))
  y_coords <- rep(NA, length(nid_vector))
  x_pos <- rep(NA, length(nid_vector))

  # Initialize spouse vector
  spouse_vector <- rep(NA, length(nid_vector))

  #' A matrix with values
  #' 1 = subject plotted to the immediate right is a spouse
  #' 2 = subject plotted to the immediate right is an inbred spouse
  #' 0 = not a spouse


  # Populate coordinates from nid positions
  for (i in seq_along(nid_vector)) {
    y_coords[i] <- nid_pos[i, "row"]
    x_coords[i] <- nid_pos[i, "col"]
    x_pos[i] <- pos$pos[nid_pos[i, "row"], nid_pos[i, "col"]]
    spouse_vector[i] <- pos$spouse[nid_pos[i, "row"], nid_pos[i, "col"]]

  }

  # -----
  # Fill in the data frame with coordinates
  # -----


  # Match each individual to their primary layout position
  tmp <- match(1:length(ped_ped$id), nid_vector)

  # Fill the nid, pos, x, and y columns in ped_ped based on the mapping
  ped$nid <- nid_vector[tmp]
  ped$x_order <- x_coords[tmp]
  ped$y_order <- y_coords[tmp]
  ped$x_pos <- x_pos[tmp]
  ped$y_pos <- y_coords[tmp]
  ped$spousehint <- spouse_vector[tmp]


  # Detect multiple layout positions for the same individual
  # This can happen if the same individual appears multiple times in the pedigree
  # For each nid, count how many times it appears
  appearance_counts <- table(nid_vector)

  duplicate_nids <- names(appearance_counts[appearance_counts > 1]) |>
    as.integer()

  # Initialize list to collect extra rows
  extra_rows <- list()

  # Create duplicate rows for extra appearances

  # For each duplicate nid
  for (nid_val in duplicate_nids) {
    # All appearance positions
    appearance_indices <- which(nid_vector == nid_val)

    # Find which index was already used in tmp
    # tmp is a mapping from person index to nid_vector position
    used_index <- tmp[which(1:length(ped_ped$id) == nid_val)]

    # Extra indices are the appearances NOT used by match()
    extra_indices <- setdiff(appearance_indices, used_index)

    for (idx in extra_indices) {
      new_row <- ped[ped[[personID]] == ped_ped$id[nid_val], , drop = FALSE]

      new_row$nid <- nid_val
      new_row$x_order <- x_coords[idx]
      new_row$y_order <- y_coords[idx]
      new_row$x_pos <- x_pos[idx]
      new_row$y_pos <- y_coords[idx]

      extra_rows[[length(extra_rows) + 1]] <- new_row
    }
  }


  # Combine original and extra rows, marking extras
  if (length(extra_rows) > 0) {
    ped_extra <- do.call(rbind, extra_rows)
    ped$extra <- FALSE
    ped_extra$extra <- TRUE
    ped <- rbind(ped, ped_extra)
  } else {
    ped_extra <- NULL
  }

  return(ped)
}

#' Calculate connections for a pedigree dataset
#'
#' Computes graphical connection paths for a pedigree layout, including parent-child,
#' sibling, and spousal connections. Optionally processes duplicate appearances
#' of individuals (marked as `extra`) to ensure relational accuracy.
#'
#' @inheritParams ggpedigree
#' @param config List of configuration parameters. Currently unused but passed through to internal helpers.
#' @return A `data.frame` containing connection points and midpoints for graphical rendering. Includes:
#'   \itemize{
#'     \item `x_pos`, `y_pos`: positions of focal individual
#'     \item `x_dad`, `y_dad`, `x_mom`, `y_mom`: parental positions (if available)
#'     \item `x_spouse`, `y_spouse`: spousal positions (if available)
#'     \item `x_midparent`, `y_midparent`: midpoint between parents
#'     \item `x_mid_sib`, `y_mid_sib`: sibling group midpoint
#'     \item `x_mid_spouse`, `y_mid_spouse`: midpoint between spouses
#'   }
#'
#' @export

calculateConnections <- function(ped,
                                 config = list()) {
  # Check inputs -----------------------------------------------------------
  if (!inherits(ped, "data.frame")) {
    stop("ped should be a data.frame or inherit to a data.frame")
  }
  if (!all(c("personID", "x_pos", "y_pos", "dadID", "momID") %in% names(ped))) {
    stop("ped must contain personID, x_pos, y_pos, dadID, and momID columns")
  }

  # Default configuration placeholder
  default_config <- list()
  config <- utils::modifyList(default_config, config)


  # Add spouseID if missing
  if (!all("spouseID" %in% names(ped))) {
    ped$spouseID <- NA
    # Attempt to infer spouse based on parenthood (not always reliable)
    # this will give you the mom that is the spouse of the dad
    # ped$spouseID <- ped$momID[match(ped$personID, ped$dadID)]
    # this will give you the dad that is the spouse of the mom
    # ped$spouseID <- ped$dadID[match(ped$personID, ped$momID)]

    ped$spouseID <- ifelse(!is.na(ped$momID[match(ped$personID, ped$dadID)]),
      ped$momID[match(ped$personID, ped$dadID)],
      ped$dadID[match(ped$personID, ped$momID)]
    )
  }
  # Add famID if missing (used for grouping)
  if (!all("famID" %in% names(ped))) {
    ped$famID <- 1
  }

  # If duplicated appearances exist, resolve which connections to keep
  if ("extra" %in% names(ped)) {
    ped <- processExtras(ped, config = config)
  }

  # Construct base connection frame
  # This will be used for all joins


  if ("x_otherself" %in% names(ped)) {
    connections <-  dplyr::select(
        .data = ped,
        "personID",
        "x_pos", "y_pos",
        "dadID", "momID",
        "spouseID",
        "famID",
        "x_otherself", "y_otherself",
        "extra","link_as_mom", "link_as_dad", "link_as_spouse"
      )


    connections_moms <- dplyr::filter(connections, .data$extra==FALSE  | .data$link_as_mom == TRUE) %>%
      dplyr::select(
        -"extra",
        -"link_as_mom",
        -"link_as_dad",
        -"link_as_spouse"
      )

    connections_dads <- dplyr::filter(connections, .data$extra==FALSE | .data$link_as_dad == TRUE) %>%
      dplyr::select(
        -"extra",
        -"link_as_mom",
        -"link_as_dad",
        -"link_as_spouse"
      )
    connections_spouses <- dplyr::filter(connections, .data$extra==FALSE |  .data$link_as_spouse == TRUE) %>%
      dplyr::select(
        -"extra",
        -"link_as_mom",
        -"link_as_dad",
        -"link_as_spouse"
      )

  }  else {
    connections <- dplyr::select(
      .data = ped,
      "personID",
      "x_pos", "y_pos",
      "dadID", "momID",
      "spouseID",
      "famID"

    )
# no duplications, so just use the same connections
    connections_spouses <- connections_dads <- connections_moms <- connections
  }






  # Get mom's coordinates
  mom_connections <- getRelativeCoordinates(
    ped = ped,
    connections = connections_moms,
    relativeIDvar = "momID",
    x_name = "x_mom",
    y_name = "y_mom"
  )

  # Get dad's coordinates
  dad_connections <- getRelativeCoordinates(
    ped = ped,
    connections = connections_dads,
    relativeIDvar = "dadID",
    x_name = "x_dad",
    y_name = "y_dad"
  )

  # Get spouse coordinates
  spouse_connections <- ped |>
    dplyr::select(
      "personID", "x_pos",
      "y_pos", "spouseID"
    ) |>
    dplyr::left_join(connections_spouses,
      by = c("spouseID" = "personID"),
      suffix = c("", "_spouse"),
      multiple = "any"
    ) |>
    dplyr::rename(
      x_spouse = "x_pos_spouse",
      y_spouse = "y_pos_spouse"
    ) |>
    dplyr::select(
      "personID", "spouseID",
      "x_spouse", "y_spouse"
    )

  # Combine mom, dad, and spouse coordinates
  connections <- connections |>
    dplyr::left_join(mom_connections,
      by = c("personID", "momID")
    ) |>
    dplyr::left_join(dad_connections,
      by = c("personID", "dadID")
    ) |>
    dplyr::left_join(spouse_connections,
      by = c("personID", "spouseID")
    )

  # Calculate midpoints between mom and dad
  parent_midpoints <- connections |>
    dplyr::filter(!is.na(.data$dadID) & !is.na(.data$momID)) |>
    dplyr::group_by(.data$dadID, .data$momID) |>
    dplyr::summarize(
      x_midparent = mean(c(
        dplyr::first(.data$x_dad),
        dplyr::first(.data$x_mom)
      )),
      y_midparent = mean(c(
        dplyr::first(.data$y_dad),
        dplyr::first(.data$y_mom)
      )),
      .groups = "drop"
    )

  # Calculate midpoints between spouses
  spouse_midpoints <- connections |>
    dplyr::filter(!is.na(.data$spouseID)) |>
    dplyr::group_by(.data$spouseID) |>
    dplyr::summarize(
      x_mid_spouse = mean(c(
        dplyr::first(.data$x_pos),
        dplyr::first(.data$x_spouse)
      )),
      y_mid_spouse = mean(c(
        dplyr::first(.data$y_pos),
        dplyr::first(.data$y_spouse)
      )),
      .groups = "drop"
    )

  # Calculate sibling group midpoints
  sibling_midpoints <- connections |>
    dplyr::filter(!is.na(.data$dadID) & !is.na(.data$momID)) |>
    dplyr::group_by(
      .data$dadID,
      .data$momID
    ) |>
    dplyr::summarize(
      x_mid_sib = mean(.data$x_pos),
      y_mid_sib = dplyr::first(.data$y_pos),
      .groups = "drop"
    )


  # Merge midpoints into connections
  connections <- connections |>
    dplyr::left_join(parent_midpoints,
      by = c("dadID", "momID")
    ) |>
    dplyr::left_join(spouse_midpoints,
      by = c("spouseID")
    ) |>
    dplyr::left_join(sibling_midpoints,
      by = c("dadID", "momID")
    ) |>
    dplyr::mutate(
      x_mid_sib = dplyr::case_when(
        is.na(.data$x_mid_sib) & !is.na(.data$dadID) & !is.na(.data$momID) ~ .data$x_pos,
        !is.na(.data$x_mid_sib) ~ .data$x_mid_sib,
        TRUE ~ NA_real_
      ),
      y_mid_sib = dplyr::case_when(
        is.na(.data$y_mid_sib) & !is.na(.data$dadID) & !is.na(.data$momID) ~ .data$y_pos,
        !is.na(.data$y_mid_sib) ~ .data$y_mid_sib,
        TRUE ~ NA_real_
      )
    )

  return(connections)
}
#' Get coordinate positions of relatives for each individual
#'
#' Helper function used to retrieve the x and y coordinates of a specified relative
#' (e.g., mom, dad, spouse) and join them into the main connection table. This supports
#' relative-specific positioning in downstream layout functions like `calculateConnections()`.
#'
#' @inheritParams ggpedigree
#' @param connections A `data.frame` containing the individuals and their associated relative IDs.
#' @param relativeIDvar Character. Name of the column in `connections` for the relative ID variable.
#' @param x_name Character. Name of the new column to store the x-coordinate of the relative.
#' @param y_name Character. Name of the new column to store the y-coordinate of the relative.
#' @param multiple Character. Specifies how to handle multiple matches. Options are "all" or "any".
#'
#' @return A `data.frame` with columns:
#'   \itemize{
#'     \item `personID`, `relativeIDvar`
#'     \item `x_name`, `y_name`: Coordinates of the specified relative
#'     \item Optionally, `newID` if present in `ped`
#'   }
#' @keywords internal


getRelativeCoordinates <- function(ped, connections, relativeIDvar, x_name, y_name,
                                   #  relationship = "one-to-one",
                                   personID = "personID",
                                   multiple = "all") {
  # Filter only rows where the relative ID is not missing
  # and join with the main pedigree data frame
  rel_connections <- connections |>
    dplyr::filter(!is.na(.data[[relativeIDvar]])) |>
    # Join in the relative's coordinates from `ped`, based on relative ID
    dplyr::left_join(
      ped,
      by = stats::setNames(personID, relativeIDvar),
      suffix = c("", "_rel"),
      #    relationship = relationship,
      multiple = multiple
    ) |>
    # Rename the joined coordinate columns to the specified x/y output names
    dplyr::rename(
      !!x_name := "x_pos_rel",
      !!y_name := "y_pos_rel"
    )
  # If the ped includes a 'newID' column (used to track duplicates), retain it in the result
  if ("newID" %in% names(ped)) {
    rel_connections <- rel_connections |>
      dplyr::select(
        !!personID,
        "newID",
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

  return(rel_connections)
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

#' Process duplicate appearances of individuals in a pedigree layout
#'
#' Resolves layout conflicts when the same individual appears in multiple places
#' (e.g., due to inbreeding loops). Keeps the layout point that is closest to a relevant
#' relative (mom, dad, or spouse) and removes links to others to avoid confusion in visualization.
#'
#' @param ped A data.frame containing pedigree layout info with columns including:
#'   `personID`, `x_pos`, `y_pos`, `dadID`, `momID`, and a logical column `extra`.
#' @param config A list of configuration options. Currently unused but passed through to internal helpers.
#'
#' @return A modified `ped` data.frame with updated coordinates and removed duplicates.
#'
#' @keywords internal

processExtras <- function(ped, config = list()) {
  # -----
  # Check inputs
  # -----
  if (!inherits(ped, "data.frame")) {
    stop("ped should be a data.frame or inherit to a data.frame")
  }
  if (!all(c("personID", "x_pos", "y_pos", "dadID", "momID") %in% names(ped))) {
    stop("ped must contain personID, x_pos, y_pos, dadID, and momID columns")
  }

  # default config
  default_config <- list()
  config <- utils::modifyList(default_config, config)

  # -----
  # Identify duplicated individuals
  # -----

  # Find all individuals with extra appearances
  idsextras <- dplyr::filter(ped, .data$extra == TRUE) |>
    dplyr::select("personID") |>
    dplyr::pull() |>
    unique()


  # Assign unique ID per row for later use
  ped$newID <- 1:nrow(ped)


  # -----
  # Subset to duplicated entries only # note that tidyselect hates .data pronouns
  # -----
  extras <- dplyr::filter(ped, .data$personID %in% idsextras) |>
    dplyr::select(
      "newID",
      "personID",
      "x_pos", "y_pos",
      "dadID", "momID",
      "spouseID"
    )

  # -----
  # Get coordinate positions of relatives and other-self
  # -----

  # Mother's coordinates
  mom_coords <- getRelativeCoordinates(
    ped = ped,
    connections = extras,
    relativeIDvar = "momID",
    x_name = "x_mom",
    y_name = "y_mom",
    multiple = "any"
  )

  # Father's coordinates

  dad_coords <- getRelativeCoordinates(
    ped = ped,
    connections = extras,
    relativeIDvar = "dadID",
    x_name = "x_dad",
    y_name = "y_dad",
    multiple = "any"
  )

  # Spouse's coordinates
  spouse_coords <- getRelativeCoordinates(
    ped = ped,
    connections = extras,
    relativeIDvar = "spouseID",
    x_name = "x_spouse",
    y_name = "y_spouse",
    multiple = "all"
  )

  # Coordinates of the individual's other appearance ("self")
  self_coords <- extras |>
    dplyr::left_join(
      ped,
      by = c("personID"),
      suffix = c("", "_other"),
      #    relationship = relationship,
      multiple = "all"
    ) |>
    dplyr::filter(.data$newID != .data$newID_other) |>
    dplyr::mutate(
      x_otherself = .data$x_pos_other,
      y_otherself = .data$y_pos_other
    ) |>
    dplyr::select(
      .data$newID,
      .data$personID,
      .data$newID_other,
      .data$x_otherself,
      .data$y_otherself
    )

  # -----
  # Merge coordinates into the extra rows
  # -----

  extras <- extras |>
    dplyr::left_join(mom_coords, by = c("newID", "personID", "momID")) |>
    dplyr::left_join(dad_coords, by = c("newID", "personID", "dadID")) |>
    dplyr::left_join(self_coords, by = c("newID", "personID")) |>
    dplyr::left_join(spouse_coords,
      by = c("newID", "personID", "spouseID"),
      multiple = "all"
    )


  # -----
  # Compute Euclidean distances between this appearance and:
  #   - mom, dad, spouse
  #   - same individual in other location (otherself)
  # These will be used to choose the "closest" relationship.
  # -----
  extras <- extras |>
    dplyr::mutate(
      dist_mom = sqrt((.data$x_pos - .data$x_mom)^2 + (.data$y_pos - .data$y_mom)^2),
      dist_mom_other = sqrt((.data$x_otherself - .data$x_mom)^2 + (.data$y_otherself - .data$y_mom)^2),
      dist_dad = sqrt((.data$x_pos - .data$x_dad)^2 + (.data$y_pos - .data$y_dad)^2),
      dist_dad_other = sqrt((.data$x_otherself - .data$x_dad)^2 + (.data$y_otherself - .data$y_dad)^2),
      dist_spouse = sqrt((.data$x_pos - .data$x_spouse)^2 + (.data$y_pos - .data$y_spouse)^2),
      dist_spouse_other = sqrt((.data$x_otherself - .data$x_spouse)^2 + (.data$y_otherself - .data$y_spouse)^2),
      dist_otherself = sqrt((.data$x_pos - .data$x_otherself)^2 + (.data$y_pos - .data$y_otherself)^2)
    )

  # -----
  # When there are multiple spouses, keep only the appearance
  # where the individual is closest to one of their spouses.
  # -----

  extras <- extras |>
    dplyr::group_by(.data$newID, .data$personID) |>
    dplyr::mutate(
      min_spouse = min(.data$dist_spouse, na.rm = TRUE),
      num_spouse = dplyr::n()
    ) |>
    dplyr::ungroup()
  extras <- extras |>
    dplyr::filter(.data$num_spouse == 1 | .data$dist_spouse == .data$min_spouse) |>
    dplyr::select(
      -.data$min_spouse,
      -.data$num_spouse
    )


  # -----
  # Determine the "closest relative" to this duplicated row
  # -----



  # For each duplicated appearance, we now ask:
  #   - Is this appearance closer to mom than the otherself copy is?
  #   - Same for dad? For spouse?

  extras <- extras |>
    dplyr::mutate(
      mom_closer = dplyr::case_when(
        .data$dist_mom < .data$dist_mom_other ~ TRUE,
        .data$dist_mom_other < .data$dist_mom ~ FALSE,
        TRUE ~ TRUE
      ),
      dad_closer = dplyr::case_when(
        .data$dist_dad < .data$dist_dad_other ~ TRUE,
        .data$dist_dad_other < .data$dist_dad ~ FALSE,
        TRUE ~ TRUE
      ),
      spouse_closer = dplyr::case_when(
        .data$dist_spouse < .data$dist_spouse_other ~ TRUE,
        .data$dist_spouse_other < .data$dist_spouse ~ FALSE,
     #   is.na(.data$dist_spouse)  ~ FALSE,
      #  !is.na(.data$dist_spouse) & is.na(.data$dist_spouse_other) ~ TRUE,
        TRUE ~ TRUE
      )
    )


  # Then:
  #   - Determine which of mom, dad, or spouse is closest in absolute terms
  #   - Use that to decide whether to retain connections to that relative

  extras <- extras |>
    dplyr::mutate(
      closest_relative = dplyr::case_when(
        .data$dist_mom <= .data$dist_dad & .data$dist_mom <= .data$dist_spouse ~ "mom",
        .data$dist_dad < .data$dist_mom & .data$dist_dad <= .data$dist_spouse ~ "dad",
        TRUE ~ "spouse"
      )
    )

  # -----
  # Based on which relative is closest, determine which links to keep
  # -----

  extras <- extras |>
    dplyr::mutate(
      link_as_mom = .data$closest_relative %in% c("mom", "dad") & .data$mom_closer,
      link_as_dad = .data$closest_relative %in% c("mom", "dad") & .data$dad_closer,
      link_as_spouse = .data$closest_relative == "spouse" & .data$spouse_closer
      )


  # -----
  # Final subset of relevant decision columns
  # -----

  skinnyextras <- extras |>
    dplyr::select(
      .data$newID,
      .data$link_as_dad,
      .data$link_as_mom,
      .data$link_as_spouse,
      .data$x_otherself,
      .data$y_otherself
    )


  # -----
  # Apply decisions to main pedigree
  # Removes connection references for non-kept parents/spouses
  # -----

  ped <- ped |>
    dplyr::left_join(skinnyextras,
      by = c("newID"), suffix = c("", "_")#,
     # relationship = "one-to-one"
    )  |>
    dplyr::select(
      -"newID"
    ) |>
    # set the connection columns to TRUE if not kept
    dplyr::mutate(
      link_as_mom = case_when(
        is.na(.data$link_as_mom) ~ TRUE,
        .data$link_as_mom == TRUE ~ TRUE,
        .data$link_as_mom == FALSE ~ FALSE
      ),
      link_as_dad = case_when(
        is.na(.data$link_as_dad) ~ TRUE,
        .data$link_as_dad == TRUE ~ TRUE,
        .data$link_as_dad == FALSE ~ FALSE
      ),
      link_as_spouse = case_when(
        is.na(.data$link_as_spouse) ~ TRUE,
        .data$link_as_spouse == TRUE ~ TRUE,
        .data$link_as_spouse == FALSE ~ FALSE
      )
    )
  return(ped)
}
