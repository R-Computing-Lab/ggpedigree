#' Align pedigree - Process a set of siblings
#'
#' This is an internal helper function for pedigree alignment. It processes a set
#' of siblings, ordering them according to hints and calling kinship2_alignped1
#' for each sibling. The results are merged together using kinship2_alignped3.
#'
#' @param x Integer vector of sibling IDs to process
#' @param dad Integer vector of father indices
#' @param mom Integer vector of mother indices
#' @param level Integer vector indicating the generation level of each subject
#' @param horder Numeric vector of hint order for positioning subjects
#' @param packed Logical, if TRUE uses compact packing algorithm
#' @param spouselist Matrix defining spouse relationships
#' @return A list containing the aligned pedigree structure for the sibling group:
#'   \item{nid}{Matrix of subject IDs at each level and position}
#'   \item{pos}{Matrix of horizontal positions}
#'   \item{fam}{Matrix of family indices}
#'   \item{n}{Vector of counts per level}
#'   \item{spouselist}{Updated spouse list}
#' @keywords internal
kinship2_alignped2 <- function(x, dad, mom, level, horder, packed,
                               spouselist) {
  x <- x[order(horder[x])] # Use the hints to order the sibs
  rval <- kinship2_alignped1(
    x[1], dad, mom, level, horder, packed,
    spouselist
  )
  spouselist <- rval$spouselist

  if (length(x) > 1) {
    mylev <- level[x[1]]
    for (i in 2:length(x)) {
      rval2 <- kinship2_alignped1(
        x[i], dad, mom, level,
        horder, packed, spouselist
      )
      spouselist <- rval2$spouselist

      # Deal with the unusual special case:
      if ((rval2$n[mylev] > 1) ||
        (is.na(match(x[i], floor(rval$nid[mylev, ]))))) {
        rval <- kinship2_alignped3(rval, rval2, packed)
      }
    }
    rval$spouselist <- spouselist
  }
  rval
}
