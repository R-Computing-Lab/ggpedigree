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
#'     \item{ped_packed}{Logical, default TRUE. Passed to `kinship2_align.pedigree`.}
#'     \item{ped_align}{Logical, default TRUE. Align generations.}
#'     \item{ped_width}{Numeric, default 15. Controls spacing.}
#'   }
#' @inheritParams ggPedigree
#'
#' @return A data frame with one or more rows per person, each containing:
#'   \itemize{
#'     \item `x_order`, `y_order`: Grid indices representing layout rows and columns.
#'     \item `x_pos`, `y_pos`: Continuous coordinate positions used for plotting.
#'     \item `nid`: Internal numeric identifier for layout mapping.
#'     \item `extra`: Logical flag indicating whether this row is a secondary appearance.
#'   }
#'
#' @export
#' @examples
#' # Load example data
#' data(potter, package = "BGmisc")
#'
#' # Calculate coordinates for the pedigree
#' coords <- calculateCoordinates(
#'   ped = potter,
#'   personID = "personID",
#'   momID = "momID",
#'   dadID = "dadID",
#'   code_male = 1
#' )
#'
#' # View the coordinates
#' head(coords)
#'
#' # Example with custom configuration
#' coords_custom <- calculateCoordinates(
#'   ped = potter,
#'   personID = "personID",
#'   momID = "momID",
#'   dadID = "dadID",
#'   code_male = 1,
#'   config = list(
#'     ped_packed = FALSE,
#'     ped_width = 20
#'   )
#' )
#' @examples
#' # Load example data
#' data(potter, package = "BGmisc")
#'
#' # Calculate coordinates for the pedigree
#' coords <- calculateCoordinates(
#'   ped = potter,
#'   personID = "personID",
#'   momID = "momID",
#'   dadID = "dadID",
#'   config = list(
#'     code_male = 1
#'   )
#' )
#'
#' # View the coordinates
#' head(coords)
#'
#' # Example with custom configuration
#' coords_custom <- calculateCoordinates(
#'   ped = potter,
#'   personID = "personID",
#'   momID = "momID",
#'   dadID = "dadID",
#'   config = list(
#'     ped_packed = FALSE,
#'     ped_width = 20
#'   )
#' )
calculateCoordinates <- function(ped,
                                 personID = "personID",
                                 momID = "momID",
                                 dadID = "dadID",
                                 spouseID = "spouseID",
                                 sexVar = "sex",
                                 twinID = "twinID",
                                 code_male = NULL,
                                 config = list()) {
  if (!inherits(ped, "data.frame")) {
    stop("ped should be a data.frame or inherit to a data.frame")
  }

  if (!all(c(personID, momID, dadID) %in% names(ped))) {
    stop(
      "At least one of the required ID variables (personID, momID, dadID) was not found in `ped`"
    )
  }

  # -----
  # Set up
  # -----
  if (!is.null(code_male)) {
    config$code_male <- code_male
  }

  # Fill missing configuration values with defaults
  default_config <- list(
    code_male = 1,
    code_female = 0,
    ped_packed = TRUE,
    ped_align = TRUE,
    ped_width = 15,
    return_mid_parent = FALSE,
    fast_threshold = 1000
  )
  config <- utils::modifyList(default_config, config)

  extractCoordinatesFromAlignedPedigree <- function(ped_component,
                                                    ped_ped,
                                                    pos,
                                                    personID,
                                                    momID,
                                                    dadID,
                                                    config = NULL) {
    # Extract layout information
    nid_vector <- as.vector(pos$nid)
    nid_vector <- nid_vector[nid_vector != 0] # Remove zero entries (empty cells)

    # Initialize coordinate columns in the data frame
    ped_component$nid <- NA
    ped_component$x_pos <- NA
    ped_component$x_order <- NA
    ped_component$y_order <- NA

    # Determine matrix indices for all non-zero entries
    nid_pos <- which(pos$nid != 0, arr.ind = TRUE)

    # Allocate coordinate vectors
    n_coords <- length(nid_vector)
    base_vector <- rep(NA_real_, n_coords)

    x_pos <- base_vector
    y_coords <- base_vector
    x_coords <- base_vector
    spouse_vector <- base_vector
    parent_fam <- base_vector
    parent_right_vector <- base_vector
    parent_left_vector <- base_vector
    y_fam <- base_vector

    # A matrix with values
    # 1 = subject plotted to the immediate right is a spouse
    # 2 = subject plotted to the immediate right is an inbred spouse
    # 0 = not a spouse

    # Populate coordinates from nid positions
    y_coords <- nid_pos[, "row"]
    x_coords <- nid_pos[, "col"]
    x_pos <- pos$pos[cbind(y_coords, x_coords)]

    # Spouse information
    spouse_vector <- pos$spouse[cbind(y_coords, x_coords)]

    # Parent information
    parent_fam <- pos$fam[cbind(y_coords, x_coords)]
    y_fam <- y_coords - 1

    parent_row <- y_coords - 1
    parent_col_left <- parent_fam
    parent_col_right <- parent_fam + 1

    # Ensure parent columns are within bounds
    valid_parent <- parent_row >= 1 &
      parent_col_left >= 1 &
      parent_col_right <= ncol(pos$pos)

    parent_left_vector[valid_parent] <- pos$pos[cbind(
      parent_row[valid_parent],
      parent_col_left[valid_parent]
    )]

    parent_right_vector[valid_parent] <- pos$pos[cbind(
      parent_row[valid_parent],
      parent_col_right[valid_parent]
    )]

    # -----
    # Fill in the data frame with coordinates
    # -----
    # Match each individual to their primary layout position
    tmp <- match(seq_along(ped_ped$id), nid_vector)

    # Fill the nid, pos, x, and y columns in ped_ped based on the mapping
    ped_component$nid <- nid_vector[tmp]
    ped_component$x_order <- x_coords[tmp]
    ped_component$y_order <- y_coords[tmp]
    ped_component$x_pos <- x_pos[tmp]
    ped_component$y_pos <- y_coords[tmp]
    ped_component$parent_fam <- parent_fam[tmp]
    ped_component$spousehint <- spouse_vector[tmp]
    ped_component$parent_left <- parent_left_vector[tmp]
    ped_component$parent_right <- parent_right_vector[tmp]
    ped_component$y_fam <- y_fam[tmp]

    # Detect multiple layout positions for the same individual
    # This can happen if the same individual appears multiple times in the pedigree

    # For each nid, count how many times it appears
    appearance_counts <- table(nid_vector)

    duplicate_nids <- names(appearance_counts[appearance_counts > 1]) |>
      as.integer()

    # Prepare flat list of (nid_val, idx) for all extra appearances
    extra_info <- list()

    # Create duplicate rows for extra appearances

    # All appearance positions
    appearance_indices <- which(nid_vector %in% duplicate_nids)

    # Find which index was already used in tmp
    # tmp is a mapping from person index to nid_vector position
    used_indices <- tmp[duplicate_nids]

    # Extra indices are the appearances NOT used by match()
    extra_indices <- setdiff(appearance_indices, used_indices)

    # If there are extra indices, we need to create additional rows
    if (length(extra_indices) > 0) {
      extra_df <- data.frame(
        nid = nid_vector[extra_indices],
        idx = extra_indices
      )

      # directly matching each nid to ped_ped$id and then to ped
      matched_personID <- ped_ped$id[extra_df$nid]
      ped_rows_idx <- match(matched_personID, ped_component[[personID]])

      extra_rows <- ped_component[ped_rows_idx, , drop = FALSE]

      # Assign coordinates explicitly
      extra_rows$nid <- extra_df$nid
      extra_rows$x_order <- x_coords[extra_df$idx]
      extra_rows$y_order <- y_coords[extra_df$idx]
      extra_rows$x_pos <- x_pos[extra_df$idx]
      extra_rows$y_pos <- y_coords[extra_df$idx]
      extra_rows$spousehint <- spouse_vector[extra_df$idx]
      extra_rows$parent_fam <- parent_fam[extra_df$idx]
      extra_rows$parent_left <- parent_left_vector[extra_df$idx]
      extra_rows$parent_right <- parent_right_vector[extra_df$idx]
      extra_rows$y_fam <- y_fam[extra_df$idx]

      ped_component$extra <- FALSE
      extra_rows$extra <- TRUE

      ped_component <- rbind(ped_component, extra_rows)
    } else {
      ped_component$extra <- FALSE
    }

    ## assumes that there are two parents
    ped_component$x_fam <- base::rowMeans(cbind(
      ped_component$parent_left,
      ped_component$parent_right
    ), na.rm = FALSE)

    # Unplaced individuals (nid = NA, parent_fam = NA) can produce NaN from
    # kinship2's position matrix; also clear the parent_fam == 0 entries.
    no_parents <- is.na(ped_component$parent_fam) | ped_component$parent_fam == 0
    ped_component$x_fam[no_parents] <- NA
    ped_component[[momID]][no_parents] <- NA
    ped_component[[dadID]][no_parents] <- NA
    ped_component$y_fam[no_parents] <- NA
    ped_component$parent_left <- NULL
    ped_component$parent_right <- NULL

    return(ped_component)
  }

  alignAndExtractComponent <- function(ped_component, config) {
    # use relations if provided, otherwise use default settings
    ped_ped <- alignPedigreeWithRelations(
      ped = ped_component,
      personID = personID,
      dadID = dadID,
      momID = momID,
      code_male = config$code_male,
      sexVar = sexVar,
      config = config
    )

    # use hints if provided
    pos <- alignPedigreeWithHints(
      ped_ped = ped_ped,
      config = config
    )

    extractCoordinatesFromAlignedPedigree(
      ped_component = ped_component,
      ped_ped = ped_ped,
      pos = pos,
      personID = personID,
      momID = momID,
      dadID = dadID
    )
  }

  # Construct a pedigree object to compute layout coordinates
  if (nrow(ped) > config$fast_threshold) {
    components <- splitPedigreeComponents(
      ped = ped,
      personID = personID,
      momID = momID,
      dadID = dadID
    )

    if (length(components) > 1L) {
      component_dfs <- lapply(seq_along(components), function(i) {
        idx <- components[[i]]
        ped_component <- ped[idx, , drop = FALSE]

        component_df <- alignAndExtractComponent(ped_component, config = config)
        component_df$.component <- i

        component_df
      })

      ped_out <- stitchComponents(component_dfs)
      rownames(ped_out) <- NULL

      ped_out <- .applyFixedPositions(
        ds = ped_out, config = config,
        personID = personID, momID = momID, dadID = dadID
      )
      return(ped_out)
    }
  }

  ped_out <- alignAndExtractComponent(ped, config = config)
  rownames(ped_out) <- NULL

  ped_out <- .applyFixedPositions(
    ds = ped_out, config = config,
    personID = personID, momID = momID, dadID = dadID
  )
  return(ped_out)
}

