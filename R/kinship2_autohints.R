# From autohint.R file
# Automatically generated from all.nw using noweb

#' Automatically generate alignment hints for pedigree plotting
#'
#' This function automatically generates alignment hints for pedigree plotting.
#' Hints control the relative horizontal positioning of subjects within their
#' generation and the placement of spouse pairs. The function handles twins,
#' multiple marriages, and complex pedigree structures.
#'
#' @param ped A pedigree object
#' @param hints Optional existing hints (list with `order` and optionally `spouse` components)
#' @param packed Logical, if TRUE uses compact packing algorithm (default TRUE)
#' @param align Logical, if TRUE attempts to align spouses on the same level (default FALSE)
#' @return A list containing:
#'   \item{order}{Numeric vector of relative ordering hints for subjects}
#'   \item{spouse}{Matrix of spouse pair information}
#' @keywords internal
#' @details
#' The function is called automatically by kinship2_align.pedigree if no hints
#' are provided. It analyzes the pedigree structure, identifies twins, handles
#' multiple marriages, and determines optimal subject ordering to minimize
#' crossing lines and produce aesthetically pleasing plots.
#'
#' Full documentation is available in the align_code_details vignette.
kinship2_autohint <- function(ped, hints, packed = TRUE, align = FALSE) {
  ## full documentation now in vignette: align_code_details.Rmd
  ## REferences to those sections appear here as:
  ## Doc: AutoHint
  if (!is.null(ped$hints)) {
    return(ped$hints)
  } # nothing to do
  n <- length(ped$id)
  depth <- kinship2_kindepth(ped, align = TRUE)

  if (is.null(ped$relation)) {
    relation <- NULL
  } else {
    relation <- cbind(
      as.matrix(ped$relation[, 1:2]),
      as.numeric(ped$relation[, 3])
    )
  }
  if (!is.null(relation) && any(relation[, 3] < 4)) {
    temp <- (relation[, 3] < 4)
    twinlist <- unique(c(relation[temp, 1:2])) # list of twin id's
    twinrel <- relation[temp, , drop = FALSE]

    twinset <- rep(0, n)
    twinord <- rep(1, n)
    for (i in 2:length(twinlist)) {
      # Now, for any pair of twins on a line of twinrel, give both
      #  of them the minimum of the two ids
      # For a set of triplets, it might take two iterations for the
      #  smallest of the 3 numbers to "march" across the threesome.
      #  For quads, up to 3 iterations, for quints, up to 4, ....
      newid <- pmin(twinrel[, 1], twinrel[, 2])
      twinset[twinrel[, 1]] <- newid
      twinset[twinrel[, 2]] <- newid
      twinord[twinrel[, 2]] <- pmax(
        twinord[twinrel[, 2]],
        twinord[twinrel[, 1]] + 1
      )
    }
  } else {
    twinset <- rep(0, n)
    twinrel <- NULL
  }
  ## Doc: Shift
  shift <- function(id, sibs, goleft, hint, twinrel, twinset) {
    if (twinset[id] > 0) {
      shift.amt <- 1 + diff(range(hint[sibs])) # enough to avoid overlap
      twins <- sibs[twinset[sibs] == twinset[id]]
      if (goleft) {
        hint[twins] <- hint[twins] - shift.amt
      } else {
        hint[twins] <- hint[twins] + shift.amt
      }

      mono <- any(twinrel[c(
        match(id, twinrel[, 1], nomatch = 0),
        match(id, twinrel[, 2], nomatch = 0)
      ), 3] == 1)
      if (mono) {
        #
        # ok, we have to worry about keeping the monozygotics
        #  together within the set of twins.
        # first, decide who they are, by finding those monozygotic
        #  with me, then those monozygotic with the results of that
        #  iteration, then ....  If I were the leftmost, this could
        #  take (#twins -1) iterations to get us all
        #
        monoset <- id
        rel2 <- twinrel[twinrel[, 3] == 1, 1:2, drop = FALSE]
        for (i in 2:length(twins)) {
          newid1 <- rel2[match(monoset, rel2[, 1], nomatch = 0), 2]
          newid2 <- rel2[match(monoset, rel2[, 2], nomatch = 0), 1]
          monoset <- unique(c(monoset, newid1, newid2))
        }
        if (goleft) {
          hint[monoset] <- hint[monoset] - shift.amt
        } else {
          hint[monoset] <- hint[monoset] + shift.amt
        }
      }
    }

    # finally, move the subject himself
    if (goleft) {
      hint[id] <- min(hint[sibs]) - 1
    } else {
      hint[id] <- max(hint[sibs]) + 1
    }

    hint[sibs] <- rank(hint[sibs]) # aesthetics -- no negative hints
    hint
  }
  ## Doc: init-autohint
  if (!missing(hints)) {
    if (is.vector(hints)) hints <- list(order = hints)
    if (is.matrix(hints)) hints <- list(spouse = hints)
    if (is.null(hints$order)) {
      horder <- integer(n)
    } else {
      horder <- hints$order
    }
  } else {
    horder <- integer(n)
  }

  for (i in unique(depth)) {
    who <- (depth == i & horder == 0)
    if (any(who)) horder[who] <- 1:sum(who) # screwy input - overwrite it
  }

  if (any(twinset > 0)) {
    # First, make any set of twins a cluster: 6.01, 6.02, ...
    #  By using fractions, I don't have to worry about other sib's values
    for (i in unique(twinset)) {
      if (i == 0) next
      who <- (twinset == i)
      horder[who] <- mean(horder[who]) + twinord[who] / 100
    }

    # Then reset to integers
    for (i in unique(ped$depth)) {
      who <- (ped$depth == i)
      horder[who] <- rank(horder[who]) # there should be no ties
    }
  }

  if (!missing(hints)) {
    sptemp <- hints$spouse
  } else {
    sptemp <- NULL
  }
  plist <- kinship2_align.pedigree(ped,
    packed = packed, align = align,
    hints = list(order = horder, spouse = sptemp)
  )
  ## end doc init

  ## duporder()
  ## Doc: fixup-2
  maxlev <- nrow(plist$nid)
  for (lev in 1:maxlev) {
    idlist <- plist$nid[lev, 1:plist$n[lev]] # subjects on this level
    dpairs <- kinship2_duporder(idlist, plist, lev, ped) # duplicates to be dealt with
    if (nrow(dpairs) == 0) next
    for (i in 1:nrow(dpairs)) {
      anchor <- spouse <- rep(0, 2)
      for (j in 1:2) {
        direction <- c(FALSE, TRUE)[j]
        mypos <- dpairs[i, j]
        if (plist$fam[lev, mypos] > 0) {
          # Am connected to parents at this location
          anchor[j] <- 1 # familial anchor
          sibs <- idlist[kinship2_findsibs(mypos, plist, lev)]
          if (length(sibs) > 1) {
            horder <- shift(
              idlist[mypos], sibs, direction,
              horder, twinrel, twinset
            )
          }
        } else {
          # spouse at this location connected to parents ?
          spouse[j] <- kinship2_findspouse(mypos, plist, lev, ped)
          if (plist$fam[lev, spouse[j]] > 0) { # Yes they are
            anchor[j] <- 2 # spousal anchor
            sibs <- idlist[kinship2_findsibs(spouse[j], plist, lev)]
            if (length(sibs) > 1) {
              horder <- shift(
                idlist[spouse[j]], sibs, direction,
                horder, twinrel, twinset
              )
            }
          }
        }
      }
      # add the marriage(s)
      ## Doc: Fixup2
      id1 <- idlist[dpairs[i, 1]] # i,1 and i,2 point to the same person
      id2 <- idlist[spouse[1]]
      id3 <- idlist[spouse[2]]

      temp <- switch(paste(anchor, collapse = ""),
        "21" = c(id2, id1, dpairs[i, 3]), # the most common case
        "22" = rbind(c(id2, id1, 1), c(id1, id3, 2)),
        "02" = c(id2, id1, 0),
        "20" = c(id2, id1, 0),
        "00" = rbind(c(id1, id3, 0), c(id2, id1, 0)),
        "01" = c(id2, id1, 2),
        "10" = c(id1, id2, 1),
        NULL
      )

      if (is.null(temp)) {
        warning("Unexpected result in autohint, please contact developer")
        return(list(order = 1:n)) # punt
      } else {
        sptemp <- rbind(sptemp, temp)
      }
    }
    #
    # Recompute, since this shifts things on levels below
    #
    plist <- kinship2_align.pedigree(ped,
      packed = packed, align = align,
      hints = list(order = horder, spouse = sptemp)
    )
  }
  list(order = horder, spouse = sptemp)
}

