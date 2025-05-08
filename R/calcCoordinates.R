#' Calculate x and y coordinates for plotting a pedigree

#' @param ped a pedigree dataset.  Needs ID, momID, and dadID columns
#' @param personID character.  Name of the column in ped for the person ID variable
#' @param momID character.  Name of the column in ped for the mother ID variable
#' @param dadID character.  Name of the column in ped for the father ID variable
#' @param generation character.  Name of the column in ped the generation variable
#' @param spouseID character.  Name of the column in ped for the spouse ID variable
#' @param sexVar character.  Name of the column in ped for the sex variable
#' @param code_male character.  Value in sexVar that corresponds

#' @return a data.frame with x and y coordinates for each person in the pedigree
#'
#'
calculateCoordinates <- function(ped, personID = "ID", momID = "momID",
                                 dadID = "dadID",
                                 spouseID = "spouseID", sexVar = "sex",
                                 code_male = NULL,
                                 generation = NULL,
                                 config = list()) {
  if (!inherits(ped, "data.frame")) stop("ped should be a data.frame or inherit to a data.frame")
  if (!all(c(personID, momID, dadID) %in% names(ped))) {
    stop("At least one of the following needed ID variables were not found: personID, momID, dadID")
  }

  # default config
  default_config <- list(
    ped_packed = TRUE,
     ped_align = TRUE,
     ped_width = 15
  )

  # Add fill in default_config values to config if config doesn't already have them

  config <- utils::modifyList(default_config, config)


  ped_recode <- BGmisc::recodeSex(ped, code_male = code_male)
  # Initialize alignment data structure
  ped_ped <- kinship2::pedigree(
    id = ped[[personID]],
    dadid = ped[[dadID]],
    momid = ped[[momID]],
    sex = ped_recode[[sexVar]],
  )

  pos <- kinship2::align.pedigree(ped_ped, packed = config$ped_packed,
                                  align =  config$ped_align,
                                  width = config$ped_width)

  # extract the nid and pos matrices from the pos object
  nid_vector <- as.vector(pos$nid)
  nid_vector <- nid_vector[nid_vector != 0]

  # Flatten the pos$pos matrix
  pos_vector <- as.vector(pos$pos)

  # Ensure ped_ped is correctly structured


  # Initialize new columns with NA values
  ped$nid <- NA
  ped$x_pos <- NA
  ped$x_order <- NA
  ped$y_order <- NA


  # Get all nid positions once
  nid_pos <- which(pos$nid != 0, arr.ind = TRUE)
  # Initialize coordinate vectors
  x_coords <- rep(NA, length(nid_vector))
  y_coords <- rep(NA, length(nid_vector))
  x_pos <- rep(NA, length(nid_vector))

  # Populate coordinate vectors
  for (i in seq_along(nid_vector)) {
    y_coords[i] <- nid_pos[i, "row"]
    x_coords[i] <- nid_pos[i, "col"]
    x_pos[i] <- pos$pos[nid_pos[i, "row"], nid_pos[i, "col"]]
  }


  # First appearance: assign as before

  # Create a mapping from nid_vector to ped_ped$id
  tmp <- match(1:length(ped_ped$id), nid_vector)

  # Fill the nid, pos, x, and y columns in ped_ped based on the mapping
  ped$nid <- nid_vector[tmp]
  ped$x_order <- x_coords[tmp]
  ped$y_order <- y_coords[tmp]
  ped$x_pos <- x_pos[tmp]
  ped$y_pos <- y_coords[tmp]


  # ---- NEW: find extra appearances and build a separate data frame ----

  # For each nid, count how many times it appears
  appearance_counts <- table(nid_vector)

  # Find which nids have duplicates
  duplicate_nids <- as.integer(names(appearance_counts[appearance_counts > 1]))

  # Initialize list to collect extra rows
  extra_rows <- list()

  # Go through all appearances
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


  # Create a separate data frame for extra appearances
  if (length(extra_rows) > 0) {
    ped_extra <- do.call(rbind, extra_rows)
    ped$extra <- FALSE
    ped_extra$extra <- TRUE

    ped <- rbind(ped, ped_extra)

  } else {
    ped_extra <- NULL
  }

  return(ped)
}


