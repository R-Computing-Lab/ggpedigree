#' Calculate connections for a pedigree dataset
#'
#' Computes graphical connection paths for a pedigree layout, including parent-child,
#' sibling, and spousal connections. Optionally processes duplicate appearances
#' of individuals (marked as `extra`) to ensure relational accuracy.
#'
#' @inheritParams  ggPedigree
#' @param config List of configuration parameters. Currently unused but passed through to internal helpers.
#' @return A `data.frame` containing connection points and midpoints for graphical rendering. Includes:
#'   \itemize{
#'     \item `x_pos`, `y_pos`: positions of focal individual
#'     \item `x_dad`, `y_dad`, `x_mom`, `y_mom`: parental positions (if available)
#'     \item `x_spouse`, `y_spouse`: spousal positions (if available)
#'     \item `x_mid_parent`, `y_mid_parent`: midpoint between parents
#'     \item `x_mid_sib`, `y_mid_sib`: sibling group midpoint
#'     \item `x_mid_spouse`, `y_mid_spouse`: midpoint between spouses
#'   }
#'
#' @export

calculateConnections <- function(ped,
                                 config = list(),
                                 spouseID = "spouseID",
                                 personID = "personID",
                                 momID = "momID",
                                 famID = "famID",
                                 twinID = "twinID",
                                 dadID = "dadID") {
  # Check inputs -----------------------------------------------------------
  if (!inherits(ped, "data.frame")) {
    stop("ped should be a data.frame or inherit to a data.frame")
  }
  if (!all(c(personID, "x_pos", "y_pos", dadID, momID) %in% names(ped))) {
    stop("ped must contain personID, x_pos, y_pos, dadID, and momID columns")
  }

  # Default configuration placeholder
  default_config <- list(
    debug = FALSE,
    return_mid_parent = FALSE
  )
  config <- utils::modifyList(default_config, config)


  # rename columns to match expected names
  names(ped)[names(ped) == personID] <- "personID"
  names(ped)[names(ped) == momID] <- "momID"
  names(ped)[names(ped) == dadID] <- "dadID"
  if (!is.null(twinID) && twinID %in% names(ped)) {
    names(ped)[names(ped) == twinID] <- "twinID"
  }
  # Capture type-safe NAs for each ID column
  na_person <- ped$personID[NA_integer_]
  if (is.factor(na_person)) {
    na_person <- factor(NA, levels = levels(ped$personID))
  } else if (is.character(na_person)) {
    na_person <- as.character(NA)
  } else if (is.integer(na_person)) {
    na_person <- as.integer(NA)
  } else if (is.numeric(na_person)) {
    na_person <- as.numeric(NA)
  } else {
    na_person <- NA
  }
  # Add spouseID if missing
  if (!all(spouseID %in% names(ped))) {
    # make it match the personID type
    # Initialize spouseID with NA of the same type as personID

    ped$spouseID <- na_person
    # Attempt to infer spouse based on parenthood (not always reliable)
    # this will give you the mom that is the spouse of the dad
    # ped$spouseID <- ped$momID[match(ped$personID, ped$dadID)]
    # this will give you the dad that is the spouse of the mom
    # ped$spouseID <- ped$dadID[match(ped$personID, ped$momID)]

    ped$spouseID <- ifelse(!is.na(ped$momID[match(ped$personID, ped$dadID)]),
      ped$momID[match(ped$personID, ped$dadID)],
      ped$dadID[match(ped$personID, ped$momID)]
    )

    # Ensure class matches personID exactly (in case factor, character, etc.)
    # class(ped$spouseID) <- class(ped$personID)

    #  assign("DEBUG_ped", ped, envir = .GlobalEnv)
  } else {
    # rename spouseID to match
    names(ped)[names(ped) == spouseID] <- "spouseID"
  }
  # Add famID if missing (used for grouping)
  if (!all(famID %in% names(ped))) {
    ped$famID <- 1
  } else {
    # rename famID to match
    names(ped)[names(ped) == famID] <- "famID"
  }

  # create a unique parent_hash for each individual
  # this will be used to identify siblings
  if (!all("parent_hash" %in% names(ped))) {
    ped <- ped |>
      unique() |>
      dplyr::mutate(
        parent_hash = .makeSymmetricKey(.data$momID, .data$dadID),
        couple_hash = .makeSymmetricKey(.data$personID, .data$spouseID)
      ) |>
      dplyr::mutate(
        parent_hash = gsub("NA.NA", NA_character_, .data$parent_hash),
        couple_hash = gsub("NA.NA", NA_character_, .data$couple_hash)
      )
  }

  # If duplicated appearances exist, resolve which connections to keep
  if (sum(ped$extra) > 0) {
    full_extra <- processExtras(ped, config = config)

    ped <- unique(full_extra$ped)
  } else {
    ped <- ped |>
      dplyr::mutate(
        coreID = .data$personID
      )
  }

  select_vars <- c(
    "personID", "x_pos", "y_pos", "dadID", "momID",
    "x_fam", "y_fam", "parent_hash", "couple_hash",
    "spouseID", "famID", "extra"
  )

  if ("twinID" %in% names(ped) && any(!is.na(ped$twinID))) {
    select_vars <- c(select_vars, "twinID")
  }
  if ("zygosity" %in% names(ped)) {
    select_vars <- c(select_vars, "zygosity")
  }

  connections <- dplyr::select(ped, dplyr::all_of(select_vars)) |> unique()


  # no duplication, so just use the same connections
  connections_skinny <- connections

  connections <- connections |>
    dplyr::mutate(
      link_as_spouse = TRUE,
      link_as_sibling = !is.na(.data$x_fam),
      link_as_twin = FALSE
    )

  if ("twinID" %in% names(ped) && any(!is.na(ped$twinID))) {
    connections <- connections |>
      dplyr::mutate(
        link_as_twin = !is.na(.data$twinID) & .data$link_as_sibling
      )
  }

  # Get mom's coordinates
  mom_connections <- getRelativeCoordinates(
    ped = ped,
    connections = connections_skinny,
    relativeIDvar = "momID",
    x_name = "x_mom",
    y_name = "y_mom"
  )

  # Get dad's coordinates
  dad_connections <- getRelativeCoordinates(
    ped = ped,
    connections = connections_skinny,
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
    dplyr::left_join(connections_skinny,
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
    unique() |>
    dplyr::left_join(mom_connections,
      by = c("personID", "momID")
    ) |>
    unique() |>
    dplyr::left_join(dad_connections,
      by = c("personID", "dadID")
    ) |>
    unique() |>
    dplyr::left_join(spouse_connections,
      by = c("personID", "spouseID", "couple_hash")
    ) |>
    unique()

  # Calculate midpoints between mom and dad in child row
  if (config$return_mid_parent == TRUE) {
    parent_midpoints <- connections |>
      dplyr::filter(.data$link_as_sibling &
        !is.na(.data$dadID) & !is.na(.data$momID)) |>
      #  unique() |>
      dplyr::group_by(.data$parent_hash) |>
      dplyr::summarize(
        x_mid_parent = mean(c(
          dplyr::first(.data$x_dad, na_rm = TRUE),
          dplyr::first(.data$x_mom, na_rm = TRUE)
        )),
        y_mid_parent = mean(c(
          dplyr::first(.data$y_dad, na_rm = TRUE),
          dplyr::first(.data$y_mom, na_rm = TRUE)
        )),
        .groups = "drop"
      )
  }
  # Calculate midpoints between spouses
  spouse_midpoints <- connections |>
    dplyr::filter(
      .data$link_as_spouse,
      !is.na(.data$spouseID)
    ) |>
    #  unique() |>
    dplyr::group_by(.data$spouseID, .data$couple_hash) |>
    dplyr::summarize(
      x_mid_spouse = mean(c(
        dplyr::first(.data$x_pos, na_rm = TRUE),
        dplyr::first(.data$x_spouse, na_rm = TRUE)
      )),
      y_mid_spouse = mean(c(
        dplyr::first(.data$y_pos, na_rm = TRUE),
        dplyr::first(.data$y_spouse, na_rm = TRUE)
      )),
      .groups = "drop"
    ) # |> unique()

  # Calculate sibling group midpoints
  sibling_midpoints <- connections |>
    dplyr::filter(
      .data$link_as_sibling,
      !is.na(.data$momID) & !is.na(.data$dadID) & # biological parents defined
        !is.na(.data$x_mom) & !is.na(.data$y_mom) & # mom’s coordinates linked
        !is.na(.data$x_dad) & !is.na(.data$y_dad) & # dad’s coordinates linked
        !is.na(.data$x_fam)
    ) |>
    #   unique() |>
    dplyr::group_by(
      .data$parent_hash,
      .data$x_mom, .data$y_mom,
      .data$x_dad, .data$y_dad
    ) |>
    dplyr::summarize(
      x_mid_sib = mean(.data$x_pos),
      y_mid_sib = dplyr::first(.data$y_pos, na_rm = TRUE),
      .groups = "drop"
    ) #|> unique()


  if (config$return_mid_parent == TRUE) {
    # print(parent_midpoints)
    # Merge midpoints into connections
    connections <- connections |>
      dplyr::left_join(parent_midpoints,
        by = c("parent_hash")
      ) |>
      unique()
  }
  connections <- connections |>
    dplyr::left_join(spouse_midpoints,
      by = c("spouseID", "couple_hash")
    ) |>
    unique() |>
    dplyr::left_join(sibling_midpoints,
      by = c(
        "parent_hash", "x_mom", "y_mom",
        "x_dad", "y_dad"
      )
    ) |>
    unique() |> # should reduce filesize
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
    dplyr::mutate(
      x_mid_sib = dplyr::if_else(.data$link_as_sibling, .data$x_mid_sib, NA_real_),
      y_mid_sib = dplyr::if_else(.data$link_as_sibling, .data$y_mid_sib, NA_real_)
    )

  if (exists("full_extra") && !is.null(full_extra$self_coords)) {
    plot_connections <- list(
      connections = connections,
      self_coords = full_extra$self_coords
    )
  } else {
    plot_connections <- list(
      connections = connections,
      self_coords = FALSE
    )
  }

  # Add twin connections if available
  if ("twinID" %in% names(ped) && any(!is.na(ped$twinID))) {
    plot_connections$twin_coords <- buildTwinSegments(
      ped = ped,
      connections_for_FOO = connections_skinny
    )
  } else {
    plot_connections$twin_coords <- FALSE
  }
  #  assign("DEBUG_plot_connections", plot_connections, envir = .GlobalEnv)
  return(plot_connections)
}

#' Build spouse segments
#'
#' @inheritParams calculateConnections
#' @param connections_for_FOO A data frame containing the connections for the spouse segments from parent connections
#' @param use_hash Logical. If TRUE, use the parent_hash to build segments. If FALSE, use the spouseID.
#' @return A data frame with the spouse segments
#' @keywords internal
#'
#'
buildSpouseSegments <- function(ped, connections_for_FOO, use_hash = TRUE) {
  if (use_hash == TRUE) {
    # I want to make segments for each hash, because some people have multiple spouses
    # this is to add those missing segments
    # do not filter for uniques because that seems to break things 😭
    parent_connections <- ped |>
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
      # unique()|> NOPE
      dplyr::left_join(
        connections_for_FOO |>
          dplyr::mutate(personID = paste0(.data$personID)),
        by = c("parent2" = "personID"),
        suffix = c("", "_parent2"),
        multiple = "any"
      ) |>
      #   unique()|> NOPE
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
  } else {
    # spouses
    # Get spouse coordinates
    parent_connections <- ped |>
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
      #   unique() |> NOPE
      dplyr::rename(
        x_spouse = "x_pos_spouse",
        y_spouse = "y_pos_spouse"
      ) |>
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
  return(parent_connections)
}

buildTwinSegments <- function(ped, connections_for_FOO) {
  # Get twin coordinates
  if (!"twinID" %in% names(ped)) {
    stop("ped must contain twinID column to build twin segments")
  }
  if (!all(c("x_pos", "y_pos") %in% names(ped))) {
    stop("ped must contain x_pos and y_pos columns to build twin segments")
  }
  if (!"zygosity" %in% names(ped)) {
    ped$zygosity <- NA_character_
  }

  twin_connections <- ped |>
    dplyr::filter(!is.na(.data$twinID)) |>
    dplyr::mutate(
      mz = ifelse(stringr::str_to_lower(.data$zygosity) %in% c("mz", "monozygotic", "identical"), TRUE, FALSE),
    ) |>
    dplyr::select(
      "personID", "x_pos",
      "y_pos", "twinID", "mz"
    ) |>
    dplyr::left_join(connections_for_FOO,
      by = c("twinID" = "personID"),
      suffix = c("", "_twin"),
      multiple = "all"
    ) |>
    #    unique() |> NOPE
    dplyr::rename(
      x_twin = "x_pos_twin",
      y_twin = "y_pos_twin"
    ) |>
    dplyr::mutate(
      x_mid_twin = (.data$x_pos + .data$x_twin) / 2,
      y_mid_twin = (.data$y_pos + .data$y_twin) / 2
    )
  return(twin_connections)
}
