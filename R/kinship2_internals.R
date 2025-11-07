

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
kinship2_autohint <- function(ped, hints, packed=TRUE, align=FALSE) {
    ## full documentation now in vignette: align_code_details.Rmd
    ## REferences to those sections appear here as:
    ## Doc: AutoHint
    if (!is.null(ped$hints)) return(ped$hints)  #nothing to do
    n <- length(ped$id)
    depth <- kinship2_kindepth(ped, align=TRUE)

    if (is.null(ped$relation)) relation <- NULL
    else  relation <- cbind(as.matrix(ped$relation[,1:2]),
                            as.numeric(ped$relation[,3]))
    if (!is.null(relation) && any(relation[,3] <4)) {
        temp <- (relation[,3] < 4)
        twinlist <- unique(c(relation[temp,1:2]))  #list of twin id's
        twinrel  <- relation[temp,,drop=F]

        twinset <- rep(0,n)
        twinord <- rep(1,n)
        for (i in 2:length(twinlist)) {
            # Now, for any pair of twins on a line of twinrel, give both
            #  of them the minimum of the two ids
            # For a set of triplets, it might take two iterations for the
            #  smallest of the 3 numbers to "march" across the threesome.
            #  For quads, up to 3 iterations, for quints, up to 4, ....
            newid <- pmin(twinrel[,1], twinrel[,2])
            twinset[twinrel[,1]] <- newid
            twinset[twinrel[,2]] <- newid
            twinord[twinrel[,2]] <- pmax(twinord[twinrel[,2]],
                                         twinord[twinrel[,1]]+1)
            }
        }
    else {
        twinset <- rep(0,n)
        twinrel <- NULL
        }
    ## Doc: Shift
    shift <- function(id, sibs, goleft, hint, twinrel, twinset) {
        if (twinset[id]> 0)  {
            shift.amt <- 1 + diff(range(hint[sibs]))  # enough to avoid overlap
            twins <- sibs[twinset[sibs]==twinset[id]]
            if (goleft)
                 hint[twins] <- hint[twins] - shift.amt
            else hint[twins] <- hint[twins] + shift.amt

            mono  <- any(twinrel[c(match(id, twinrel[,1], nomatch=0),
                                   match(id, twinrel[,2], nomatch=0)),3]==1)
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
                rel2 <- twinrel[twinrel[,3]==1, 1:2, drop=F]
                for (i in 2:length(twins)) {
                    newid1 <- rel2[match(monoset, rel2[,1], nomatch=0),2]
                    newid2 <- rel2[match(monoset, rel2[,2], nomatch=0),1]
                    monoset <- unique(c(monoset, newid1, newid2))
                    }
                if (goleft)
                       hint[monoset]<- hint[monoset] - shift.amt
                else   hint[monoset]<- hint[monoset] + shift.amt
                }
            }

        #finally, move the subject himself
        if (goleft) hint[id] <- min(hint[sibs]) -1
        else        hint[id] <- max(hint[sibs]) +1

        hint[sibs] <- rank(hint[sibs])  # aesthetics -- no negative hints
        hint
        }
    ## Doc: init-autohint
    if (!missing(hints)) {
        if (is.vector(hints)) hints <- list(order=hints)
        if (is.matrix(hints)) hints <- list(spouse=hints)
        if (is.null(hints$order)) horder <- integer(n)
        else horder <- hints$order
        }
    else horder <- integer(n)

    for (i in unique(depth)) {
        who <- (depth==i & horder==0)
        if (any(who)) horder[who] <- 1:sum(who) #screwy input - overwrite it
        }

    if (any(twinset>0)) {
        # First, make any set of twins a cluster: 6.01, 6.02, ...
        #  By using fractions, I don't have to worry about other sib's values
        for (i in unique(twinset)) {
            if (i==0) next
            who <- (twinset==i)
            horder[who] <- mean(horder[who]) + twinord[who]/100
            }

        # Then reset to integers
        for (i in unique(ped$depth)) {
            who <- (ped$depth==i)
            horder[who] <- rank(horder[who])  #there should be no ties
            }
        }

    if (!missing(hints)) sptemp <- hints$spouse
    else sptemp <- NULL
    plist <- kinship2_align.pedigree(ped, packed=packed, align=align,
                            hints=list(order=horder, spouse=sptemp))
    ## end doc init
    ## Doc: fixup, and findspouse/findsibs
    findspouse <- function(mypos, plist, lev, ped) {
        lpos <- mypos
        while (lpos >1 && plist$spouse[lev, lpos-1]) lpos <- lpos-1
        rpos <- mypos
        while(plist$spouse[lev, rpos]) rpos <- rpos +1
        if (rpos==lpos) stop("autohint bug 3")

        opposite <-ped$sex[plist$nid[lev,lpos:rpos]] != ped$sex[plist$nid[lev,mypos]]
        if (!any(opposite)) stop("autohint bug 4")  # no spouse
        spouse <- min((lpos:rpos)[opposite])  #can happen with a triple marriage
        spouse
        }
    findsibs <- function(mypos, plist, lev) {
        family <- plist$fam[lev, mypos]
        if (family==0) stop("autohint bug 6")
        which(plist$fam[lev,] == family)
        }
    ## Doc: duporder
    duporder <- function(idlist, plist, lev, ped) {
        temp <- table(idlist)
        if (all(temp==1)) return (matrix(0L, nrow=0, ncol=3))

        # make an intial list of all pairs's positions
        # if someone appears 4 times they get 3 rows
        npair <- sum(temp-1)
        dmat <- matrix(0L, nrow=npair, ncol=3)
        dmat[,3] <- 2; dmat[1:(npair/2),3] <- 1
        i <- 0
        for (id in unique(idlist[duplicated(idlist)])) {
            j <- which(idlist==id)
            for (k in 2:length(j)) {
                i <- i+1
                dmat[i,1:2] <- j[k + -1:0]
                }
            }
        if (nrow(dmat)==1) return(dmat)  #no need to sort it

        # families touch?
        famtouch <- logical(npair)
        for (i in 1:npair) {
            if (plist$fam[lev,dmat[i,1]] >0)
                 sib1 <- max(findsibs(dmat[i,1], plist, lev))
            else {
                spouse <- findspouse(dmat[i,1], plist, lev, ped)
                ##If spouse is marry-in then move on without looking for sibs
                    if (plist$fam[lev,spouse]==0) {famtouch[i] <- F; next}
                sib1 <- max(findsibs(spouse, plist, lev))
                }

            if (plist$fam[lev, dmat[i,2]] >0)
                sib2 <- min(findsibs(dmat[i,2], plist, lev))
            else {
                spouse <- findspouse(dmat[i,2], plist, lev, ped)
                ##If spouse is marry-in then move on without looking for sibs
                    if (plist$fam[lev,spouse]==0) {famtouch[i] <- F; next}
                sib2 <- min(findsibs(spouse, plist, lev))
                }
            famtouch[i] <- (sib2-sib1 ==1)
            }
        dmat[order(famtouch, dmat[,1]- dmat[,2]),, drop=FALSE ]
    } ## duporder()
    ## Doc: fixup-2
    maxlev <- nrow(plist$nid)
    for (lev in 1:maxlev) {
        idlist <- plist$nid[lev,1:plist$n[lev]] #subjects on this level
        dpairs <- duporder(idlist, plist, lev, ped)  #duplicates to be dealt with
        if (nrow(dpairs)==0) next;
        for (i in 1:nrow(dpairs)) {
            anchor <- spouse <- rep(0,2)
            for (j in 1:2) {
                direction <- c(FALSE, TRUE)[j]
                mypos <- dpairs[i,j]
                if (plist$fam[lev, mypos] >0) {
                    # Am connected to parents at this location
                    anchor[j] <- 1  #familial anchor
                    sibs <- idlist[findsibs(mypos, plist, lev)]
                    if (length(sibs) >1)
                        horder <- shift(idlist[mypos], sibs, direction,
                                        horder, twinrel, twinset)
                    }
                else {
                    #spouse at this location connected to parents ?
                    spouse[j] <- findspouse(mypos, plist, lev, ped)
                    if (plist$fam[lev,spouse[j]] >0) { # Yes they are
                        anchor[j] <- 2  #spousal anchor
                        sibs <- idlist[findsibs(spouse[j], plist, lev)]
                        if (length(sibs) > 1)
                            horder <- shift(idlist[spouse[j]], sibs, direction,
                                        horder, twinrel, twinset)
                        }
                    }
                }
            # add the marriage(s)
            ## Doc: Fixup2
            id1 <- idlist[dpairs[i,1]]  # i,1 and i,2 point to the same person
            id2 <- idlist[spouse[1]]
            id3 <- idlist[spouse[2]]

            temp <- switch(paste(anchor, collapse=''),
                           "21" = c(id2, id1, dpairs[i,3]),   #the most common case
                           "22" = rbind(c(id2, id1, 1), c(id1, id3, 2)),
                           "02" = c(id2, id1, 0),
                           "20" = c(id2, id1, 0),
                           "00" = rbind(c(id1, id3, 0), c(id2, id1, 0)),
                           "01" = c(id2, id1, 2),
                           "10" = c(id1, id2, 1),
                           NULL)

            if (is.null(temp)) {
                warning("Unexpected result in autohint, please contact developer")
                return(list(order=1:n))  #punt
              }
            else sptemp <- rbind(sptemp, temp)
            }
        #
        # Recompute, since this shifts things on levels below
        #
        plist <- kinship2_align.pedigree(ped, packed=packed, align=align,
                                hints=list(order=horder, spouse=sptemp))
        }
    list(order=horder, spouse=sptemp)
    }


