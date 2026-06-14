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
    reposition_founders = FALSE,
    fast_threshold = 1000,
    founder_order_seed = NULL,
    founder_order_tries = 1L,
    layout_score_method = "parent_stub"
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

  # Local helper: run the full layout pipeline for one pedigree row ordering.
  # Handles both the multi-component (large pedigree) and single-component paths.
  .doOneLayout <- function(ped_input) {
    if (nrow(ped_input) > config$fast_threshold) {
      components <- splitPedigreeComponents(
        ped = ped_input, personID = personID, momID = momID, dadID = dadID
      )
      if (length(components) > 1L) {
        component_dfs <- lapply(seq_along(components), function(i) {
          ped_component <- ped_input[components[[i]], , drop = FALSE]
          component_df <- alignAndExtractComponent(ped_component, config = config)
          component_df$.component <- i
          component_df
        })
        return(stitchComponents(component_dfs))
      }
    }
    alignAndExtractComponent(ped_input, config = config)
  }

  # ---- Founder-order search -----------------------------------------------
  # kinship2 processes founders in row order, so different row shufflings
  # produce different layouts.  When founder_order_seed or founder_order_tries
  # is set, try each seed, score the resulting layout, and keep the best one.
  founder_seed <- config[["founder_order_seed"]]
  founder_tries <- max(1L, as.integer(config[["founder_order_tries"]]))

  if (!is.null(founder_seed) || founder_tries > 1L) {
    seeds <- if (!is.null(founder_seed)) {
      founder_seed + seq(0L, founder_tries - 1L)
    } else {
      seq_len(founder_tries)
    }

    best_out <- NULL
    best_score <- Inf

    for (s in seeds) {
      set.seed(s)
      ped_shuffled <- ped[sample(nrow(ped)), , drop = FALSE]
      rownames(ped_shuffled) <- NULL
      candidate <- .doOneLayout(ped_shuffled)
      rownames(candidate) <- NULL
      score <- .layoutScore(candidate,
        method  = config[["layout_score_method"]],
        twinID  = twinID
      )
      if (score < best_score) {
        best_score <- score
        best_out <- candidate
        best_seed <- s
      }
    }
    ped_out <- best_out
    if (isTRUE(config$debug) || isTRUE(config$return_best_seed)) {
      message(
        "Best founder order seed: ", best_seed,
        " with layout score: ", best_score
      )
    }
  } else {
    ped_out <- .doOneLayout(ped)
    rownames(ped_out) <- NULL
  }

  if (isTRUE(config$reposition_founders)) {
    ped_out <- .repositionCrossGenerationSpouses(
      ds = ped_out, ped = ped, personID = personID, momID = momID, dadID = dadID
    )
  }

  ped_out <- .applyFixedPositions(
    ds = ped_out, config = config,
    personID = personID, momID = momID, dadID = dadID
  )
  return(ped_out)
}

#' @title Count crossed parent-stub segments in a pedigree layout
#' @description
#' Within each generation row, counts pairs of individuals whose parent-stub
#' segments cross: individual i is to the left of j in their generation, but
#' i's parent midpoint (`x_fam`) is to the right of j's parent midpoint, or
#' vice versa.  This is an inversion count — equivalent to counting bubble-sort
#' swaps needed to restore a monotone parent-midpoint ordering.  Only
#' non-extra, placed individuals with a known `x_fam` are considered.
#' @param ds Data frame produced by `calculateCoordinates`.
#' @return A non-negative integer.
#' @keywords internal
.layoutScoreCrossings <- function(ds) {
  placed <- ds[
    !is.na(ds$x_pos) & !is.na(ds$x_fam) & (is.na(ds$extra) | !ds$extra),
  ]
  if (nrow(placed) < 2L) {
    return(0L)
  }

  count <- 0L
  for (g in unique(placed$y_pos)) {
    gr <- placed[!is.na(placed$y_pos) & placed$y_pos == g, ]
    n <- nrow(gr)
    if (n < 2L) next
    xc <- gr$x_pos
    xp <- gr$x_fam
    for (i in seq_len(n - 1L)) {
      for (j in seq.int(i + 1L, n)) {
        if (!is.na(xp[i]) && !is.na(xp[j]) &&
          ((xc[i] < xc[j]) != (xp[i] < xp[j]))) {
          count <- count + 1L
        }
      }
    }
  }
  count
}

