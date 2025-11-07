# Automatically generated from all.nw using noweb
## renamed from pedBits, part of pedigree.shrink functions

#' Calculate the bit size of a pedigree
#'
#' This function calculates the bit size of a pedigree, which is a measure of
#' the information content. The bit size is calculated as 2 * (number of non-founders) -
#' (number of founders). This is used in pedigree.shrink functions.
#'
#' @param ped A pedigree object
#' @return A list containing:
#'   \item{bitSize}{The bit size of the pedigree}
#'   \item{nFounder}{The number of founders in the pedigree}
#'   \item{nNonFounder}{The number of non-founders in the pedigree}
#' @keywords internal
#' @examples
#' \dontrun{
#' # Example requires a pedigree object
#' # ped <- pedigree(id=1:5, dadid=c(0,0,1,1,1), momid=c(0,0,2,2,2),
#' #                 sex=c(1,2,1,2,1))
#' # kinship2_bitSize(ped)
#' }
kinship2_bitSize <- function(ped) {
  ## calculate bit size of a pedigree

  if(!("pedigree" %in% class(ped)))
    stop("Must be a pedigree object.\n")

  father = ped$findex
  mother = ped$mindex
  id = ped$id

  founder <- father==0 & mother==0
  pedSize <- length(father)
  nFounder <- sum(founder)
  nNonFounder <- pedSize - nFounder
  bitSize <- 2*nNonFounder - nFounder
  return(list(bitSize=bitSize,
    nFounder = nFounder,
    nNonFounder = nNonFounder))
}

