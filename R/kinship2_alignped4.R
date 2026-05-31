# Automatically generated from all.nw using noweb

#' Compute optimal horizontal spacing for pedigree alignment
#'
#' This is an internal helper function for pedigree alignment. It uses quadratic
#' programming to find optimal horizontal positions for subjects that minimize
#' the distance between parents and children while keeping spouses together and
#' respecting spacing constraints. Requires the quadprog package.
#'
#' @param rval Aligned pedigree structure from previous alignment steps
#' @param spouse Logical matrix indicating spouse connections
#' @param level Integer vector of generation levels
#' @param width Numeric, maximum width of the pedigree plot
#' @param align Logical or numeric vector. If logical, uses default alignment parameters.
#'   If numeric, should be a vector c(a1, a2) where a1 controls parent-child penalties
#'   and a2 controls spouse penalties
#' @param classic Logical, if TRUE uses classic alignment method (default TRUE)
#' @return Matrix of optimized horizontal positions for each subject
#' @keywords internal
kinship2_alignped4 <- function(rval, spouse, level, width, align,
                               classic = TRUE
                               ) {
  if(classic != TRUE){
    return(kinship2_alignped4_optimized(rval=rval,
                                        spouse=spouse,
                                        level=level,
                                        width=width,
                                        align=align
                                        ))
  } else {
  ## Doc: alignped4 -part1, spacing across page
  if (is.logical(align)) align <- c(1.5, 2) # defaults
  maxlev <- nrow(rval$nid)
  width <- max(width, rval$n + .01) # width must be > the longest row

  n <- sum(rval$n) # total number of subjects
  myid <- matrix(0, maxlev, ncol(rval$nid)) # number the plotting points
  for (i in 1:maxlev) {
    myid[i, rval$nid[i, ] > 0] <- cumsum(c(0, rval$n))[i] + 1:rval$n[i]
  }

  # There will be one penalty for each spouse and one for each child
  npenal <- sum(spouse[rval$nid > 0]) + sum(rval$fam > 0)
  pmat <- matrix(0., nrow = npenal + 1, ncol = n)

  ## Doc: alignped4 -part2
  indx <- 0
  # Penalties to keep spouses close
  for (lev in 1:maxlev) {
    if (any(spouse[lev, ])) {
      who <- which(spouse[lev, ])
      indx <- max(indx) + 1:length(who)
      pmat[cbind(indx, myid[lev, who])] <- sqrt(align[2])
      pmat[cbind(indx, myid[lev, who + 1])] <- -sqrt(align[2])
    }
  }

  # Penalties to keep kids close to parents
  for (lev in (1:maxlev)[-1]) { # no parents at the top level
    families <- unique(rval$fam[lev, ])
    families <- families[families != 0] # 0 is the 'no parent' marker
    for (i in families) { # might be none
      who <- which(rval$fam[lev, ] == i)
      k <- length(who)
      indx <- max(indx) + 1:k # one penalty per child
      penalty <- sqrt(k^(-align[1]))
      pmat[cbind(indx, myid[lev, who])] <- -penalty
      pmat[cbind(indx, myid[lev - 1, rval$fam[lev, who]])] <- penalty / 2
      pmat[cbind(indx, myid[lev - 1, rval$fam[lev, who] + 1])] <- penalty / 2
    }
  }
  maxrow <- min(which(rval$n == max(rval$n)))
  pmat[nrow(pmat), myid[maxrow, 1]] <- 1e-5
  ncon <- n + maxlev # number of constraints
  cmat <- matrix(0., nrow = ncon, ncol = n)
  coff <- 0 # cumulative constraint lines so var
  dvec <- rep(1., ncon)
  for (lev in 1:maxlev) {
    nn <- rval$n[lev]
    if (nn > 1) {
      for (i in 1:(nn - 1)) {
        cmat[coff + i, myid[lev, i + 0:1]] <- c(-1, 1)
      }
    }

    cmat[coff + nn, myid[lev, 1]] <- 1 # first element >=0
    dvec[coff + nn] <- 0
    cmat[coff + nn + 1, myid[lev, nn]] <- -1 # last element <= width-1
    dvec[coff + nn + 1] <- 1 - width
    coff <- coff + nn + 1
  }

  if (requireNamespace("quadprog", quietly = TRUE)) {
    pp <- t(pmat) %*% pmat + 1e-8 * diag(ncol(pmat))
    fit <- quadprog::solve.QP(pp, rep(0., n), t(cmat), dvec)
  } else {
    stop("Need the quadprog package")
  }

  newpos <- rval$pos
  # fit <- lsei(pmat, rep(0, nrow(pmat)), G=cmat, H=dvec)
  # newpos[myid>0] <- fit$X[myid]
  newpos[myid > 0] <- fit$solution[myid]
  newpos
  }
}