#' @title Pin individuals to fixed layout positions
#' @description
#' Overrides the computed layout coordinates for specific individuals, using the
#' `config$fixed_positions` data frame. Positions are interpreted in raw
#' layout-slot units (the units produced by `calculateCoordinates()`, before
#' spacing and radial transforms), so pins compose with `generation_width` /
#' `generation_height` scaling and radial layout. Because all downstream
#' connection anchors are derived from `x_pos`/`y_pos`, pinning automatically
#' propagates to the connecting segments. When a pinned individual is a parent,
#' the family anchor (`x_fam`/`y_fam`) of their children is recomputed as the
#' midpoint of the (pinned) parent positions, unless
#' `config$fixed_positions_update_family` is `FALSE`.
#' @param ds A data frame of layout coordinates with at least `x_pos`, `y_pos`,
#'   and the `personID` column.
#' @param config A configuration list. Uses `fixed_positions` and
#'   `fixed_positions_update_family`.
#' @param personID Name of the individual ID column.
#' @param momID Name of the mother ID column.
#' @param dadID Name of the father ID column.
#' @return The input data frame with pinned coordinates applied.
#' @keywords internal
.applyFixedPositions <- function(ds, config,
                                 personID = "personID",
                                 momID = "momID",
                                 dadID = "dadID") {
  # Use [[ ]] (exact match) rather than $ to avoid partial matching against
  # the sibling key `fixed_positions_update_family`.
  fp <- config[["fixed_positions"]]
  if (is.null(fp)) {
    return(ds)
  }
  if (!is.data.frame(fp)) {
    stop(
      "config$fixed_positions must be a data.frame with an id column and ",
      "'x' and/or 'y' columns."
    )
  }

  # Identify the id column: prefer the personID name, then "id"/"ID".
  id_col <- if (personID %in% names(fp)) {
    personID
  } else if ("id" %in% names(fp)) {
    "id"
  } else if ("ID" %in% names(fp)) {
    "ID"
  } else {
    names(fp)[1]
    warning(
      "config$fixed_positions must include an ID column named ",
      shQuote(personID), " (or 'id'/'ID'). Using the first column '", names(fp)[1], "' as ID."
    )
  }

  has_x <- "x" %in% names(fp)
  has_y <- "y" %in% names(fp)
  if (!has_x && !has_y) {
    warning(
      "config$fixed_positions has no 'x' or 'y' column; no positions pinned."
    )
    return(ds)
  }

  unmatched <- setdiff(stats::na.omit(as.character(fp[[id_col]])), as.character(ds[[personID]]))
  if (length(unmatched) > 0) {
    warning(
      "fixed_positions IDs not found in pedigree and ignored: ",
      paste(unmatched, collapse = ", ")
    )
  }

  # Apply absolute overrides (all layout appearances of a matched ID)
  pinned_ids <- character()
  for (i in seq_len(nrow(fp))) {
    rows <- which(as.character(ds[[personID]]) == as.character(fp[[id_col]][i]))
    if (length(rows) == 0) next
    if (has_x && !is.na(fp$x[i])) ds$x_pos[rows] <- fp$x[i]
    if (has_y && !is.na(fp$y[i])) ds$y_pos[rows] <- fp$y[i]
    pinned_ids <- c(pinned_ids, as.character(fp[[id_col]][i]))
  }

  # Optionally recompute the family anchor for children of pinned parents so the
  # parent-to-children connector follows the pinned parent. NULL (unset) -> TRUE.
  if (!isFALSE(config[["fixed_positions_update_family"]]) &&
    length(pinned_ids) > 0 &&
    all(c("x_fam", "y_fam") %in% names(ds))) {
    affected <- which(as.character(ds[[momID]]) %in% pinned_ids | as.character(ds[[dadID]]) %in% pinned_ids)
    if (length(affected) > 0) {
      xp <- stats::setNames(ds$x_pos, as.character(ds[[personID]]))
      yp <- stats::setNames(ds$y_pos, as.character(ds[[personID]]))
      for (r in affected) {
        parents <- c(ds[[momID]][r], ds[[dadID]][r])
        parents <- as.character(parents[!is.na(parents)])
        px <- xp[parents]
        py <- yp[parents]
        px <- px[!is.na(px)]
        py <- py[!is.na(py)]
        if (length(px) > 0) ds$x_fam[r] <- mean(px)
        if (length(py) > 0) ds$y_fam[r] <- mean(py)
      }
    }
  }

  ds
}
#' Align pedigree with additional relations
#'
#' This function aligns a pedigree object using relations if provided, or
#' defaults to the default alignment settings.
#' @inheritParams calculateCoordinates
#' @return A data frame with the aligned positions of individuals in the pedigree.
#' @keywords internal

