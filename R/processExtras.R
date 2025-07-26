utils::globalVariables(c("coreID")) # no alternative with group_by

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
#' @importFrom utils modifyList
#' @importFrom dplyr filter select mutate starts_with if_else group_by slice_min ungroup pull arrange rowwise
# note that i think that the merging by coreID might not be behaving as expected with selecting spouses and parents correctly
processExtras <- function(ped, config = list()) {
  # ---- 1. Sanity checks and data integrity validation -----------------------
  if (!inherits(ped, "data.frame")) {
    stop("ped must be a data.frame")
  }
  default_config <- list(
    override_many2many = FALSE # default behavior
  )
  config <- utils::modifyList(default_config, config)

  req_cols <- c(
    "personID", "x_pos", "y_pos",
    "momID", "dadID", "spouseID", "extra"
  )
  miss <- setdiff(req_cols, names(ped))
  if (length(miss)) {
    stop("ped is missing columns: ", paste(miss, collapse = ", "))
  }


  # ---- 2. Assign unique IDs and initial relationship flags ------------------
  ped$newID <- seq_len(nrow(ped))


  idsextras <- dplyr::filter(ped, .data$extra == TRUE) |>
    dplyr::select("personID") |>
    dplyr::pull() |>
    unique()

  # flags complicated relationships that require special handling
  ped <- ped |>
    dplyr::mutate(
      momSpouse = dplyr::if_else(!is.na(.data$spouseID) & !is.na(.data$momID) & (.data$spouseID == .data$momID), TRUE, FALSE),
      dadSpouse = dplyr::if_else(!is.na(.data$spouseID) & !is.na(.data$dadID) & (.data$spouseID == .data$dadID), TRUE, FALSE),
      total_blue = .data$dadSpouse | .data$momSpouse
    ) |>
    dplyr::select(-"dadSpouse", -"momSpouse")

  # ---- 3. Give every extra appearance a unique numeric personID -----------

  # Assign a new ID to each extra appearance
  if (is.numeric(ped$personID) || is.integer(ped$personID) || is.double(ped$personID) # numeric
  ) {
    ped <- ped |>
      dplyr::arrange(.data$personID, .data$newID) |>
      dplyr::mutate(
        coreID = .data$personID,
        personID = dplyr::if_else(
          .data$extra,
          .data$personID + .data$newID / 10000, # numeric, unique
          .data$personID
        )
      )
  } else {
    ped <- ped |>
      dplyr::arrange(.data$personID, .data$newID) |>
      dplyr::mutate(
        coreID = as.character(.data$personID),
        momID = as.character(.data$momID),
        dadID = as.character(.data$dadID),
        spouseID = as.character(.data$spouseID),
        personID = as.character(.data$personID),
        personID = dplyr::if_else(
          .data$extra,
          paste0(.data$personID, "_", .data$newID), # character, unique
          .data$personID
        ),
        personID = gsub("NA", NA_character_, .data$personID)
      )
  }

  # ---- 4. Isolate duplicates for relationship resolution --------------------
  ped <- ped |> # flag anyone with extra appearances
    dplyr::mutate(extra = dplyr::case_when(
      .data$coreID %in% idsextras ~ TRUE,
      #  .data$momID %in% idsextras ~ TRUE,
      #   .data$dadID %in% idsextras ~ TRUE,
      #  .data$spouseID %in% idsextras ~ TRUE,
      TRUE ~ .data$extra
    ))

  extras <- dplyr::filter(ped, .data$extra)
  if (config$debug == TRUE) {
    message("Found ", nrow(extras), " extra appearances in the pedigree.")
    message("Unique core IDs: ", nrow(unique(extras$coreID)))
    message("Core IDs of extras: ", paste(unique(extras$coreID), collapse = ", "))
    if ("name" %in% names(extras)) {
      message("Names of extras: ", paste(unique(extras$name), collapse = ", "))
    }
    message("Total blue count: ", sum(extras$total_blue, na.rm = TRUE))
  }

  # ---- 5. Attach relative coordinates & compute distances -------------------
  # Mother's coordinates
  # mom_coords <- getRelativeCoordinates(
  #   ped = ped,
  #   connections = extras,
  #    relativeIDvar = "momID",
  #   x_name = "x_mom",
  #    y_name = "y_mom",
  #    multiple = "all" # "any"
  ##  )


  # Father's coordinates
  # dad_coords <- getRelativeCoordinates(
  #  ped = ped,
  #  connections = extras,
  #   relativeIDvar = "dadID",
  #   x_name = "x_dad",
  #   y_name = "y_dad",
  #   multiple = "all" # "any"
  #  )


  # Spouse's coordinates
  spouse_coords <- getRelativeCoordinates(
    ped = ped,
    connections = extras,
    relativeIDvar = "spouseID",
    x_name = "x_spouse",
    y_name = "y_spouse",
    multiple = "all"
  )

  # Parent hash coordinates
  #  parent_hash_coords <- extras |>
  #    dplyr::left_join(mom_coords, by = c("newID", "personID", "momID")) |>
  #    dplyr::left_join(dad_coords, by = c("newID", "personID", "dadID")) |>
  #    dplyr::filter(!is.na(.data$parent_hash)) |>
  #   dplyr::mutate(
  #     x_parent_hash = mean(c(.data$x_dad, .data$x_mom), na.rm = TRUE),
  #     y_parent_hash = mean(c(.data$y_dad, .data$y_mom), na.rm = TRUE)
  #   ) |>
  #  dplyr::select(
  #    "newID", "personID",
  #     "x_parent_hash", "y_parent_hash"
  #   )


  extras <- extras |>
    #   dplyr::left_join(mom_coords, by = c("newID", "personID", "momID")) |>
    #   dplyr::left_join(dad_coords, by = c("newID", "personID", "dadID")) |>
    dplyr::left_join(spouse_coords, by = c("newID", "personID", "spouseID")) # |>
  #    dplyr::left_join(parent_hash_coords, by = c("newID", "personID"))


  # ---- 5b. compute distance metrics  --------------
  extras <- extras |>
    dplyr::mutate(
      #     dist_mom = computeDistance(
      #      method = "cityblock",
      #      x1 = .data$x_pos, y1 = .data$y_pos,
      #       x2 = .data$x_mom, y2 = .data$y_mom
      #     ),
      #      dist_dad = computeDistance(
      #       method = "cityblock",
      #       x1 = .data$x_pos, y1 = .data$y_pos,
      #       x2 = .data$x_dad, y2 = .data$y_dad
      #     ),
      dist_spouse = computeDistance(
        method = "cityblock",
        x1 = .data$x_pos, y1 = .data$y_pos,
        x2 = .data$x_spouse, y2 = .data$y_spouse
      ) # ,
      #      parent_dist_mid = computeDistance(
      #     method = "cityblock",
      #    x1 = .data$x_pos, y1 = .data$y_pos,
      #    x2 = .data$x_parent_hash, y2 = .data$y_parent_hash
      #   ),
      #     parent_dist_sum = .data$dist_mom + .data$dist_dad
    )


  # ---- 6. choose winning duplicate per relationship -----------------------


  spouse_winner <- extras |>
    dplyr::group_by(.data$coreID, .data$spouseID) |>
    dplyr::slice_min(.data$dist_spouse, n = 1, with_ties = FALSE) |>
    dplyr::ungroup() |>
    dplyr::select("coreID", "personID") |>
    dplyr::rename(spouse_choice = "personID")


  # if (sum(ped$total_blue, na.rm = TRUE) == 0) {
  #   parent_winner <- extras |>
  #     dplyr::group_by(.data$coreID) |>
  #     dplyr::slice_min(.data$parent_dist_mid,
  #       n = 1,
  #       with_ties = FALSE
  #     ) |>
  #     dplyr::ungroup() |>
  #     dplyr::select("coreID", "personID") |>
  #     dplyr::rename(parent_choice = "personID")
  # } else {
  #   # if there are spouseID == momID or spouseID == dadID, then parent choice needs to be the 2nd closest
  #   # this version penalizes total distance by summing the distances to mom and dad
  #   parent_winner <- extras |>
  #     dplyr::group_by(.data$coreID) |>
  #     dplyr::arrange(.data$parent_dist_sum, .by_group = TRUE) |>
  #     dplyr::mutate(
  #       rank       = dplyr::row_number(), # 1 = closest, 2 = second‑closest …
  #       pick_rank  = dplyr::if_else(any(.data$total_blue), 2L, 1L) # group‑level choice
  #     ) |>
  #     dplyr::filter(.data$rank == .data$pick_rank) |>
  #     dplyr::ungroup() |>
  #     dplyr::select("coreID", "personID") |>
  #     dplyr::rename(parent_choice = "personID")
  # }
  # ---- 7. row‑wise relink using nearest appearance -------------------------

  # lookup table: every appearance of every coreID
  dup_xy <- ped |>
    dplyr::select("personID", "coreID", "x_pos", "y_pos", "total_blue")

  # pre-split version for faster lookup
  dup_xy_list <- split(dup_xy, dup_xy$coreID)

  closest_dup <- function(target_core, x0, y0) {
    cand <- dup_xy_list[[as.character(target_core)]]
    if (nrow(cand) == 0L) {
      return(dup_xy$coreID[NA_integer_]) # return correct NA type
    }
    # compute Manhattan (“city‑block”) distance for all candidates
    d <- computeDistance(
      method = "cityblock",
      x1 = x0, y1 = y0,
      x2 = cand$x_pos, y2 = cand$y_pos
    )
    ord <- order(d) # ascending distance
    pick <- if (any(cand$total_blue, na.rm = TRUE)) {
      2L
    } else {
      1L
    } # 2nd if blue present, else 1st

    if (length(ord) < pick) {
      pick <- 1L
    }

    cand$personID[ord[pick]]

    #  cand$personID[
    #    which.min(
    #      computeDistance(method = "cityblock",
    #                     x1= x0, y1=y0,
    #                     x2=cand$x_pos, y2=cand$y_pos)
    #   )
    #  ]
  }

  relink <- function(df, col) {
    df |>
      dplyr::rowwise() |>
      dplyr::mutate(
        "{col}" := {
          tgt <- .data[[col]]
          if (is.na(tgt)) {
            tgt[NA_integer_] # return correct NA type
          } else {
            closest_dup(tgt, .data$x_pos, .data$y_pos)
          }
        }
      ) |>
      dplyr::ungroup()
  }

  # remove parent ids from all but the closest coreID,
  # if there's no choice to be made, then keep existing momID

  ped <- ped |>
    dplyr::left_join(spouse_winner, by = "coreID") |>
    #   dplyr::left_join(parent_winner, by = "coreID") |>
    dplyr::mutate(
      # momID = dplyr::case_when(
      #   .data$personID == .data$parent_choice ~ .data$momID,
      #   !is.na(.data$parent_choice) ~ ped$momID[NA_integer_],
      #   TRUE ~ .data$momID
      # ),
      # dadID = dplyr::case_when(
      #   .data$personID == .data$parent_choice ~ .data$dadID,
      #   !is.na(.data$parent_choice) ~ ped$dadID[NA_integer_],
      #   TRUE ~ .data$dadID
      # ),
      spouseID = dplyr::case_when(
        .data$personID == .data$spouse_choice ~ .data$spouseID,
        !is.na(.data$spouse_choice) ~ ped$spouseID[NA_integer_],
        TRUE ~ .data$spouseID
      )
    ) |>
    dplyr::select(
      # -"parent_choice",
      -"spouse_choice",
      -dplyr::starts_with("newID")
    )
  ped <- ped |>
    relink("spouseID") |>
    #   relink("momID") |>
    #  relink("dadID") |>
    unique()

  # rehash
  ped <- ped |>
    dplyr::mutate(
      #     parent_hash = .makeSymmetricKey(.data$momID, .data$dadID),
      couple_hash = .makeSymmetricKey(.data$personID, .data$spouseID)
    ) |>
    dplyr::mutate(
      #  parent_hash = gsub("NA.NA", NA_character_, .data$parent_hash),
      couple_hash = gsub("NA.NA", NA_character_, .data$couple_hash)
    )
  # ---- 8. remove duplicates and return ------------------------------------

  # Coordinates of the individual's other appearance ("self")
  if (config$override_many2many == TRUE) {
    self_relationship <- "many-to-many"
  } else {
    self_relationship <- NULL
  }
  self_coords <- extras |>
    dplyr::left_join(
      ped,
      by = c("coreID"),
      suffix = c("", "_other"),
      relationship = self_relationship,
      multiple = "all"
    ) |>
    dplyr::filter(.data$personID != .data$personID_other) |>
    dplyr::mutate(
      x_otherself = .data$x_pos_other,
      y_otherself = .data$y_pos_other
    ) |>
    unique()

  full_extra <- list(
    ped = ped,
    self_coords = self_coords
  )
  if (config$debug == TRUE) {
    message("Processed ", nrow(full_extra$ped), " individuals in the pedigree.")
    message("Found ", nrow(full_extra$self_coords), " self coordinates.")
    # assign("DEBUG_full_extra", full_extra, envir = .GlobalEnv)
  }
  return(full_extra)
}
