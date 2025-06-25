#' Count offspring of each individual
#'
#' @param ped A data frame containing the pedigree information
#' @param personID character.  Name of the column in ped for the person ID variable
#' @param momID character.  Name of the column in ped for the mother ID variable
#' @param dadID character.  Name of the column in ped for the father ID variable
#' @return A data frame with an additional column, offspring,
#'    that contains the number of offspring for each individual
#' @examples
#' library(BGmisc)
#' data("potter")
#' countOffspring(potter,
#'   personID = "personID",
#'   momID = "momID", dadID = "dadID"
#' )
#'
#' @export
countOffspring <- function(ped, personID = "ID", momID = "momID", dadID = "dadID") {
  if (!all(c(personID, momID, dadID) %in% names(ped))) {
    stop("At least one of the following needed ID variables were not found: personID, momID, dadID")
  }
  ped$offspring <- 0

  # ped$offspring <- sapply(ped[[personID]], function(id) {
  ped$offspring <- vapply(ped[[personID]], function(id) {
    sum(ped[[momID]] == id, na.rm = TRUE) + sum(ped[[dadID]] == id, na.rm = TRUE)
  }, integer(1))
  return(ped)
}

#' Count siblings of each individual
#'
#' @param ped A data frame containing the pedigree information
#' @param personID character.  Name of the column in ped for the person ID variable
#' @param momID character.  Name of the column in ped for the mother ID variable
#' @param dadID character.  Name of the column in ped for the father ID variable
#' @return A data frame with an additional column, siblings,
#'        that contains the number of siblings for each individual
#' @examples
#' library(BGmisc)
#' data("potter")
#' countSiblings(potter, personID = "personID")
#'
#' @export

countSiblings <- function(ped, personID = "ID", momID = "momID", dadID = "dadID") {
  if (!all(c(personID, momID, dadID) %in% names(ped))) {
    stop("At least one of the following needed ID variables were not found: personID, momID, dadID")
  }
  # Create a unique parent ID by concatenating momID and dadID

  ped$parentsID <- paste0(ped[[momID]], ".", ped[[dadID]])

  ped$parentsID[ped$parentsID == "NA.NA"] <- NA

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

#' Generate a spouselist matrix
#' @param ped A data frame containing the pedigree information
#' @param personID Character. Name of the column in ped for the person ID variable
#' @param momID Character. Name of the column in ped for the mother ID variable
#' @param dadID Character. Name of the column in ped for the father ID variable
#' @param spouseID Character. Name of the column in ped for the spouse ID variable
#' @return A spouselist matrix
#' @examples
#' library(BGmisc)
#' data("potter")
#' generateSpouseList(potter,
#'   personID = "personID",
#'   momID = "momID", dadID = "dadID", spouseID = "spouseID"
#' )
#' @export
generateSpouseList <- function(ped, personID = "personID",
                               momID = "momID", dadID = "dadID", spouseID = "spouseID") {
  spouselist <- data.frame(matrix(NA, nrow = 0, ncol = 4))
  colnames(spouselist) <- c("ID1", "ID2", "sex1", "sex2")

  unique_pairs <- unique(ped[, c(momID, dadID)])
  for (i in seq_len(nrow(unique_pairs))) {
    id1 <- unique_pairs[i, 1]
    id2 <- unique_pairs[i, 2]
    if (!is.na(id1) && !is.na(id2)) {
      sex1 <- ifelse(id1 %in% ped[[personID]], ped$sex[which(ped[[personID]] == id1)], NA)
      sex2 <- ifelse(id2 %in% ped[[personID]], ped$sex[which(ped[[personID]] == id2)], NA)
      spouselist <- rbind(spouselist, data.frame(ID1 = id1, ID2 = id2, sex1 = sex1, sex2 = sex2))
    }
  }

  return(as.matrix(spouselist))
}

#' @importFrom rlang .data
NULL

#' @importFrom stats median
NULL