#### to do. Add spouseID to the mix, and determine better way to make sure spouses are nearby
#' Calculate connections for a pedigree dataset
#' @param ped a pedigree dataset.  Needs personID, momID, and dadID columns
#' @param type character.  Type of connections to calculate, either "siblings" or "parent-child"
#' @return a data.frame with connections between individuals based on parent-child relationships
#'
calculateConnections <- function(ped,
                                 type = c("siblings", "parent-child", "spouses"),
                                 config = list()
                                 ) {
  # Check inputs -----------------------------------------------------------
  if (!inherits(ped, "data.frame")) stop("ped should be a data.frame or inherit to a data.frame")
  if (!all(c("personID", "x_pos", "y_pos", "dadID", "momID") %in% names(ped))) {
    stop("ped must contain personID, x_pos, y_pos, dadID, and momID columns")
  }
  # default config
  default_config <- list(
  )

  # Add fill in default_config values to config if config doesn't already have them

  config <- utils::modifyList(default_config, config)


  # Generate spouseID if missing ------------------------------------------

  if (!all("spouseID" %in% names(ped))) {
    ped$spouseID <- NA
    # this will give you the mom that is the spouse of the dad
   # ped$spouseID <- ped$momID[match(ped$personID, ped$dadID)]
    # this will give you the dad that is the spouse of the mom
   # ped$spouseID <- ped$dadID[match(ped$personID, ped$momID)]

    ped$spouseID <- ifelse(!is.na(ped$momID[match(ped$personID, ped$dadID)]),
                           ped$momID[match(ped$personID, ped$dadID)],
                           ped$dadID[match(ped$personID, ped$momID)])

  }

  if (!all("famID" %in% names(ped))) {
    ped$famID <- 1
  }

if("extra" %in% names(ped)){

  # Find all individuals with extra appearances
  idsextras <- dplyr::filter(ped, .data$extra == TRUE) |>
    dplyr::select(.data$personID)

  # Remove duplicates
  idsextras <- idsextras$personID |>
                  as.vector() |> unique()

 # add unqiue ID so we can restore them
  ped$newID <- 1:nrow(ped)


# determine who each is closest too

  extras <- dplyr::filter(ped, .data$personID %in% idsextras) %>%
    dplyr::select(
    .data$newID,
    .data$personID,
    .data$x_pos, .data$y_pos,
    .data$dadID, .data$momID,
    .data$spouseID
  )


  # step one is find mom and dad's coordinates
  # Get mom, dad, spouse coordinates using the general function
  mom_coords <- getRelativeCoordinates(
    ped = ped,
    connections = extras,
    relativeIDvar = "momID",
    x_name = "x_mom",
    y_name = "y_mom",
    multiple = "any"
  )


  dad_coords <- getRelativeCoordinates(
    ped = ped,
    connections = extras,
    relativeIDvar = "dadID",
    x_name = "x_dad",
    y_name = "y_dad",
    multiple = "any"
  )


  spouse_coords <- getRelativeCoordinates(
    ped = ped,
    connections = extras,
    relativeIDvar = "spouseID",
    x_name = "x_spouse",
    y_name = "y_spouse",
    multiple = "any"
  )


  # Merge mom, dad, spouse coordinates
  extras <- extras |>
    dplyr::left_join(mom_coords, by = c("newID","personID", "momID")) |>
    dplyr::left_join(dad_coords, by = c("newID","personID", "dadID")) |>
    dplyr::left_join(spouse_coords, by = c("newID","personID", "spouseID"),
                     multiple = "any"
                     )




  # Calculate distances to mom, dad, spouse
  extras <- extras |>
    dplyr::mutate(
      dist_mom = sqrt((.data$x_pos - .data$x_mom)^2 + (.data$y_pos - .data$y_mom)^2),
      dist_dad = sqrt((.data$x_pos - .data$x_dad)^2 + (.data$y_pos - .data$y_dad)^2),
      dist_spouse = sqrt((.data$x_pos - .data$x_spouse)^2 + (.data$y_pos - .data$y_spouse)^2)
    )
  # Find the closest relative
  extras <- extras |>
    dplyr::mutate(
      closest_relative = dplyr::case_when(
        .data$dist_mom <= .data$dist_dad & .data$dist_mom <= .data$dist_spouse ~ "mom",
        .data$dist_dad < .data$dist_mom & .data$dist_dad <= .data$dist_spouse ~ "dad",
        TRUE ~ "spouse"
      )
    )

  # remove spouseID if it isn't the closest relative
#  extras <- extras |>
#    dplyr::mutate(
#      spouseID = dplyr::case_when(
#        .data$closest_relative == "spouse" ~ .data$spouseID,
#        TRUE ~  NA_real_
#      ),
#      momID = dplyr::case_when(
#        .data$closest_relative == "spouse" ~ NA_real_,
#        TRUE ~ .data$momID
#      ),
#      dadID = dplyr::case_when(
#        .data$closest_relative == "spouse" ~ NA_real_,
#        TRUE ~ .data$dadID
#      )
#    )


 skinnyextras <- extras|>
    dplyr::select(.data$newID,
                  .data$closest_relative)

  # now return the new connections to ped, no. these need to replace the old ones,
  # joining will not work because they will restore the mom and dad identifiers that we've removed



   ped <- ped |>
    dplyr::left_join(skinnyextras,
      by = c("newID"),  suffix = c("", "_"), relationship = "one-to-one"
    ) |>  dplyr::mutate(
      spouseID = dplyr::case_when(
        .data$closest_relative == "spouse" ~ .data$spouseID,
        is.na(.data$closest_relative) ~ .data$spouseID,
        TRUE ~  NA_real_
      ),
      momID = dplyr::case_when(
        .data$closest_relative == "spouse" ~ NA_real_,
        is.na(.data$closest_relative) ~ .data$momID,
        TRUE ~ .data$momID
      ),
      dadID = dplyr::case_when(
        .data$closest_relative == "spouse" ~ NA_real_,
        is.na(.data$closest_relative) ~ .data$dadID,
        TRUE ~ .data$dadID
      )
    ) |>  dplyr::select(-.data$newID,
                        -.data$extra,
                        -.data$closest_relative)

  }


  # Base data frame used for joins ----------------------------------------
  connections <- dplyr::select(
    .data = ped,
    .data$personID,
    .data$x_pos, .data$y_pos,
    .data$dadID, .data$momID,
    .data$spouseID,
    .data$famID
  )
#print(connections)
  # Separate mom coordinates ----------------------------------------------

  mom_connections <- getRelativeCoordinates(
    ped = ped,
    connections = connections,
    relativeIDvar = "momID",
    x_name = "x_mom",
    y_name = "y_mom"
  )

  # Separate dad coordinates ----------------------------------------------
  dad_connections <- getRelativeCoordinates(
    ped = ped,
    connections = connections,
    relativeIDvar = "dadID",
    x_name = "x_dad",
    y_name = "y_dad"
  )

  spouse_connections <- ped |>
    dplyr::select(
      .data$personID, .data$x_pos,
      .data$y_pos, .data$spouseID
    ) |>
    dplyr::left_join(ped,
      by = c("spouseID" = "personID"),
      suffix = c("", "_spouse"),
      multiple = "any"
    ) |>
    dplyr::rename(
      x_spouse = .data$x_pos_spouse,
      y_spouse = .data$y_pos_spouse
    ) |>
    dplyr::select(
      .data$personID, .data$spouseID,
      .data$x_spouse, .data$y_spouse
    )

  # Combine mom and dad connections with the original dataset
  connections <- connections |>
    dplyr::left_join(mom_connections,
      by = c("personID", "momID")
    ) |>
    dplyr::left_join(dad_connections,
      by = c("personID", "dadID")
    ) |>
    dplyr::left_join(spouse_connections,
      by = c("personID", "spouseID")
    )

  # Create midpoints for parents
  parent_midpoints <- connections |>
    dplyr::filter(!is.na(.data$dadID) & !is.na(.data$momID)) |>
    dplyr::group_by(.data$dadID, .data$momID) |>
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
    )

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
    )

  # Calculate midpoints for siblings
  sibling_midpoints <- connections |>
    dplyr::filter(!is.na(.data$dadID) & !is.na(.data$momID)) |>
    dplyr::group_by(
      .data$dadID,
      .data$momID
    ) |>
    dplyr::summarize(
      x_mid_sib = mean(.data$x_pos),
      y_mid_sib = dplyr::first(.data$y_pos),
      .groups = "drop"
    )


  # Merge midpoints back to connections
  connections <- connections |>
    dplyr::left_join(parent_midpoints,
      by = c("dadID", "momID")
    ) |>
    dplyr::left_join(spouse_midpoints,
      by = c("spouseID")
    ) |>
    dplyr::left_join(sibling_midpoints,
      by = c("dadID", "momID")
    ) |>
    dplyr::mutate(
      x_mid_sib = dplyr::case_when(
        is.na(.data$x_mid_sib) & !is.na(.data$dadID) & !is.na(.data$momID) ~ .data$x_pos,
        !is.na(.data$x_mid_sib) ~ .data$x_mid_sib,
        TRUE ~ NA_real_
      ),
      y_mid_sib = dplyr::case_when(
        is.na(.data$y_mid_sib) & !is.na(.data$dadID) & !is.na(.data$momID) ~ .data$y_pos,
        !is.na(.data$y_mid_sib) ~ .data$y_mid_sib,
        TRUE ~ NA_real_
      )
    )

  return(connections)
}