#' @rdname kinship2_alignped4
kinship2_alignped4_optimized <- function(rval, spouse, level, width, align
) {

  ## Doc: alignped4 -part1, spacing across page
  if (is.logical(align)) align <- c(1.5, 2) # defaults
  maxlev <- nrow(rval$nid)
  width <- max(width, rval$n + .01) # width must be > the longest row

  n <- sum(rval$n) # total number of subjects
  myid <- matrix(0L, maxlev, ncol(rval$nid)) # number the plotting points
  offset <- cumsum(c(0L, rval$n))

  for (i in seq_len(maxlev)) {
    myid[i, rval$nid[i, ] > 0] <- offset[i] + seq_len(rval$n[i])
  }

  # There will be one penalty for each spouse and one for each child
  #
  # The original code explicitly constructed pmat and then formed
  # pp <- t(pmat) %*% pmat.  Since each penalty row has only 2 or 3
  # nonzero entries, this version accumulates pp directly.  This keeps
  # the same quadratic programming problem while avoiding the dense
  # npenal-by-n penalty matrix.
  pp <- matrix(0., nrow = n, ncol = n)

  ## Doc: alignped4 -part2
  # Penalties to keep spouses close
  spouse_penalty <- sqrt(align[2])

  for (lev in seq_len(maxlev)) {
    if (any(spouse[lev, ])) {
      who <- which(spouse[lev, ])

      for (j in who) {
        idx <- c(myid[lev, j], myid[lev, j + 1L])
        val <- c(spouse_penalty, -spouse_penalty)

        pp[idx, idx] <- pp[idx, idx] + tcrossprod(val)
      }
    }
  }

  # Penalties to keep kids close to parents
  for (lev in seq_len(maxlev)[-1]) { # no parents at the top level
    families <- unique(rval$fam[lev, ])
    families <- families[families != 0] # 0 is the 'no parent' marker

    for (i in families) { # might be none
      who <- which(rval$fam[lev, ] == i)
      k <- length(who)
      penalty <- sqrt(k^(-align[1]))

      for (j in who) {
        child <- myid[lev, j]
        parent1 <- myid[lev - 1L, rval$fam[lev, j]]
        parent2 <- myid[lev - 1L, rval$fam[lev, j] + 1L]

        idx <- c(child, parent1, parent2)
        val <- c(-penalty, penalty / 2, penalty / 2)

        pp[idx, idx] <- pp[idx, idx] + tcrossprod(val)
      }
    }
  }

  maxrow <- min(which(rval$n == max(rval$n)))
  anchor <- myid[maxrow, 1L]
  pp[anchor, anchor] <- pp[anchor, anchor] + 1e-10

  ncon <- n + maxlev # number of constraints
  cmat <- matrix(0., nrow = ncon, ncol = n)
  coff <- 0L # cumulative constraint lines so var
  dvec <- rep(1., ncon)

  for (lev in seq_len(maxlev)) {
    nn <- rval$n[lev]
    ids <- myid[lev, seq_len(nn)]

    if (nn > 1L) {
      row_idx <- coff + seq_len(nn - 1L)
      cmat[cbind(row_idx, ids[-nn])] <- -1
      cmat[cbind(row_idx, ids[-1L])] <- 1
    }

    cmat[coff + nn, ids[1L]] <- 1 # first element >=0
    dvec[coff + nn] <- 0
    cmat[coff + nn + 1L, ids[nn]] <- -1 # last element <= width-1
    dvec[coff + nn + 1L] <- 1 - width
    coff <- coff + nn + 1L
  }

  if (requireNamespace("quadprog", quietly = TRUE)) {
    pp <- pp + 1e-8 * diag(n)
    fit <- quadprog::solve.QP(pp, rep(0., n), t(cmat), dvec)
  } else {
    stop("Need the quadprog package")
  }

  newpos <- rval$pos
  # fit <- lsei(pmat, rep(0, nrow(pmat)), G=cmat, H=dvec)
  # newpos[myid>0] <- fit$X[myid]
  newpos[myid > 0] <- fit$solution[myid]
  newpos
}
