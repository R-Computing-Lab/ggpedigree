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
#'
#' @export

calculateCoordinates <- function(ped, personID = "ID", momID = "momID",
                                 dadID = "dadID",
                                 spouseID = "spouseID", sexVar = "sex",
                                 code_male = NULL,
                                 config = list())
  {

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

  if(!is.null(config$hints)) {

#' Check if hints are provided
    autohint <-   tryCatch(kinship2::autohint(ped_ped,config$hints,
                                align = config$ped_align,
                                packed = config$ped_packed),
             error = function(e) kinship2::autohint(ped_ped,
                                        align = config$ped_align,
                                        packed = config$ped_packed)
             ,
             finally = warning("Your hints caused an error and were not used, using default hints instead"))
  } else {
    autohint <- kinship2::autohint(ped_ped,
                                   align = config$ped_align,
                                   packed = config$ped_packed)
  }



  # -----
  # Extract layout information
  # -----


  # Align pedigree for plotting
  pos <- kinship2::align.pedigree(ped_ped,
    packed = config$ped_packed,
    align = config$ped_align,
    width = config$ped_width,
    hints = autohint
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

  # A matrix with values
  # 1 = subject plotted to the immediate right is a spouse
  # 2 = subject plotted to the immediate right is an inbred spouse
  # 0 = not a spouse


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
    ped$extra <- FALSE
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