getRelativeCoordinates <- function(ped, connections, relativeIDvar, x_name, y_name,
                                 #  relationship = "one-to-one",
                                    multiple = "all") {
  rel_connections <- connections |>
    dplyr::filter(!is.na(.data[[relativeIDvar]])) |>
    dplyr::left_join(
      ped,
      by = setNames("personID", relativeIDvar),
      suffix = c("", "_rel"),
  #    relationship = relationship,
      multiple = multiple
    ) |>
    dplyr::rename(
      !!x_name := .data$x_pos_rel,
      !!y_name := .data$y_pos_rel
    )

  if("newID" %in% names(ped)){
    rel_connections <-  rel_connections   |>
      dplyr::select(
        .data$personID,
        .data$newID,
        !!relativeIDvar,
        !!x_name,
        !!y_name
      )
  } else {
    rel_connections <- rel_connections |>
      dplyr::select(
        .data$personID,
        !!relativeIDvar,
        !!x_name,
        !!y_name
      )
  }

  return(rel_connections)
}

getMidpoints <- function(data, group_vars,
                         x_vars, y_vars,
                         x_out, y_out, method = "mean",
                         require_non_missing = group_vars) {


  # Apply missing data filter if requested
  if (!is.null(require_non_missing)) {
    data <- data |>
      dplyr::filter(
        dplyr::if_all(all_of(require_non_missing), ~ !is.na(.))
      )
  }

  if(method == "mean"){
    data |>
      dplyr::group_by(across(all_of(group_vars))) |>
      dplyr::summarize(
        !!x_out := mean(c(!!!syms(x_vars)), na.rm = TRUE),
        !!y_out := mean(c(!!!syms(y_vars)), na.rm = TRUE),
        .groups = "drop"
      )
  } else if(method == "median"){
    data |>
      dplyr::group_by(across(all_of(group_vars))) |>
      dplyr::summarize(
        !!x_out := median(c(!!!syms(x_vars)), na.rm = TRUE),
        !!y_out := median(c(!!!syms(y_vars)), na.rm = TRUE),
        .groups = "drop"
      )
  } else if(method == "weighted_mean"){
    data |>
      dplyr::group_by(across(all_of(group_vars))) |>
      dplyr::summarize(
        !!x_out := weighted.mean(c(!!!syms(x_vars)), na.rm = TRUE),
        !!y_out := weighted.mean(c(!!!syms(y_vars)), na.rm = TRUE),
        .groups = "drop"
      )
  } else if(method == "first_pair"){
    data |>
      dplyr::group_by(across(all_of(group_vars))) |>
      dplyr::summarize(
        !!x_out := mean(c(
          dplyr::first(.data[[x_vars[1]]]),
          dplyr::first(.data[[x_vars[2]]])
        ), na.rm = TRUE),
        !!y_out := mean(c(
          dplyr::first(.data[[y_vars[1]]]),
          dplyr::first(.data[[y_vars[2]]])
        ), na.rm = TRUE),
        .groups = "drop"
      )
  } else if(method == "meanxfirst"){
    data |>
      dplyr::group_by(across(all_of(group_vars))) |>
      dplyr::summarize(
        !!x_out := mean(c(!!!syms(x_vars)), na.rm = TRUE),
        !!y_out := mean(c(
          dplyr::first(.data[[y_vars[1]]]),
          dplyr::first(.data[[y_vars[2]]])
        ), na.rm = TRUE),
        .groups = "drop"
      )

  } else if(method == "meanyfirst"){

    data |>
      dplyr::group_by(across(all_of(group_vars))) |>
      dplyr::summarize(
        !!x_out := mean(c(
          dplyr::first(.data[[x_vars[1]]]),
          dplyr::first(.data[[x_vars[2]]])
        ), na.rm = TRUE),
        !!y_out := mean(c(!!!syms(y_vars)), na.rm = TRUE),
        .groups = "drop"
      )
  }  else  {
    stop("Unsupported method.")
  }
}