alignPedigreeWithRelations <- function(ped,
                                       personID,
                                       dadID,
                                       momID,
                                       code_male = NULL,
                                       sexVar = "sex",
                                       config = NULL) {
  # recodeSex <- function(
  #  ped, verbose = FALSE, code_male = NULL, code_na = NULL, code_female = NULL,
  #   recode_male = "M", recode_female = "F", recode_na = NA_character_)
  # Recode sex values in case non-standard codes are used (e.g., "M"/"F")

  if (!is.null(code_male)) {
    config$code_male <- code_male
    code_male <- NULL
  }
  if (sexVar != "sex") {
    ped$sex <- ped[[sexVar]]
  }

  ped_recode <- BGmisc::recodeSex(ped,
    code_male = config$code_male # ,
    #  code_female = config$code_female
  )
  if ("relation" %in% names(config) && !is.null(config$relation)) {
    # Construct a pedigree object to compute layout coordinates

    ped_ped <- tryCatch(
      pedigree(
        id = ped[[personID]],
        dadid = ped[[dadID]],
        momid = ped[[momID]],
        sex = ped_recode$sex,
        relation = config$relation
      ),
      error = function(e) {
        stop(
          "Error in constructing pedigree object. Please check that you've ",
          "correctly specified the sex of individuals. Setting code_male may help ",
          "if non-standard codes are used (e.g., 'M'/'F'; '1,2').\n\n",
          "Underlying error: ", conditionMessage(e),
          call. = FALSE
        )
      }
    )
  } else {
    ped_ped <- tryCatch(
      pedigree(
        id = ped[[personID]],
        dadid = ped[[dadID]],
        momid = ped[[momID]],
        sex = ped_recode[[sexVar]]
      ),
      error = function(e) {
        stop(
          "Error in constructing pedigree object. Please check that you've ",
          "correctly specified the sex of individuals. Setting code_male may help ",
          "if non-standard codes are used (e.g., 'M'/'F'; '1,2').\n\n",
          "Underlying error: ", conditionMessage(e),
          call. = FALSE
        )
      }
    )
  }

  return(ped_ped)
}