#' @title Penalise layouts that split twins apart
#' @description
#' For each group of co-twins (individuals sharing the same value of the
#' `twinID` column), computes the number of "intruder" layout positions that
#' sit between the first and last twin in their generation row.  If N twins are
#' all adjacent the penalty is 0; if one non-twin is placed between them the
#' penalty is 1; and so on.
#'
#' Twins placed in *different* generation rows receive a flat penalty of 10 per
#' cross-generation twin pair (a structural anomaly, not just sub-optimal
#' positioning).
#'
#' Only placed, non-extra individuals are considered.  Returns 0 silently when
#' `twinID` is not a column in `ds` or when no twin groups exist.
#'
#' @param ds Data frame produced by `calculateCoordinates`.
#' @param twinID Character name of the twin-group ID column in `ds`.
#'   Defaults to `"twinID"`.
#'   @param cross_gen_penalty Numeric penalty for twins in different generation rows.
#' @return A non-negative numeric value.
#' @keywords internal
.layoutScoreTwinPenalty <- function(ds, twinID = "twinID", cross_gen_penalty = 10) {
  if (!twinID %in% names(ds)) {
    return(0)
  }

  placed <- ds[
    !is.na(ds[[twinID]]) &
      !is.na(ds$x_pos) &
      (is.na(ds$extra) | !ds$extra),
  ]
  if (nrow(placed) < 2L) {
    return(0)
  }

  penalty <- 0
  twin_groups <- split(placed, placed[[twinID]])

  for (grp in twin_groups) {
    n <- nrow(grp)
    if (n < 2L) next

    unique_rows <- unique(grp$y_pos[!is.na(grp$y_pos)])
    if (length(unique_rows) > 1L) {
      # Twins in different generation rows — structural problem, heavy penalty
      penalty <- penalty + cross_gen_penalty * (n * (n - 1L) / 2L)
      next
    }

    # Same row: penalise intruder positions between first and last twin
    # Minimum span for N adjacent twins = N - 1 position units
    x_span <- max(grp$x_pos) - min(grp$x_pos)
    penalty <- penalty + max(0, x_span - (n - 1L))
  }

  penalty
}

#' @title Score a pedigree layout
#' @description
#' Returns a single non-negative number summarising layout quality; **lower is
#' better**.  Five methods are available, controlled by `method`:
#'
#' \describe{
#'   \item{`"parent_stub"`}{Sum of `|x_fam - x_pos|` over all placed
#'     individuals.  Measures total diagonal parent-stub length: children
#'     ideally sit directly below their parent midpoint.  Fast, O(n).}
#'   \item{`"crossings"`}{Count of parent-stub inversion pairs within each
#'     generation: two stubs cross when the lateral order of children is
#'     reversed relative to the order of their parent midpoints.  O(n²) per
#'     generation but still fast for typical pedigree sizes.}
#'   \item{`"duplications"`}{Number of individuals kinship2 had to place
#'     twice (`extra = TRUE` rows).  Each duplication produces a self-loop
#'     in the plot; fewer is better.}
#'   \item{`"twin_penalty"`}{Sum of intruder positions separating co-twins
#'     within their generation row.  For N twins placed adjacently the penalty
#'     is 0; each non-twin slot that separates them adds 1.  Twins in different
#'     generation rows receive a heavy flat penalty.}
#'   \item{`"composite"`}{Weighted sum:
#'     `parent_stub + 10 * crossings + 20 * twin_penalty + 100 * duplications`.
#'     Penalises duplications most heavily, then twin separation, then
#'     crossings, then stub length.  Good default when you have no strong
#'     preference.}
#' }
#'
#' Used by the `founder_order_tries` search to rank candidate layouts when
#' `founder_order_tries > 1` or `founder_order_seed` is set.
#'
#' @param ds Data frame produced by `calculateCoordinates`.
#' @param method One of `"parent_stub"` (default), `"crossings"`,
#'   `"duplications"`, `"twin_penalty"`, or `"composite"`.
#' @param twinID Character name of the twin-group ID column in `ds`.
#'   Passed to `.layoutScoreTwinPenalty()`.  Defaults to `"twinID"`.
#' @param cross_gen_penalty Numeric penalty for twins in different generation rows.
#'   Passed to `.layoutScoreTwinPenalty()`.  Default is 10.
#' @param twin_penalty_weight Numeric weight for the twin penalty in the composite score. Default is 20.
#' @param duplication_weight Numeric weight for the duplication count in the composite score. Default is 100.
#' @return A single numeric value (≥ 0).
#' @keywords internal
.layoutScore <- function(ds,
                         method = c(
                           "parent_stub", "crossings",
                           "duplications", "twin_penalty", "composite",
                           "parent_offset", "minimal_duplicates"
                         ),
                         twinID = "twinID",
                         cross_gen_penalty = 10L,
                         twin_penalty_weight = 20L,
                         duplication_weight = 100L) {
  method <- match.arg(method)
  switch(method,
    parent_stub = ,
    parent_offset = sum(abs(ds$x_fam - ds$x_pos), na.rm = TRUE),
    crossings = .layoutScoreCrossings(ds),
    duplications = ,
    minimal_duplicates = sum(duplicated(ds$nid[!is.na(ds$nid)])),
    twin_penalty = .layoutScoreTwinPenalty(ds, twinID = twinID, cross_gen_penalty = cross_gen_penalty),
    composite = {
      sum(abs(ds$x_fam - ds$x_pos), na.rm = TRUE) +
        cross_gen_penalty * .layoutScoreCrossings(ds) +
        twin_penalty_weight * .layoutScoreTwinPenalty(ds, twinID = twinID) +
        duplication_weight * sum(duplicated(ds$nid[!is.na(ds$nid)]))
    }
  )
}

#' @keywords internal
.nearestFreeSlot <- function(anchor, taken, step = 1, max_search = 10) {
  # Search outward from anchor in both directions for the nearest integer-step
  # position not already occupied (within step/2 tolerance).
  is_taken <- function(x) any(abs(taken - x) < step / 2, na.rm = TRUE)
  for (i in seq_len(max_search)) {
    left <- anchor - i * step
    right <- anchor + i * step
    if (!is_taken(left)) {
      return(left)
    }
    if (!is_taken(right)) {
      return(right)
    }
  }
  NA_real_
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
