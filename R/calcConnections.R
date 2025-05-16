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

  # create a unique parent_hash for each individual
  # this will be used to identify siblings
  if (!all("parent_hash" %in% names(ped))) {
    ped <- ped |>
      dplyr::mutate(
        parent_hash = symKey(.data$momID, .data$dadID),
        couple_hash = symKey(.data$personID, .data$spouseID)
      ) |>
      dplyr::mutate(
        parent_hash = gsub("NA.NA", NA, .data$parent_hash),
        couple_hash = gsub("NA.NA", NA, .data$couple_hash)
      )
  }

  # If duplicated appearances exist, resolve which connections to keep
  if (sum(ped$extra) > 0) {
    full_extra <- processExtras(ped, config = config)

    ped <- full_extra$ped |> unique()
  } else {
    ped <- ped |>
      dplyr::mutate(
        coreID = .data$personID
      )
  }
  connections <- dplyr::select(
    .data = ped,
    "personID",
    "x_pos", "y_pos",
    "dadID", "momID", "parent_hash", "couple_hash",
    "spouseID",
    "famID",
    "extra"
  ) |> unique()

  # no duplications, so just use the same connections
  connections_for_sibs <- connections_for_spouses <- connections_for_dads <- connections_for_moms <- connections


  connections <- connections |>
    dplyr::mutate(
      link_as_mom = TRUE,
      link_as_dad = TRUE,
      link_as_spouse = TRUE,
      link_as_sibling = TRUE
    )





  # Get mom's coordinates
  mom_connections <- getRelativeCoordinates(
    ped = ped,
    connections = connections_for_moms,
    relativeIDvar = "momID",
    x_name = "x_mom",
    y_name = "y_mom"
  )

  # Get dad's coordinates
  dad_connections <- getRelativeCoordinates(
    ped = ped,
    connections = connections_for_dads,
    relativeIDvar = "dadID",
    x_name = "x_dad",
    y_name = "y_dad"
  )

  # Get spouse coordinates
  spouse_connections <- ped |>
    dplyr::select(
      "personID", "x_pos",
      "y_pos", "spouseID", "couple_hash"
    ) |>
    dplyr::left_join(connections_for_spouses,
      by = c("spouseID" = "personID"),
      suffix = c("", "_spouse"),
      multiple = "all"
    ) |>
    dplyr::rename(
      x_spouse = "x_pos_spouse",
      y_spouse = "y_pos_spouse"
    ) |>
    dplyr::select(
      "personID", "spouseID",
      "x_spouse", "y_spouse", "couple_hash"
    ) |>
    unique()

  # Combine mom, dad, and spouse coordinates
  connections <- connections |>
    dplyr::left_join(mom_connections,
      by = c("personID", "momID")
    ) |>
    dplyr::left_join(dad_connections,
      by = c("personID", "dadID")
    ) |>
    dplyr::left_join(spouse_connections,
      by = c("personID", "spouseID", "couple_hash")
    ) |>
    unique()

  # Calculate midpoints between mom and dad in child row

  parent_midpoints <- connections |>
    dplyr::filter(.data$link_as_sibling &
      !is.na(.data$dadID) & !is.na(.data$momID)) |>
    dplyr::group_by(.data$parent_hash) |>
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
    ) |>
    unique()

  # Calculate midpoints between spouses
  spouse_midpoints <- connections |>
    dplyr::filter(
      .data$link_as_spouse,
      !is.na(.data$spouseID)
    ) |>
    dplyr::group_by(.data$spouseID, .data$couple_hash) |>
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
    ) |>
    unique()

  # Calculate sibling group midpoints
  sibling_midpoints <- connections |>
    dplyr::filter(
      .data$link_as_sibling,
      !is.na(.data$momID) & !is.na(.data$dadID) & # biological parents defined
        !is.na(.data$x_mom) & !is.na(.data$y_mom) & # mom’s coordinates linked
        !is.na(.data$x_dad) & !is.na(.data$y_dad) # dad’s coordinates linked
    ) |>
    dplyr::group_by(
      .data$parent_hash,
      .data$x_mom, .data$y_mom,
      .data$x_dad, .data$y_dad
    ) |>
    dplyr::summarize(
      x_mid_sib = mean(.data$x_pos),
      y_mid_sib = dplyr::first(.data$y_pos),
      .groups = "drop"
    ) |>
    unique()

  # print(parent_midpoints)
  # Merge midpoints into connections
  connections <- connections |>
    dplyr::left_join(parent_midpoints,
      by = c("parent_hash")
    ) |>
    dplyr::left_join(spouse_midpoints,
      by = c("spouseID", "couple_hash")
    ) |>
    dplyr::left_join(sibling_midpoints,
      by = c(
        "parent_hash", "x_mom", "y_mom",
        "x_dad", "y_dad"
      )
    ) |>
    dplyr::mutate(
      x_mid_sib = dplyr::case_when(
        is.na(.data$x_dad) & is.na(.data$x_mom) ~ NA_real_,
        !is.na(.data$x_mid_sib) ~ .data$x_mid_sib,
        (!is.na(.data$momID) & !is.na(.data$x_mom)) | (!is.na(.data$dadID) & !is.na(.data$x_dad)) ~ .data$x_pos,
        TRUE ~ NA_real_
      ),
      y_mid_sib = dplyr::case_when(
        is.na(.data$y_dad) & is.na(.data$y_mom) ~ NA_real_,
        !is.na(.data$y_mid_sib) ~ .data$y_mid_sib,
        (!is.na(.data$momID) & !is.na(.data$y_mom)) | (!is.na(.data$dadID) & !is.na(.data$y_dad)) ~ .data$y_pos,
        TRUE ~ NA_real_
      )
    ) |>
    unique() |>
    dplyr::mutate(
      x_mid_sib = dplyr::if_else(.data$link_as_sibling, .data$x_mid_sib, NA_real_),
      y_mid_sib = dplyr::if_else(.data$link_as_sibling, .data$y_mid_sib, NA_real_)
    )

  if (exists("full_extra")) {
    plot_connections <- list(
      connections = connections,
      self_coords = full_extra$self_coords,
      connections_spouse_segment = build_connections_spouse_segment(
        ped = ped,
        connections_for_FOO = connections_for_spouses
      )
    )
  } else {
    plot_connections <- list(
      connections = connections,
      self_coords = FALSE,
      connections_spouse_segment = build_connections_spouse_segment(
        ped = ped,
        connections_for_FOO = connections_for_spouses
      )
    )
  }
  return(plot_connections)
}