## Doc: duporder
#' Find all duplicated IDs on a level, and return
#' @keywords internal
#' @return A matrix with one row per duplicated ID, columns 1 and 2
kinship2_duporder <- function(idlist,
                              plist,
                              lev,
                              ped) {
  temp <- table(idlist)
  if (all(temp == 1)) {
    return(matrix(0L, nrow = 0, ncol = 3))
  }

  # make an initial list of all pairs's positions
  # if someone appears 4 times they get 3 rows
  npair <- sum(temp - 1)
  dmat <- matrix(0L, nrow = npair, ncol = 3)
  dmat[, 3] <- 2
  dmat[1:(npair / 2), 3] <- 1
  i <- 0
  for (id in unique(idlist[duplicated(idlist)])) {
    j <- which(idlist == id)
    for (k in 2:length(j)) {
      i <- i + 1
      dmat[i, 1:2] <- j[k + -1:0]
    }
  }
  if (nrow(dmat) == 1) {
    return(dmat)
  } # no need to sort it

  # families touch?
  famtouch <- logical(npair)
  for (i in 1:npair) {
    if (plist$fam[lev, dmat[i, 1]] > 0) {
      sib1 <- max(kinship2_findsibs(dmat[i, 1], plist, lev))
    } else {
      spouse <- kinship2_findspouse(dmat[i, 1], plist, lev, ped)
      ## If spouse is marry-in then move on without looking for sibs
      if (plist$fam[lev, spouse] == 0) {
        famtouch[i] <- FALSE
        next
      }
      sib1 <- max(kinship2_findsibs(spouse, plist, lev))
    }

    if (plist$fam[lev, dmat[i, 2]] > 0) {
      sib2 <- min(kinship2_findsibs(dmat[i, 2], plist, lev))
    } else {
      spouse <- kinship2_findspouse(dmat[i, 2], plist, lev, ped)
      ## If spouse is marry-in then move on without looking for sibs
      if (plist$fam[lev, spouse] == 0) {
        famtouch[i] <- FALSE
        next
      }
      sib2 <- min(kinship2_findsibs(spouse, plist, lev))
    }
    famtouch[i] <- (sib2 - sib1 == 1)
  }
  dmat[order(famtouch, dmat[, 1] - dmat[, 2]), , drop = FALSE]
}
