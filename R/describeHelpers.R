#' Count offspring of each individual
#'
#' @param ped A data frame containing the pedigree information
#' @param personID character.  Name of the column in ped for the person ID variable
#' @param momID character.  Name of the column in ped for the mother ID variable
#' @param dadID character.  Name of the column in ped for the father ID variable
#' @return A data frame with an additional column, offspring, that contains the number of offspring for each individual
#' @export
#'
#'
countOffspring <- function(ped, personID = "ID", momID = "momID", dadID = "dadID") {
  if (!all(c(personID, momID, dadID) %in% names(ped))) {
    stop("At least one of the following needed ID variables were not found: personID, momID, dadID")
  }
  ped$offspring <- 0
  ped$offspring <- sapply(ped[[personID]], function(id) {
    sum(ped[[momID]] == id, na.rm = TRUE) + sum(ped[[dadID]] == id, na.rm = TRUE)
  })
  return(ped)
}

#' Count siblings of each individual
#'
#' @param ped A data frame containing the pedigree information
#' @param personID character.  Name of the column in ped for the person ID variable
#' @param momID character.  Name of the column in ped for the mother ID variable
#' @param dadID character.  Name of the column in ped for the father ID variable
#' @return A data frame with an additional column, siblings, that contains the number of siblings for each individual
#' @export
#'
countSiblings <- function(ped, personID = "ID", momID = "momID", dadID = "dadID") {
  if (!all(c(personID, momID, dadID) %in% names(ped))) {
    stop("At least one of the following needed ID variables were not found: personID, momID, dadID")
  }
  # Create a unique parent ID by concatenating momID and dadID

  ped$parentsID <- paste0(ped[[momID]],".",ped[[dadID]])

  ped$parentsID[ped$parentsID=="NA.NA"] <- NA

  # Calculate sibling order and count using vectorized operations
  ped <- ped[order(ped$parentsID), ]
  rle_parentsID <- rle(ped$parentsID)
  ped$siborder <- sequence(rle_parentsID$lengths)
  ped$siblings <- rep(rle_parentsID$lengths - 1, rle_parentsID$lengths)

   # Handle cases where parent ID is missing (orphans)
  ped$siblings[is.na(ped$parentsID)] <- 0
  ped$siborder[is.na(ped$parentsID)] <- 1

  # Reorder the pedigree
  ped <- ped[order(ped[[personID]]), ]

  return(ped)
}