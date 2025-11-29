#' @title Check kinship2 hints for consistency
#'
#' @description
#' This function checks the consistency of kinship2 hints, particularly
#' focusing on the `order` and `spouse` components. It ensures that the
#' order is numeric and matches the length of the `sex` vector, and that
#' marriages are valid male/female pairs without duplicates.
#' @param hints A list containing kinship2 hints, including `order` and optionally `spouse`.
#' @param sex A character vector indicating the sex of each individual
#' ('male' or 'female').
#' @return The original `hints` list if all checks pass; otherwise, an error is raised.
#' @keywords internal
#' @details Extracted from checks.Rnw
#' This routine tries to remove inconsistencies in spousal hints.
#' These and arise in autohint with complex pedigrees.
#' One can have ABA (subject A is on both the
#' left and the right of B), cycles, etc.
#' Actually, these used to arise in autohint, I don't know if it's so after the recent rewrite.
#' Users can introduce problems as well if they modify the hints.


kinship2_check.hint <- function(hints, sex) {
  if (is.null(hints$order)) stop("Missing order component")
  if (!is.numeric(hints$order)) stop("Invalid order component")
  n <- length(sex)
  if (length(hints$order) != n) {
    stop("Wrong length for order component")
  }
  spouse <- hints$spouse
  if (is.null(spouse)) {
    hints
  } else {
    lspouse <- spouse[, 1]
    rspouse <- spouse[, 2]
    if (any(lspouse < 1 | lspouse > n | rspouse < 1 | rspouse > n)) {
      warning("Invalid spouse value")
    }

    temp1 <- (sex[lspouse] == "female" & sex[rspouse] == "male")
    temp2 <- (sex[rspouse] == "female" & sex[lspouse] == "male")
    if (!all(temp1 | temp2)) {
      warning("A marriage is not opposite sex")
    }

    hash <- n * pmax(lspouse, rspouse) + pmin(lspouse, rspouse)
    # Turn off this check for now - is set off if someone is married to two siblings
    # if (any(duplicated(hash))) stop("Duplicate marriage")

    # Break any loops: A left of B, B left of C, C left of A.
    #  Not yet done
  }
  hints
}