#' Align pedigree with hints for plotting
#' This function aligns a pedigree object using hints if provided,
#'  or defaults to  the default alignment settings.
#' @param ped_ped A pedigree object created by `pedigree()`.
#' @param config A list of configuration options
#' @return A data frame with the aligned positions of individuals in the pedigree.
#' @keywords internal

alignPedigreeWithHints <- function(ped_ped, config) {
  if ("hints" %in% names(config) && !is.null(config$hints)) {
    # Check if hints are provided
    autohint <- tryCatch(
      kinship2_autohint(
        ped_ped,
        config$hints,
        align = config$ped_align,
        packed = config$ped_packed
      ),
      error = function(e) {
        warning(
          "Your hints caused an error and were not used.\n",
          "Using default hints instead.\n\n",
          "Underlying error from kinship2_autohint(): ", conditionMessage(e),
          call. = FALSE
        )
        kinship2_autohint(ped_ped,
          align = config$ped_align,
          packed = config$ped_packed
        )
      }
    )
    # Align pedigree for plotting
    pos <- kinship2_align.pedigree(
      ped_ped,
      packed = config$ped_packed,
      align = config$ped_align,
      width = config$ped_width,
      hints = autohint
    )
  } else {
    # -----
    # Extract layout information
    # -----
    # Align pedigree for plotting
    pos <- kinship2_align.pedigree(
      ped_ped,
      packed = config$ped_packed,
      align = config$ped_align,
      width = config$ped_width
    )
  }
  return(pos)
}


