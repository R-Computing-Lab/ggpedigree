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

  # create a unique parenthash for each individual
  # this will be used to identify siblings
  if (!all("parenthash" %in% names(ped))) {
  ped <- ped |>
    dplyr::mutate(
      parenthash = paste0(.data$momID, ".", .data$dadID)
    ) |>
    dplyr::mutate(
      parenthash = gsub("NA.NA", NA, .data$parenthash)
    )
  }

  # If duplicated appearances exist, resolve which connections to keep
  if (sum(ped$extra) > 0) {
    ped <- processExtras(ped, config = config)
  }

  # Construct base connection frame
  # This will be used for all joins


  if ("x_otherself" %in% names(ped)) {
    connections <-  dplyr::select(
        .data = ped,
        "personID",
        "x_pos", "y_pos",
        "dadID", "momID", "parenthash",
        "spouseID",
        "famID",
        "x_otherself", "y_otherself",
        "extra","link_as_mom", "link_as_dad", "link_as_spouse",
        "link_as_sibling"
      )  |> unique()


    connections_moms <- dplyr::filter(connections, .data$link_as_mom == TRUE) |>
      dplyr::select(
        -"extra",
        -"link_as_mom",
        -"link_as_dad",
        -"link_as_spouse",
        -"link_as_sibling"
      )

    connections_dads <- dplyr::filter(connections, .data$link_as_dad == TRUE)|>
      dplyr::select(
        -"extra",
        -"link_as_mom",
        -"link_as_dad",
        -"link_as_spouse",
        -"link_as_sibling"
      )
    connections_spouses <- dplyr::filter(connections, .data$link_as_spouse == TRUE) |>
      dplyr::select(
        -"extra",
        -"link_as_mom",
        -"link_as_dad",
        -"link_as_spouse",
        -"link_as_sibling"
      )
    connections_sibs <- dplyr::filter(connections, .data$link_as_sibling == TRUE) |>
      dplyr::select(
        -"extra",
        -"link_as_mom",
        -"link_as_dad",
        -"link_as_spouse",
        -"link_as_sibling"
      )
  }  else {
    connections <- dplyr::select(
      .data = ped,
      "personID",
      "x_pos", "y_pos",
      "dadID", "momID", "parenthash",
      "spouseID",
      "famID",
      "extra"
    )  |> unique() |>
      dplyr::mutate(
        link_as_mom = TRUE,
        link_as_dad = TRUE,
        link_as_spouse = TRUE,
        link_as_sibling = TRUE
      )



# no duplications, so just use the same connections
    connections_sibs <-  connections_spouses <- connections_dads <- connections_moms <- connections
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
    )  |> unique()

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
    )  |> unique()

  # Calculate midpoints between mom and dad in child row

  parent_midpoints <- connections |>
    dplyr::filter(!is.na(.data$dadID) & !is.na(.data$momID)) |>
    dplyr::group_by(.data$parenthash) |>
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
    )  |> unique()

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
    )  |> unique()

  # Calculate sibling group midpoints
  sibling_midpoints <- connections|>
    dplyr::filter(
      !is.na(.data$momID) & !is.na(.data$dadID) &  # biological parents defined
        !is.na(.data$x_mom) & !is.na(.data$y_mom) &  # mom’s coordinates linked
        !is.na(.data$x_dad) & !is.na(.data$y_dad)    # dad’s coordinates linked
    ) |>
    dplyr::group_by(
      .data$parenthash,
      .data$x_mom, .data$y_mom,
      .data$x_dad, .data$y_dad
    ) |>
    dplyr::summarize(
      x_mid_sib = mean(.data$x_pos),
      y_mid_sib = dplyr::first(.data$y_pos),
      .groups = "drop"
    )  |> unique()


  # Merge midpoints into connections
  connections <- connections |>
    dplyr::left_join(parent_midpoints,
      by = c("parenthash")
    ) |>
    dplyr::left_join(spouse_midpoints,
      by = c("spouseID")
    ) |>
    dplyr::left_join(sibling_midpoints,
      by = c("parenthash","x_mom", "y_mom",
             "x_dad", "y_dad")
    ) |>
   dplyr::mutate(
     x_mid_sib = dplyr::case_when(
       is.na(.data$x_dad) &  is.na(.data$x_mom) ~ NA_real_,
       !is.na(.data$x_mid_sib) ~ .data$x_mid_sib,
       (!is.na(.data$momID) & !is.na(.data$x_mom)) | (!is.na(.data$dadID) & !is.na(.data$x_dad)) ~ .data$x_pos,
        TRUE ~ NA_real_
     ),
      y_mid_sib = dplyr::case_when(
        is.na(.data$y_dad) &  is.na(.data$y_mom) ~ NA_real_,

        !is.na(.data$y_mid_sib) ~ .data$y_mid_sib,
       (!is.na(.data$momID) & !is.na(.data$y_mom)) | (!is.na(.data$dadID) & !is.na(.data$y_dad)) ~ .data$y_pos,
       TRUE ~ NA_real_
     )
   )  |> unique()

  return(connections)
}





