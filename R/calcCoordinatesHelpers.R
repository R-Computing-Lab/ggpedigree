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
  if (nrow(placed) < 2L) return(0L)

  count <- 0L
  for (g in unique(placed$y_pos)) {
    gr <- placed[!is.na(placed$y_pos) & placed$y_pos == g, ]
    n  <- nrow(gr)
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
  if (!twinID %in% names(ds)) return(0)

  placed <- ds[
    !is.na(ds[[twinID]]) &
      !is.na(ds$x_pos) &
      (is.na(ds$extra) | !ds$extra),
  ]
  if (nrow(placed) < 2L) return(0)

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
                         duplication_weight = 100L
) {
  method <- match.arg(method)
  switch(method,
         parent_stub      = ,
         parent_offset    = sum(abs(ds$x_fam - ds$x_pos), na.rm = TRUE),
         crossings        = .layoutScoreCrossings(ds),
         duplications     = ,
         minimal_duplicates = sum(duplicated(ds$nid[!is.na(ds$nid)])),
         twin_penalty     = .layoutScoreTwinPenalty(ds, twinID = twinID,cross_gen_penalty = cross_gen_penalty),
         composite        = {
           sum(abs(ds$x_fam - ds$x_pos), na.rm = TRUE) +
             cross_gen_penalty  * .layoutScoreCrossings(ds) +
             twin_penalty_weight  * .layoutScoreTwinPenalty(ds, twinID = twinID) +
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



#' @title Reposition founders placed in the wrong generation
#' @description
#' kinship2 assigns a founder's generation row based on its placed descendants.
#' When a founder's only shared child with their spouse is unplaced (nid = NA),
#' kinship2 has no generation constraint for that founder and may place them in a
#' different row from their spouse. The result is a long diagonal spouse segment
#' instead of the expected short horizontal one.
#'
#' This function detects that pattern and repositions affected founders adjacent
#' to their spouse at the spouse's generation. Only founders with zero placed
#' children are eligible — moving a founder whose descendants are already laid out
#' would misalign the parent-stub segments for those children.
#' @param ds A data frame of layout coordinates (output of
#'   `extractCoordinatesFromAlignedPedigree`).
#' @param personID Name of the individual ID column.
#' @param momID Name of the mother ID column.
#' @param dadID Name of the father ID column.
#' @return The input data frame with eligible founders repositioned.
#' @keywords internal
.repositionCrossGenerationSpouses <- function(ds, ped, personID, momID, dadID) {
  placed <- !is.na(ds$x_pos) & !isTRUE(ds$extra)
  founders <- placed & (is.na(ds$parent_fam) | ds$parent_fam == 0)
  founder_rows <- which(founders)
  if (length(founder_rows) == 0) {
    return(ds)
  }

  placed_df <- ds[placed, ]
  xp <- stats::setNames(placed_df$x_pos, as.character(placed_df[[personID]]))
  yp <- stats::setNames(placed_df$y_pos, as.character(placed_df[[personID]]))
  yor <- stats::setNames(placed_df$y_order, as.character(placed_df[[personID]]))

  # Use original ped (not ds) to find parent relationships: ds has momID/dadID
  # cleared for unplaced individuals, so shared children of cross-generation
  # spouses would be invisible if we searched ds instead.
  pid_ped <- as.character(ped[[personID]])
  mom_ped <- as.character(ped[[momID]])
  dad_ped <- as.character(ped[[dadID]])

  for (r in founder_rows) {
    pid <- as.character(ds[[personID]][r])
    py <- ds$y_pos[r]

    # Locate spouses via any shared child in the original ped
    spouse_via_mom <- dad_ped[!is.na(mom_ped) & mom_ped == pid]
    spouse_via_dad <- mom_ped[!is.na(dad_ped) & dad_ped == pid]
    spouse_ids <- unique(c(spouse_via_mom, spouse_via_dad))
    spouse_ids <- spouse_ids[!is.na(spouse_ids) & nchar(spouse_ids) > 0 & spouse_ids != pid]
    if (length(spouse_ids) == 0) next

    for (sid in spouse_ids) {
      sy <- yp[sid]
      if (is.na(sy) || sy == py) next # Same generation or spouse unplaced

      # Only reposition if this founder has no placed children at all
      children_as_mom <- pid_ped[!is.na(mom_ped) & mom_ped == pid]
      children_as_dad <- pid_ped[!is.na(dad_ped) & dad_ped == pid]
      all_children <- unique(c(children_as_mom, children_as_dad))
      placed_children <- all_children[all_children %in% as.character(placed_df[[personID]])]
      if (length(placed_children) > 0) next

      # Move to spouse's generation; pick the nearest unoccupied slot
      sx <- xp[sid]
      # x positions already used at the spouse's y level (±0.6 tolerance)
      taken <- xp[abs(yp - sy) < 0.6]
      new_x <- .nearestFreeSlot(sx, taken)
      if (is.na(new_x)) next # no free slot found; leave as-is
      ds$y_pos[r] <- sy
      ds$y_order[r] <- yor[sid]
      ds$x_pos[r] <- new_x
      break
    }
  }
  ds
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