# from kinship2_align.pedigree.R
## Automatically generated from all.nw using noweb

#' Align a pedigree for plotting
#'
#' This is the main function for aligning a pedigree structure for plotting.
#' It arranges subjects by generation, positions them horizontally to minimize
#' line crossings, handles spouse relationships, and produces the coordinate
#' system needed for drawing the pedigree.
#'
#' @param ped A pedigree object or pedigreeList object
#' @param packed Logical, if TRUE uses compact packing algorithm (default TRUE)
#' @param width Numeric, maximum width of the pedigree plot (default 10)
#' @param align Logical or numeric. If TRUE, attempts to align spouses on same level.
#'   If numeric, a vector c(a1, a2) controlling alignment penalties (default TRUE)
#' @param hints Optional list with `order` and `spouse` components to guide alignment.
#'   If NULL, kinship2_autohint is called to generate hints
#' @return For a single pedigree, a list containing:
#'   \item{n}{Vector of counts per generation level}
#'   \item{nid}{Matrix of subject IDs at each position}
#'   \item{pos}{Matrix of horizontal positions}
#'   \item{fam}{Matrix of family indices indicating parent connections}
#'   \item{spouse}{Matrix indicating spouse connections}
#'   \item{twins}{Optional matrix indicating twin relationships}
#'   For a pedigreeList, returns the input with alignment information added.
#' @keywords internal
#' @details
#' This function handles the complete pedigree alignment process:
#' \itemize{
#'   \item Determines generation levels using kinship2_kindepth
#'   \item Generates or validates alignment hints using kinship2_autohint or kinship2_check.hint
#'   \item Builds spouse relationships list
#'   \item Processes founders and their descendants using kinship2_alignped1, kinship2_alignped2, kinship2_alignped3
#'   \item Optimizes horizontal spacing using kinship2_alignped4
#'   \item Identifies inbreeding loops and twin relationships
#' }
kinship2_align.pedigree <- function(ped, packed=TRUE, width=10, align=TRUE, hints=ped$hints) {

    if ('pedigreeList' %in% class(ped)) {
        nped <- length(unique(ped$famid))
        alignment <- vector('list', nped)
        for (i in 1:nped) {
            temp <- kinship2_align.pedigree(ped[i], packed, width, align)
            alignment[[i]] <- temp$alignment
            }
        ped$alignment <- alignment
        class(ped) <- 'pedigreeListAligned'
        return(ped)
        }

    if (is.null(hints)) {
      hints <- try({kinship2_autohint(ped)}, silent=TRUE)
      ## sometimes appears dim(ped) is empty (ped is NULL), so try fix here: (JPS 6/6/17
      if("try-error" %in% class(hints)) hints <- list(order=seq_len(max(1, dim(ped)))) ## 1:dim(ped))
    } else {
      hints <- kinship2_check.hint(hints, ped$sex)
    }
    ## Doc: Setup-align
    n <- length(ped$id)
    dad <- ped$findex; mom <- ped$mindex  #save typing
    if (any(dad==0 & mom>0) || any(dad>0 & mom==0))
            stop("Everyone must have 0 parents or 2 parents, not just one")
    level <- 1 + kinship2_kindepth(ped, align=TRUE)

    horder <- hints$order   # relative order of siblings within a family

    if (is.null(ped$relation)) relation <- NULL
    else  relation <- cbind(as.matrix(ped$relation[,1:2]),
                            as.numeric(ped$relation[,3]))

    if (!is.null(hints$spouse)) { # start with the hints list
        tsex <- ped$sex[hints$spouse[,1]]  #sex of the left member
        spouselist <- cbind(0,0,  1+ (tsex!='male'),
                            hints$spouse[,3])
        spouselist[,1] <- ifelse(tsex=='male', hints$spouse[,1], hints$spouse[,2])
        spouselist[,2] <- ifelse(tsex=='male', hints$spouse[,2], hints$spouse[,1])
        }
    else spouselist <- matrix(0L, nrow=0, ncol=4)

    if (!is.null(relation) && any(relation[,3]==4)) {
        # Add spouses from the relationship matrix
        trel <- relation[relation[,3]==4,,drop=F]
        tsex <- ped$sex[trel[,1]]
        trel[tsex!='male',1:2] <- trel[tsex!='male',2:1]
        spouselist <- rbind(spouselist, cbind(trel[,1],
                                              trel[,2],
                                              0,0))
        }
    if (any(dad>0 & mom>0) ) {
        # add parents
        who <- which(dad>0 & mom>0)
        spouselist <- rbind(spouselist, cbind(dad[who], mom[who], 0, 0))
        }

    hash <- spouselist[,1]*n + spouselist[,2]
    spouselist <- spouselist[!duplicated(hash),, drop=F]

    ## Doc: Founders -align
    noparents <- (dad[spouselist[,1]]==0 & dad[spouselist[,2]]==0)
     ##Take duplicated mothers and fathers, then founder mothers
    dupmom <- spouselist[noparents,2][duplicated(spouselist[noparents,2])]
       ##^Founding mothers with multiple marriages
    dupdad <- spouselist[noparents,1][duplicated(spouselist[noparents,1])]
       ##^Founding fathers with multiple marriages
    foundmom <- spouselist[noparents&!(spouselist[,1] %in% c(dupmom,dupdad)),2] # founding mothers
    founders <-  unique(c(dupmom, dupdad, foundmom))
    founders <-  founders[order(horder[founders])]  #use the hints to order them
    rval <- kinship2_alignped1(founders[1], dad, mom, level, horder,
                              packed=packed, spouselist=spouselist)

    if (length(founders)>1) {
        spouselist <- rval$spouselist
        for (i in 2:length(founders)) {
            rval2 <- kinship2_alignped1(founders[i], dad, mom,
                               level, horder, packed, spouselist)
            spouselist <- rval2$spouselist
            rval <- kinship2_alignped3(rval, rval2, packed)
            }
        }
    ## Doc: finish-align (1)
    # Unhash out the spouse and nid arrays
    #
    nid    <- matrix(as.integer(floor(rval$nid)), nrow=nrow(rval$nid))
    spouse <- 1L*(rval$nid != nid)
    maxdepth <- nrow(nid)

    # For each spouse pair, find out if it should be connected with
    #  a double line.  This is the case if they have a common ancestor
    kinship2_ancestor <- function(me, momid, dadid) {
        alist <- me
        repeat {
            newlist <- c(alist, momid[alist], dadid[alist])
            newlist <- sort(unique(newlist[newlist>0]))
            if (length(newlist)==length(alist)) break
            alist <- newlist
            }
        alist[alist!=me]
        }
    for (i in (1:length(spouse))[spouse>0]) {
        a1 <- kinship2_ancestor(nid[i], mom, dad)
        a2 <- kinship2_ancestor(nid[i+maxdepth],mom, dad)  #matrices are in column order
        if (any(duplicated(c(a1, a2)))) spouse[i] <- 2
        }
    ## Doc: finish align(2)
    if (!is.null(relation) && any(relation[,3] < 4)) {
        twins <- 0* nid
        who  <- (relation[,3] <4)
        ltwin <- relation[who,1]
        rtwin <- relation[who,2]
        ttype <- relation[who,3]

        # find where each of them is plotted (any twin only appears
        #   once with a family id, i.e., under their parents)
        ntemp <- ifelse(rval$fam>0, nid,0) # matix of connected-to-parent ids
        ltemp <- (1:length(ntemp))[match(ltwin, ntemp, nomatch=0)]
        rtemp <- (1:length(ntemp))[match(rtwin, ntemp, nomatch=0)]
        twins[pmin(ltemp, rtemp)] <- ttype
        }
    else twins <- NULL
    ## Doc: finish align(3)
    if ((is.numeric(align) || align) && max(level) >1)
        pos <- kinship2_alignped4(rval, spouse>0, level, width, align)
    else pos <- rval$pos

    if (is.null(twins))
         list(n=rval$n, nid=nid, pos=pos, fam=rval$fam, spouse=spouse)
    else list(n=rval$n, nid=nid, pos=pos, fam=rval$fam, spouse=spouse,
                  twins=twins)
}

