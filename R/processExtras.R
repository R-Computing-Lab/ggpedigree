

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

  req_cols <- c("personID", "x_pos", "y_pos", "dadID", "momID")
  if (!all(req_cols %in% names(ped))) {
    stop("ped must contain personID, x_pos, y_pos, dadID, and momID columns")
  }

  default_config <- list()
  config <- utils::modifyList(default_config, config)

  # Assign unique ID per row for later use
  ped$newID <- seq_len(nrow(ped))

  # -----
  # Identify duplicated individuals
  # -----

  # Find all individuals with extra appearances
  idsextras <- dplyr::filter(ped, .data$extra == TRUE) |>
    dplyr::select("personID") |>
    dplyr::pull() |>
    unique()

  ped <- ped  |> # flag anyone with extra appearances
    dplyr::mutate(extra = dplyr::case_when(.data$personID %in% idsextras ~ TRUE,
                                           .data$momID %in% idsextras ~ TRUE,
                                           .data$dadID %in% idsextras ~ TRUE,
                                           .data$spouseID %in% idsextras ~ TRUE,
                                         TRUE ~ .data$extra))


  # -----
  # Subset to duplicated entries only # note that tidyselect hates .data pronouns
  # -----

  extras <- dplyr::filter(ped, .data$personID %in% idsextras) |>
    dplyr::select(
      "newID",
      "personID",
      "x_pos", "y_pos",
      "dadID", "momID","parent_hash", "couple_hash",
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

  # parent_hash coordinates
  parent_hash_coords <- extras |> # need to get mom and dad coordinates
    dplyr::left_join(mom_coords, by = c("newID", "personID", "momID")) |>
    dplyr::left_join(dad_coords, by = c("newID", "personID", "dadID")) |>
    dplyr::left_join(
      ped,
      by = c("parent_hash"),
      suffix = c("", "_sib"),
      multiple = "all"
    ) |>
    dplyr::filter(!is.na(.data$parent_hash)) |>
    dplyr::mutate(
      x_parent_hash = mean(c(
        .data$x_dad,
        .data$x_mom
      )),
      y_parent_hash = mean(c(
        .data$y_dad,
        .data$y_mom
      ))
    ) |>
    dplyr::select(
      .data$newID,
      .data$personID,
      .data$parent_hash,
      .data$couple_hash,
      .data$x_parent_hash,
      .data$y_parent_hash
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
    ) |>
    dplyr::left_join(parent_hash_coords,
      by = c("newID", "personID", "parent_hash"),
      multiple = "all"
    )

#print(extras)
  # -----
  # Compute Euclidean distances between this appearance and:
  #   - mom, dad, spouse
  #   - same individual in other location (otherself)
  # These will be used to choose the "closest" relationship.
  # minkowski distance could be used here as well aka "city block" distance
  # -----
  extras <- extras |>
    dplyr::mutate(
      dist_mom = computeDistance(method = "cityblock",
                                 x1 = .data$x_pos,
                                 y1 = .data$y_pos,
                                 x2 = .data$x_mom,
                                 y2 = .data$y_mom),

      dist_mom_other = computeDistance(method = "cityblock",
                                       x1 = .data$x_otherself,
                                       y1 = .data$y_otherself,
                                       x2 = .data$x_mom,
                                       y2 = .data$y_mom),
      dist_dad = computeDistance(method = "cityblock",
                                 x1 = .data$x_pos,
                                 y1 = .data$y_pos,
                                 x2 = .data$x_dad,
                                 y2 = .data$y_dad),
      dist_dad_other = computeDistance(method = "cityblock",
                                       x1 = .data$x_otherself,
                                       y1 = .data$y_otherself,
                                       x2 = .data$x_dad,
                                       y2 = .data$y_dad),
      # spouse distance
      dist_spouse = computeDistance(method = "cityblock",
                                    x1 = .data$x_pos,
                                 y1 = .data$y_pos,
                                 x2 = .data$x_spouse,
                                 y2 = .data$y_spouse),
      dist_spouse_other = computeDistance(method = "cityblock",
                                          x1 = .data$x_otherself,
                                       y1 = .data$y_otherself,
                                       x2 = .data$x_spouse,
                                       y2 = .data$y_spouse),
      dist_otherself = computeDistance(method = "cityblock",
                                       x1 = .data$x_pos,
                                 y1 = .data$y_pos,
                                 x2 = .data$x_otherself,
                                 y2 = .data$y_otherself),
      dist_parent_hash = computeDistance(method = "cityblock",
                                             x1 = .data$x_pos,
                                       y1 = .data$y_pos,
                                       x2 = .data$x_parent_hash,
                                       y2 = .data$y_parent_hash),
      dist_parent_hash_other = computeDistance(method = "cityblock",
                                              x1 = .data$x_otherself,
                                              y1 = .data$y_otherself,
                                              x2 = .data$x_parent_hash,
                                              y2 = .data$y_parent_hash)


    )


  # -----
  # When there are multiple spouses, keep only the appearance
  # where the individual is closest to one of their spouses.
  # -----

#  extras <- extras |>
#    dplyr::group_by(.data$newID, .data$personID) |>
#    dplyr::mutate(
#      min_spouse = min(.data$dist_spouse, na.rm = TRUE),
#      num_spouse = dplyr::n()
#    ) |>
#    dplyr::ungroup()
#  extras <- extras |>
#    dplyr::filter(.data$num_spouse == 1 | .data$dist_spouse == .data$min_spouse) |>
#    dplyr::select(
#      -.data$min_spouse,
#      -.data$num_spouse
#    )


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
        .data$dist_mom == .data$dist_mom_other &
          .data$newID       <  .data$newID_other     ~ TRUE,
        TRUE                                ~ FALSE
      ),
      dad_closer = dplyr::case_when(
        .data$dist_dad < .data$dist_dad_other ~ TRUE,
        .data$dist_dad_other < .data$dist_dad ~ FALSE,
        .data$dist_dad == .data$dist_dad_other &
          .data$newID       <  .data$newID_other     ~ TRUE,
        TRUE ~ TRUE
      ),
      spouse_closer = dplyr::case_when(
        .data$dist_spouse < .data$dist_spouse_other ~ TRUE,
        .data$dist_spouse_other < .data$dist_spouse ~ FALSE,
        .data$dist_spouse == .data$dist_spouse_other &
          .data$newID       <  .data$newID_other     ~ TRUE,

        TRUE ~ FALSE
      ),
     parent_hash_closer = dplyr::case_when(
        .data$dist_parent_hash < .data$dist_parent_hash_other ~ TRUE,
        .data$dist_parent_hash_other < .data$dist_parent_hash ~ FALSE,
        TRUE ~ FALSE
      )
    )


  # Then:
  #   - Determine which of mom, dad, or spouse is closest in absolute terms
  #   - Use that to decide whether to retain connections to that relative

