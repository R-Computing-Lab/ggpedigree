

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


    # ---- sanity checks -------------------------------------------------------
    if (!inherits(ped, "data.frame")) {
      stop("ped must be a data.frame")
    }

    req_cols <- c("personID", "x_pos", "y_pos",
                  "momID", "dadID", "spouseID", "extra")
    miss <- setdiff(req_cols, names(ped))
    if (length(miss))
      stop("ped is missing columns: ", paste(miss, collapse = ", "))

    # ---- 1. ensure a unique row key  ----

      ped$newID <- seq_len(nrow(ped))

    idsextras <- dplyr::filter(ped, .data$extra == TRUE) |>
      dplyr::select("personID") |>
      dplyr::pull() |>
      unique()


    # ---- 2. give every extra appearance a unique numeric personID -----------
    ped <- ped |>
      dplyr::arrange(.data$personID, .data$newID) |>
      dplyr::mutate(
        coreID   = .data$personID,
        personID = dplyr::if_else(
          .data$extra,
          .data$personID + .data$newID / 1000,  # numeric, unique
          .data$personID
        )
      )

    ped <- ped  |> # flag anyone with extra appearances
      dplyr::mutate(extra = dplyr::case_when(.data$coreID %in% idsextras ~ TRUE,
                                             .data$momID %in% idsextras ~ TRUE,
                                             .data$dadID %in% idsextras ~ TRUE,
                                             .data$spouseID %in% idsextras ~ TRUE,
                                             TRUE ~ .data$extra))


    # ---- 3. isolate duplicates for distance logic ---------------------------
    extras <- dplyr::filter(ped, .data$extra)

    # ---- 3a. attach relative coordinates (same helpers you use) -------------
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

    parent_hash_coords <- extras |>
      dplyr::left_join(mom_coords, by = c("newID", "personID", "momID")) |>
      dplyr::left_join(dad_coords, by = c("newID", "personID", "dadID")) |>
      dplyr::filter(!is.na(.data$parent_hash)) |>
      dplyr::mutate(
        x_parent_hash = mean(c(.data$x_dad, .data$x_mom), na.rm = TRUE),
        y_parent_hash = mean(c(.data$y_dad, .data$y_mom), na.rm = TRUE)
      ) |>
      dplyr::select(.data$newID, .data$personID,
                    .data$x_parent_hash, .data$y_parent_hash)

    extras <- extras |>
      dplyr::left_join(mom_coords,    by = c("newID", "personID", "momID")) |>
      dplyr::left_join(dad_coords,    by = c("newID", "personID", "dadID")) |>
      dplyr::left_join(spouse_coords, by = c("newID", "personID", "spouseID")) |>
      dplyr::left_join(parent_hash_coords, by = c("newID", "personID"))

    # ---- 3b. compute distance metrics  --------------
    extras <- extras |>
      dplyr::mutate(
        dist_mom    = computeDistance(method = "cityblock",
                                      x1 = .data$x_pos, y1 = .data$y_pos,
                                      x2 = .data$x_mom, y2 = .data$y_mom),
        dist_dad    = computeDistance(method = "cityblock",
                                      x1 = .data$x_pos, y1 = .data$y_pos,
                                      x2 = .data$x_dad, y2 = .data$y_dad),
        dist_spouse = computeDistance(method = "cityblock",
                                      x1 = .data$x_pos, y1 = .data$y_pos,
                                      x2 = .data$x_spouse, y2 = .data$y_spouse),

        total_parent_dist = computeDistance(method = "cityblock",
                                      x1 = .data$x_pos, y1 = .data$y_pos,
                                      x2 = .data$x_parent_hash, y2 = .data$y_parent_hash),

        total_parent_dist2 = .data$dist_mom + .data$dist_dad
      )

    # ---- 4. choose winning duplicate per relationship -----------------------
    spouse_winner <- extras |>
      dplyr::group_by(.data$coreID) |>
      dplyr::slice_min(.data$dist_spouse, n = 1, with_ties = FALSE) |>
      dplyr::ungroup() |>
      dplyr::select(coreID, spouse_choice = .data$personID)

    parent_winner <- extras |>
      dplyr::group_by(.data$coreID) |>
      dplyr::slice_min(.data$total_parent_dist, n = 1, with_ties = FALSE) |>
      dplyr::ungroup() |>
      dplyr::select(coreID, parent_choice = .data$personID)

    # ---- 5. row‑wise relink using nearest appearance -------------------------

    # lookup table: every appearance of every coreID
    dup_xy <- ped |>
      dplyr::select(personID, coreID, x_pos, y_pos)

    closest_dup <- function(target_core, x0, y0) {
      cand <- dup_xy[dup_xy$coreID == target_core, ]
      if (nrow(cand) == 0L) return(NA_real_)
      cand$personID[
        which.min(
          computeDistance(method = "cityblock",
                          x1= x0, y1=y0,
                          x2=cand$x_pos, y2=cand$y_pos)
        )
      ]
    }

    relink <- function(df, col) {
      df |>
        dplyr::rowwise() |>
        dplyr::mutate(
          "{col}" := {
            tgt <- .data[[col]]
            if (is.na(tgt)) NA_real_
            else closest_dup(tgt, .data$x_pos, .data$y_pos)
          }
        ) |>
        dplyr::ungroup()
    }

    ped <- ped |>
      relink("spouseID") |>
      relink("momID")    |>
      relink("dadID")

    # remove parent ids from all but the closest coreID,
    # if there's no choice to be made, then keep existing momID
if(T){
    ped <- ped |>
      dplyr::left_join(spouse_winner, by = "coreID") |>
      dplyr::left_join(parent_winner, by = "coreID") |>
      dplyr::mutate(
        momID = dplyr::case_when(.data$personID == .data$parent_choice ~ .data$momID,
                                 !is.na(.data$parent_choice) ~ NA_real_,
                                 TRUE ~ .data$momID ),

        dadID = dplyr::case_when(.data$personID == .data$parent_choice ~ .data$dadID,
                                 !is.na(.data$parent_choice) ~ NA_real_,
                                 TRUE ~ .data$dadID ),
        spouseID = dplyr::case_when(.data$personID == .data$spouse_choice ~ .data$spouseID,
                                     !is.na(.data$spouse_choice) ~ NA_real_,
                                     TRUE ~ .data$spouseID )

      )  |>     dplyr::select(-.data$parent_choice, -.data$spouse_choice)
}

    # rehash
    ped <- ped |>
      dplyr::mutate(
        parent_hash = symKey(.data$momID,  .data$dadID),
        couple_hash = symKey(.data$personID, .data$spouseID)
      ) |>
      dplyr::mutate(
        parent_hash = gsub("NA.NA", NA_real_, .data$parent_hash),
        couple_hash = gsub("NA.NA", NA_real_, .data$couple_hash)
      )


print(ped)
    return(ped)
  }




