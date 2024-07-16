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

calculateConnections <- function(ped) {
  # Create connections based on parent-child relationships
  connections <- ped %>%
    select(personID, x_pos, y_pos, dadID, momID) %>%
    gather(key = "parent_type", value = "parent_id", dadID, momID) %>%
    filter(!is.na(parent_id)) %>%
    left_join(ped %>% select(personID, x_pos, y_pos), by = c("parent_id" = "personID"),
              suffix = c("", "_end") ) %>%
    left_join(ped %>% select(personID, x_pos, y_pos), by = c("personID" = "personID"),
              suffix = c("", ".y") ) %>% rename(x_end = x_pos_end, y_end = y_pos_end) %>%
    select(personID, x_pos, y_pos, x_end, y_end, parent_id)




  # Create additional points for horizontal connections
  horizontal_connections <- connections %>%
    group_by(parent_id) %>%
    summarize(x_mid = mean(x_pos), y_mid = first(y_pos) - 0.5) %>%
    ungroup()

  # Merge horizontal connections with original connections
  connections <- connections %>%
    left_join(horizontal_connections, by = c("parent_id" = "parent_id"))

  return(connections)
}