build_connections_spouse_segment <- function(ped, connections_for_FOO, use_hash = TRUE) {
  if (use_hash == TRUE) {
    # I want to make segments for each hash, because some people have multiple spouses
    # this is to add those missing segments
    parent_hash_connections <- ped |>
      dplyr::select("parent_hash") |>
      dplyr::mutate(
        parent1 = # needs to be the first part of the string
          stringr::str_extract(.data$parent_hash, "^[^.]+"),
        parent2 = # needs to be the second part of the string\
          stringr::str_extract(.data$parent_hash, "(?<=\\.)[^.]+")
      ) |>
      dplyr::left_join(
        connections_for_FOO |>
          dplyr::mutate(personID = paste0(.data$personID)),
        by = c("parent1" = "personID"),
        suffix = c("", "_parent1"),
        multiple = "any"
      ) |>
      dplyr::left_join(
        connections_for_FOO |>
          dplyr::mutate(personID = paste0(.data$personID)),
        by = c("parent2" = "personID"),
        suffix = c("", "_parent2"),
        multiple = "any"
      ) |>
      dplyr::mutate(
        x_start = .data$x_pos,
        x_end = .data$x_pos_parent2,
        y_start = .data$y_pos,
        y_end = .data$y_pos_parent2
      ) |>
      dplyr::select(
        -"parent_hash",
        -"parent1",
        -"parent2",
        -"x_pos",
        -"y_pos",
        -"x_pos_parent2",
        -"y_pos_parent2"
      )



    # Get spouse coordinates
  } else {
    # spouses
    # Get spouse coordinates
    spouse_connections <- ped |>
      dplyr::select(
        "personID", "x_pos",
        "y_pos", "spouseID"
      ) |>
      dplyr::filter(!is.na(.data$spouseID)) |>
      dplyr::left_join(connections_for_FOO,
        by = c("spouseID" = "personID"),
        suffix = c("", "_spouse"),
        multiple = "any"
      ) |>
      dplyr::rename(
        x_spouse = "x_pos_spouse",
        y_spouse = "y_pos_spouse"
      ) |>
      unique() |>
      dplyr::mutate(
        x_start = .data$x_spouse,
        x_end = .data$x_pos,
        y_start = .data$y_spouse,
        y_end = .data$y_pos
      ) |>
      dplyr::select(
        -"spouseID_spouse"
      )
  }
  return(parent_hash_connections)
}