#  extras <- extras |>
#    dplyr::mutate(
#      closest_relative = dplyr::case_when(
#        .data$dist_mom <= .data$dist_dad & .data$dist_mom <= .data$dist_spouse ~ "mom",
#        .data$dist_dad < .data$dist_mom & .data$dist_dad <= .data$dist_spouse ~ "dad",
#        TRUE ~ "spouse"
#      )
#    )

  # -----
  # Based on which relative is closest, determine which links to keep
  # -----

  extras <- extras |>
    dplyr::mutate(
      link_as_mom = .data$mom_closer,
      link_as_dad = .data$dad_closer,
      link_as_spouse = .data$spouse_closer,
      link_as_sibling =   .data$link_as_mom | .data$link_as_dad
#.data$parent_hash_closer
      )

  ### per‑spouse keeper  ----------------------------------------
  extras <- extras |>
    dplyr::mutate(
      dist_spouse_fix = dplyr::if_else(is.na(.data$dist_spouse),
                                       Inf, .data$dist_spouse)
    ) |>
    dplyr::group_by(.data$personID) |>
    dplyr::mutate(
      keep_spouse = (.data$dist_spouse_fix ==
                       min(.data$dist_spouse_fix, na.rm = TRUE)) #&
     #   (dplyr::row_number() == 1)
    ) |>
    dplyr::ungroup() |>
    dplyr::mutate(
      link_as_spouse = .data$link_as_spouse & .data$keep_spouse
    ) |>
    dplyr::select(-"dist_spouse_fix", -"keep_spouse") |> unique()

  ### END INSERT --------------------------------------------------------------

  # --- Keep ONE appearance per person for parent / sibling links ----
  extras <- extras |>
    dplyr::mutate(
      total_parent_dist = dplyr::if_else(
        is.na(.data$dist_mom + .data$dist_dad),
        Inf,
        .data$dist_mom + .data$dist_dad
      )
    ) |>
    dplyr::group_by(.data$personID) |>
    dplyr::mutate(
      min_total_parent_dist = min(.data$total_parent_dist, na.rm = TRUE),
      keep_links = (.data$total_parent_dist == .data$min_total_parent_dist)# &
      #  (dplyr::row_number() == 1)
    ) |>
    dplyr::ungroup() |>
    dplyr::mutate(
      link_as_mom     = .data$link_as_mom     & .data$keep_links,
      link_as_dad     = .data$link_as_dad     & .data$keep_links,
      link_as_sibling = .data$link_as_sibling & .data$keep_links
    ) |>
    dplyr::select(
      -"total_parent_dist",
      -"min_total_parent_dist",
      -"keep_links"
    )  |> dplyr::mutate(
      link_any = dplyr::case_when(
        .data$link_as_mom == TRUE | .data$link_as_dad == TRUE |
        .data$link_as_sibling == TRUE |  .data$link_as_spouse == TRUE ~ TRUE,
        TRUE ~ FALSE
      )
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
      .data$link_as_sibling,
      .data$link_any,
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
      link_as_mom =  dplyr::case_when(
        is.na(.data$link_as_mom) ~ TRUE,
        .data$link_as_mom == TRUE ~ TRUE,
        .data$link_as_mom == FALSE ~ FALSE
      ),
      link_as_dad =  dplyr::case_when(
        is.na(.data$link_as_dad) ~ TRUE,
        .data$link_as_dad == TRUE ~ TRUE,
        .data$link_as_dad == FALSE ~ FALSE
      ),
      link_as_spouse = dplyr::case_when(
        .data$link_as_spouse == FALSE ~ FALSE,
        is.na(.data$link_as_spouse) ~ TRUE,
        .data$link_as_spouse == TRUE ~ TRUE),
      link_as_sibling = dplyr::case_when(
        is.na(.data$link_as_sibling) ~ TRUE,
        .data$link_as_sibling == TRUE ~ TRUE,
        .data$link_as_sibling == FALSE ~ FALSE),
      link_any = dplyr::case_when(
        is.na(.data$link_any) ~ TRUE,
        .data$link_any == TRUE ~ TRUE,
        .data$link_any == FALSE ~ FALSE)
      ) |> filter(
        .data$link_any == TRUE
      )



  return(ped)
}