# from kindepth.R
## Extracted from checks.Rnw

## Kindepth: helper function used throughout computes the depth of
# each subject in the pedigree.
# For each subject this is defined as the maximal number of
# generations of ancestors: how far to the farthest founder.
# This can be called with a pedigree object, or with the
# full argument list.  In the former case we can simply skip a step

#' Calculate the depth (generation level) of subjects in a pedigree
#'
#' This function computes the depth of each subject in a pedigree, defined as
#' the maximal number of generations of ancestors (distance to the farthest founder).
#' Optionally aligns spouses to plot on the same generation level.
#'
#' @param id Either a pedigree/pedigreeList object, or a vector of subject IDs
#' @param dad.id Vector of father IDs (required if `id` is not a pedigree object)
#' @param mom.id Vector of mother IDs (required if `id` is not a pedigree object)
#' @param align Logical, if TRUE attempts to align married couples at the same
#'   depth level for better visualization (default FALSE)
#' @return Integer vector of depth values for each subject, where 0 = founder,
#'   1 = child of founder, etc.
#' @keywords internal
#' @details
#' When `align=TRUE`, the function adjusts depths so that married couples appear
#' on the same generation level when possible. This produces more aesthetically
#' pleasing pedigree plots. The alignment algorithm handles marry-ins, multiple
#' marriages, and inbreeding loops.
kinship2_kindepth <- function(id, dad.id, mom.id, align=FALSE) {
    if ("pedigree" %in% class(id) || "pedigreeList" %in% class(id)) {
        didx <- id$findex
        midx <- id$mindex
        n <- length(didx)
        }
    else {
        n <- length(id)
        if (missing(dad.id) || length(dad.id) !=n)
            stop("Invalid father id")
        if (missing(mom.id) || length(mom.id) !=n)
            stop("Invalid mother id")
        midx <- match(mom.id, id, nomatch=0) # row number of my mom
        didx <- match(dad.id, id, nomatch=0) # row number of my dad
        }
    if (n==1) return (0)  # special case of a single subject
    parents <- which(midx==0 & didx==0)  #founders

    depth <- rep(0,n)
    # At each iteration below, all children of the current "parents" are
    #    labeled with depth 'i', and become the parents of the next iteration
    for (i in 1:n) {
	child  <- match(midx, parents, nomatch=0) +
		  match(didx, parents, nomatch=0)

	if (all(child==0)) break
	if (i==n)
	    stop("Impossible pedegree: someone is their own ancestor")

	parents <- which(child>0) #next generation of parents
	depth[parents] <- i
	}
    if (!align) return(depth)

    ## align
    ## Assume that subjects A and B marry, we have some ancestry information for
    ## both, and that A's ancestors go back 3 generations, B's for only two.  If we
    ## add +1 to the depth of B and all her ancestors, then A and B will be the same
    ## depth, and will plot on the same line.  Founders who marry in are also aligned.
    ## However, if an inbred pedigree, may not be a simple fix of this sort.

    ## The algorithm is
    ## 1 First deal with founders. If a founder marries in multiple times at multiple
    ## deaths (animal pedigrees), given that subject the min(depth of spouses). These
    ## subjects cause trouble for the general algorithm below: the result would depend on the
    ## data order.
    ## 2. Find any remaining mother-father pairs that are mismatched in depth.
    ##   Deal with them one at a time.
    ## 3.  The children's depth is max(father, mother) +1.  Call the
    ##   parent closest to the children ``good'' and the other ``bad''.
    ## 4. Chase up the good side, and get a list of all subjects connected
    ## to "good", including in-laws (spouse connections) and sibs that are
    ## at this level or above.  Call this agood (ancestors of good).
    ##We do not follow any connections at a depth lower than the
    ##marriage in question, to get the highest marriages right.
    ##For the bad side, just get ancestors.
    ## 5. Avoid pedigree loops!  If the agood list contains anyone in abad,
    ## then don't try to fix the alignment, otherwise: Push abad down, then run the
    ## pushdown algorithm to repair any descendents --- you may have pulled down a
    ## grandparent but not the sibs of that grandparent.

    ##It may be possible to do better alignment when the pedigree has loops,
    ##but it is definitely beyond this program, perhaps in autohint one day.

    kinship2_chaseup <- function(x, midx, didx) {
        new <- c(midx[x], didx[x])  # mother and father
        new <- new[new>0]
        while (length(new) >1) {
            x <- unique(c(x, new))
            new <- c(midx[new], didx[new])
            new <- new[new>0]
        }
        x
    } ## kinship2_chaseup()

    ## First deal with any parents who are founders
    ##  They all start with depth 0
    dads <- didx[midx>0 & didx>0]   # the father side of all spouse pairs
    moms <- midx[midx>0 & didx>0]
  if(0) {
    founder <- (midx==0 & didx==0)
    if (any(founder[dads])) {
        drow <- which(founder[dads])  # which pairs
        id  <- unique(dads[drow])     # id
        depth[id] <- tapply(depth[moms[drow]], dads[drow], min)
        dads <- dads[-drow]
        moms <- moms[-drow]
    }
    if (any(founder[moms])) {
        mrow <- which(founder[moms])  # which pairs
        id  <- unique(moms[mrow])     # id
        depth[id] <- tapply(depth[dads[mrow]], moms[mrow], min)
        dads <- dads[-mrow]
        moms <- moms[-mrow]
    }
  }
    ## Get rid of duplicate pairs, which occur for any spouse with
    ##  multiple offspring
    dups <- duplicated(dads + moms*n)
    if (any(dups)) {
        dads <- dads[!dups]
        moms <- moms[!dups]
    }

    npair<- length(dads)
    done <- rep(FALSE, npair)  #couples that are taken care of
    while (TRUE) {
        pairs.to.fix <- which((depth[dads] != depth[moms]) & !done)
        if (length(pairs.to.fix) ==0) break
        temp <- pmax(depth[dads], depth[moms])[pairs.to.fix]
        who <- min(pairs.to.fix[temp==min(temp)])  # the chosen couple

        good <- moms[who]; bad <- dads[who]
        if (depth[dads[who]] > depth[moms[who]]) {
            good <- dads[who]; bad <- moms[who]
        }
        abad  <- kinship2_chaseup(bad,  midx, didx)
        if (length(abad) ==1 && sum(c(dads,moms)==bad)==1) {
                                        # simple case, a solitary marry-in
            depth[bad] <- depth[good]
        }
        else {
            agood <- kinship2_chaseup(good, midx, didx)  #ancestors of the "good" side
            ## For spouse chasing, I need to exclude the given pair
            tdad <- dads[-who]
            tmom <- moms[-who]
            while (1) {
                ## spouses of any on agood list
                spouse <- c(tmom[!is.na(match(tdad, agood))],
                            tdad[!is.na(match(tmom, agood))])
                temp <- unique(c(agood, spouse))
                temp <- unique(kinship2_chaseup(temp, midx, didx)) #parents
                kids <- (!is.na(match(midx, temp)) | !is.na(match(didx, temp)))
                temp <- unique(c(temp, (1:n)[kids & depth <= depth[good]]))
                if (length(temp) == length(agood)) break
                else agood <- temp
            }

            if (all(match(abad, agood, nomatch=0) ==0)) {
                ## shift it down
                depth[abad] <- depth[abad] + (depth[good] - depth[bad])

                ## Siblings may have had children: make sure all kids are
                ##   below their parents.  It's easiest to run through the
                ##   whole tree
                for (i in 0:n) {
                    parents <- which(depth==i)
                    child <- match(midx, parents, nomatch=0) +
                        match(didx, parents, nomatch=0)
                    if (all(child==0)) break
                    depth[child>0] <- pmax(i+1, depth[child>0])
                }
            }
        }
        ## Once a subject has been shifted, we don't allow them to instigate
        ##  yet another shift, possibly on another level
        done[dads==bad | moms==bad] <- TRUE
    } ## while(TRUE)
    if (all(depth>0)) stop("You found a bug in kindepth's alignment code!")
    depth
}
