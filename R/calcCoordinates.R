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
#' @export
#'
calculateCoordinates <- function(ped, personID = "ID", momID = "momID",
                                  dadID = "dadID",
                                  spouseID = "spouseID", sexVar = "sex",
                                  code_male = NULL
) {
  if (!inherits(ped, "data.frame")) stop("ped should be a data.frame or inherit to a data.frame")
  if (!all(c(personID, momID, dadID) %in% names(ped))) {
    stop("At least one of the following needed ID variables were not found: personID, momID, dadID")
  }
  ped_recode <- BGmisc::recodeSex(ped, code_male = code_male)
  # Initialize alignment data structure
  ped_ped <-  kinship2::pedigree(
    id = ped[[personID]],
    dadid = ped[[dadID]],
    momid = ped[[momID]],
    sex = ped_recode[[sexVar]],
  )

 pos <- kinship2::align.pedigree(ped_ped, packed = TRUE, align = TRUE)

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

 # Initialize coordinate vectors
 x_coords <- rep(NA, length(nid_vector))
 y_coords <- rep(NA, length(nid_vector))
 x_pos <- rep(NA, length(nid_vector))

 # Populate coordinate vectors
 for (i in seq_along(nid_vector)) {
   index <- which(pos$nid == nid_vector[i], arr.ind = TRUE)
   y_coords[i] <- index[1]
   x_coords[i] <- index[2]
   x_pos[i] <- pos[["pos"]][index[1], index[2]]
 }

 # Create a mapping from nid_vector to ped_ped$id
 tmp <- match(1:length(ped_ped$id), nid_vector)

 # Fill the nid, pos, x, and y columns in ped_ped based on the mapping
 ped$nid <- nid_vector[tmp]
 ped$x_order <- x_coords[tmp]
 ped$y_order <- y_coords[tmp]
 ped$x_pos <- x_pos[tmp]
#ped$x_pos <- pos_vector[tmp]
 ped$y_pos <- y_coords[tmp]

  # sort by personID
#  ped <- ped[order(ped[[var_personID]]),]
  return(ped)
}
#### to do. Add spouseID to the mix, and determine better way to make sure spouses are nearby
#' Calculate connections for a pedigree dataset
#' @param ped a pedigree dataset.  Needs personID, momID, and dadID columns
#' @param type character.  Type of connections to calculate, either "siblings" or "parent-child"
#' @return a data.frame with connections between individuals based on parent-child relationships
#' @export
#'
calculateConnections <- function(ped, type = c("siblings","parent-child", "spouses")) {
  if (!inherits(ped, "data.frame")) stop("ped should be a data.frame or inherit to a data.frame")
  if (!all(c("personID", "x_pos", "y_pos", "dadID", "momID") %in% names(ped))) {
    stop("ped must contain personID, x_pos, y_pos, dadID, and momID columns")
  }
  if("spouseID" %in% names(ped) == FALSE){

    ped$spouseID <- NA
    # this will give you the mom that is the spouse of the dad
    ped$spouseID <-  ped$momID[match(ped$personID, ped$dadID)]
    # this will give you the dad that is the spouse of the mom
    ped$spouseID <-  ped$dadID[match(ped$personID, ped$momID)]
  }

  connections <- ped %>%
    select(personID, x_pos, y_pos, dadID, momID, spouseID)

  # Separate mom and dad coordinates
  mom_connections <- connections %>%
    dplyr::filter(!is.na(momID)) %>%
    left_join(ped, by = c("momID" = "personID"), suffix = c("", "_mom")) %>%
    rename(x_mom = x_pos_mom, y_mom = y_pos_mom) %>%
    select(personID, momID, x_mom, y_mom)

  dad_connections <- connections %>%
    dplyr::filter(!is.na(dadID)) %>%
    left_join(ped, by = c("dadID" = "personID"), suffix = c("", "_dad")) %>%
    rename(x_dad = x_pos_dad, y_dad = y_pos_dad) %>%
    select(personID, dadID, x_dad, y_dad)

  spouse_connections <- ped %>%
    select(personID, x_pos, y_pos, spouseID) %>%
    left_join(ped, by = c("spouseID" = "personID"), suffix = c("", "_spouse")) %>%
    rename(x_spouse = x_pos_spouse, y_spouse = y_pos_spouse) %>%
    select(personID, spouseID, x_spouse, y_spouse)

  # Combine mom and dad connections with the original dataset
  connections <- connections %>%
    left_join(mom_connections, by = join_by(personID, momID)) %>%
    left_join(dad_connections, by = join_by(personID, dadID)) %>%
    left_join(spouse_connections, by = join_by(personID, spouseID))

  # Create midpoints for parents
  parent_midpoints <- connections %>%
    dplyr::filter(!is.na(dadID) & !is.na(momID)) %>%
    group_by(dadID, momID) %>%
    summarize(
      x_midparent = mean(c(first(x_dad), first(x_mom))),
      y_midparent = mean(c(first(y_dad), first(y_mom))),
      .groups = 'drop'
    )

  spouse_midpoints <- connections %>%
    dplyr::filter(!is.na(spouseID)) %>%
    group_by(spouseID) %>%
    summarize(
      x_mid_spouse = mean(c(first(x_pos), first(x_spouse))),
      y_mid_spouse = mean(c(first(y_pos), first(y_spouse))) ,
      .groups = 'drop'
    )

  # Calculate midpoints for siblings
  sibling_midpoints <- connections %>%
    filter(!is.na(dadID) & !is.na(momID)) %>%
    group_by(dadID, momID) %>%
    summarize(
      x_mid_sib = mean(x_pos),
      y_mid_sib = first(y_pos),
      .groups = 'drop'
    )





  # Merge midpoints back to connections
  connections <- connections %>%
    left_join(parent_midpoints, by = c("dadID", "momID")) %>%
  left_join(spouse_midpoints, by = join_by(spouseID))  %>%
  left_join(sibling_midpoints, by = join_by(dadID, momID)) %>%
    mutate(
      x_mid_sib = case_when(is.na(x_mid_sib) & !is.na(dadID) & !is.na(momID) ~ x_pos,
                            !is.na(x_mid_sib) ~ x_mid_sib,
                            TRUE ~ NA_real_),
      y_mid_sib = case_when(is.na(y_mid_sib) & !is.na(dadID) & !is.na(momID) ~ y_pos,
                              !is.na(y_mid_sib) ~ y_mid_sib,
                            TRUE ~ NA_real_)
    )

  return(connections)
}


