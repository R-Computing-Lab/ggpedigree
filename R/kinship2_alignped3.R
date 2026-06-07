# Automatically generated from all.nw using noweb

#' Merge two aligned pedigree structures
#'
#' This is an internal helper function for pedigree alignment. It takes two
#' previously aligned pedigree structures (x1 and x2) and merges them side-by-side,
#' handling overlapping subjects and adjusting positions appropriately.
#'
#' @param x1 First aligned pedigree structure (list)
#' @param x2 Second aligned pedigree structure (list)
#' @param packed Logical, if TRUE uses compact packing; if FALSE adds spacing
#' @param space Numeric, horizontal spacing between structures when packed=FALSE (default 1)
#' @param classic Logical, if TRUE uses classic alignment method (default FALSE)
#' @return A list containing the merged pedigree structure:
#'   \item{n}{Vector of counts per level}
#'   \item{nid}{Matrix of subject IDs at each level and position}
#'   \item{pos}{Matrix of horizontal positions}
#'   \item{fam}{Matrix of family indices}
#' @keywords internal
kinship2_alignped3 <- function(x1, x2, packed, space = 1,
                               classic = FALSE) {
  if (classic != TRUE) {
    return(kinship2_alignped3_optimized(
      x1 = x1, x2 = x2,
      packed = packed, space = space
    ))
  }
  maxcol <- max(x1$n + x2$n)
  maxlev <- length(x1$n)
  n1 <- max(x1$n) # These are always >1
  n <- x1$n + x2$n

  nid <- matrix(0, maxlev, maxcol)
  nid[, 1:n1] <- x1$nid

  pos <- matrix(0.0, maxlev, maxcol)
  pos[, 1:n1] <- x1$pos

  fam <- matrix(0, maxlev, maxcol)
  fam[, 1:n1] <- x1$fam
  fam2 <- x2$fam
  if (!packed) {
    ## Doc: alignped3: slide
    slide <- 0
    for (i in 1:maxlev) {
      n1 <- x1$n[i]
      n2 <- x2$n[i]
      if (n1 > 0 & n2 > 0) {
        if (nid[i, n1] == x2$nid[i, 1]) {
          temp <- pos[i, n1] - x2$pos[i, 1]
        } else {
          temp <- space + pos[i, n1] - x2$pos[i, 1]
        }
        if (temp > slide) slide <- temp
      }
    }
  }
  ## Doc: alignped3-merge
  for (i in 1:maxlev) {
    n1 <- x1$n[i]
    n2 <- x2$n[i]
    if (n2 > 0) { # If anything needs to be done for this row...
      if (n1 > 0 && (nid[i, n1] == floor(x2$nid[i, 1]))) {
        # two subjects overlap
        overlap <- 1
        fam[i, n1] <- max(fam[i, n1], fam2[i, 1])
        nid[i, n1] <- max(nid[i, n1], x2$nid[i, 1]) # preserve a ".5"
        if (!packed) {
          if (fam2[i, 1] > 0) {
            if (fam[i, n1] > 0) {
              pos[i, n1] <- (x2$pos[i, 1] + pos[i, n1] + slide) / 2
            } else {
              pos[i, n1] <- x2$pos[i, 1] + slide
            }
          }
        }
        n[i] <- n[i] - 1
      } else {
        overlap <- 0
      }

      if (packed) {
        slide <- if (n1 == 0) 0 else pos[i, n1] + space - overlap
      }
      zz <- seq(from = overlap + 1, length = n2 - overlap)
      nid[i, n1 + zz - overlap] <- x2$nid[i, zz]
      fam[i, n1 + zz - overlap] <- fam2[i, zz]
      pos[i, n1 + zz - overlap] <- x2$pos[i, zz] + slide

      if (i < maxlev) {
        # adjust the pointers of any children (look ahead)
        temp <- fam2[i + 1, ]
        fam2[i + 1, ] <- ifelse(temp == 0, 0, temp + n1 - overlap)
      }
    }
  }
  ## Doc: rest of alignped3
  if (max(n) < maxcol) {
    maxcol <- max(n)
    nid <- nid[, 1:maxcol]
    pos <- pos[, 1:maxcol]
    fam <- fam[, 1:maxcol]
  }

  list(n = n, nid = nid, pos = pos, fam = fam)
}

#' @rdname kinship2_alignped3
kinship2_alignped3_optimized <- function(x1, x2, packed, space = 1) {
  maxcol <- max(x1$n + x2$n)
  maxlev <- length(x1$n)
  n1_max <- max(x1$n)
  n <- x1$n + x2$n
  n1_vec <- x1$n
  n2_vec <- x2$n

  nid <- matrix(0, maxlev, maxcol)
  nid[, seq_len(n1_max)] <- x1$nid

  pos <- matrix(0.0, maxlev, maxcol)
  pos[, seq_len(n1_max)] <- x1$pos

  fam <- matrix(0, maxlev, maxcol)
  fam[, seq_len(n1_max)] <- x1$fam

  fam2 <- x2$fam

  # Pre-cache x2 first-column values to avoid repeated matrix indexing
  x2_nid1 <- x2$nid[, 1L]
  x2_pos1 <- x2$pos[, 1L]

  slide <- 0

  if (!packed) {
    # Vectorized slide computation across all levels at once
    active <- which(n1_vec > 0L & n2_vec > 0L)
    if (length(active) > 0L) {
      last_pos <- pos[cbind(active, n1_vec[active])]
      last_nid <- nid[cbind(active, n1_vec[active])]
      same <- last_nid == x2_nid1[active]
      temps <- last_pos - x2_pos1[active] + ifelse(same, 0, space)
      slide <- max(0, temps)
    }
  }

  for (i in seq_len(maxlev)) {
    n1 <- n1_vec[i]
    n2 <- n2_vec[i]
    if (n2 > 0L) {
      if (n1 > 0L && (nid[i, n1] == floor(x2_nid1[i]))) {
        overlap <- 1L
        fam[i, n1] <- max(fam[i, n1], fam2[i, 1L])
        nid[i, n1] <- max(nid[i, n1], x2$nid[i, 1L])
        if (!packed) {
          if (fam2[i, 1L] > 0L) {
            if (fam[i, n1] > 0L) {
              pos[i, n1] <- (x2$pos[i, 1L] + pos[i, n1] + slide) / 2
            } else {
              pos[i, n1] <- x2_pos1[i] + slide
            }
          }
        }
        n[i] <- n[i] - 1L
      } else {
        overlap <- 0L
      }

      if (packed) {
        slide <- if (n1 == 0L) 0 else pos[i, n1] + space - overlap
      }

      zz <- seq(from = overlap + 1L, length.out = n2 - overlap)
      dest <- n1 + zz - overlap
      nid[i, dest] <- x2$nid[i, zz]
      fam[i, dest] <- fam2[i, zz]
      pos[i, dest] <- x2$pos[i, zz] + slide

      if (i < maxlev) {
        temp <- fam2[i + 1L, ]
        fam2[i + 1L, ] <- ifelse(temp == 0L, 0L, temp + n1 - overlap)
      }
    }
  }

  if (max(n) < maxcol) {
    maxcol <- max(n)
    nid <- nid[, seq_len(maxcol), drop = FALSE]
    pos <- pos[, seq_len(maxcol), drop = FALSE]
    fam <- fam[, seq_len(maxcol), drop = FALSE]
  }

  list(n = n, nid = nid, pos = pos, fam = fam)
}