#' Split pedigree rows into connected-component index lists
#'
#' Delegates to [BGmisc::ped2fam()], which uses `igraph::components()` on the
#' parent-child graph. Returns row indices per component in original `ped` order.
#'
#' @inheritParams calculateCoordinates
#' @return Unnamed list of integer row-index vectors, one per component.
#' @keywords internal
splitPedigreeComponents <- function(ped, personID, momID, dadID) {
  ped_fam <- BGmisc::ped2fam(
    ped,
    famID    = "famID",
    personID = personID,
    momID    = momID,
    dadID    = dadID
  )
  if (length(unique(ped_fam[["famID"]])) == 1L) {
    return(list(seq_len(nrow(ped))))
  }
  # ped2fam may reorder rows via merge(); match back to original order
  comp_ids <- ped_fam[["famID"]][match(ped[[personID]], ped_fam[[personID]])]
  unname(split(seq_len(nrow(ped)), comp_ids))
}


#' Offset x positions across components and combine into one data frame
#'
#' @param component_dfs List of data frames, one per component.
#' @param x_offset Numeric, initial offset to apply to the first component (default 0).
#' @return Single data frame with x positions shifted to prevent overlap.
#' @keywords internal
stitchComponents <- function(component_dfs,
                             x_offset = 0) {
  if (length(component_dfs) == 1L) {
    return(component_dfs[[1L]])
  }

  for (i in seq_along(component_dfs)) {
    df <- component_dfs[[i]]
    component_dfs[[i]]$x_pos <- df$x_pos + x_offset
    component_dfs[[i]]$x_order <- df$x_order + as.integer(floor(x_offset))
    component_dfs[[i]]$x_fam <- df$x_fam + x_offset # NA + number = NA, safe
    x_max <- max(df$x_pos, na.rm = TRUE)
    if (!is.finite(x_max)) x_max <- 1.0 # isolated individual with NA x_pos
    x_offset <- x_offset + x_max + 2.0
  }

  do.call(rbind, component_dfs)
}
