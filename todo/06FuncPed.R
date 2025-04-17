#------------------------------------------------------------------------------
# Author: Michael D. Hunter and S. Mason Garrison
# Date: 2022-11-04
# Filename: 06FuncPed.R
# Purpose: Pedigree helper functions
#------------------------------------------------------------------------------


#require(SimRVPedigree)

require(Matrix) # for sparse matrices

# TODO Use matrix packages for sparse matrices in ped2add

##' Take a pedigree and turn it into additive nuclear genetic relatedness
##' @param ped a pedigree data file.  Needs ID, momID, dadID, and Gen columns
##' @param max.gen the maximum number of generations to compute
##'  (e.g., only up to 4th degree relatives).  The default of Inf uses as many
##'  generations as there are in the data.
##' @param gen.only logical  If true, only computes and returns the "generation" of each ID
##' @param verbose logical  If true print progress through stages of algorithm
##' @details source examplePedigreeFunctions
ped2addv1 <- function(ped, max.gen=Inf, gen.only=FALSE, verbose=FALSE){
  nr <- nrow(ped)
  if(verbose){cat(paste0('Family Size = ', nr, '\n'))}
  #isPar <- sparseMatrix(i=1, j=1, x=0, dims=c(nr, nr), dimnames=list(ped$ID, ped$ID))
  #isPar[1,1] <- 0
  parList <- list()
  lens <- integer(nr)
  # Is person in column j the parent of the person in row i? .5 for yes, 0 for no.
  for(i in 1:nr){
    x <- ped[i,, drop=FALSE]
    val <- (as.numeric(x['ID']) == as.numeric(ped$momID)) | (as.numeric(x['ID']) == as.numeric(ped$dadID))
    val[is.na(val)] <- FALSE
    # TODO make this indexing more efficient
    # Use sparseMatrix initializer and sum the sparse matrices?
    # keep track of indices only, and then initialize a single sparse matrix?  <- this one
    #if(any(val)){
    #  isPar[val, i] <- .5
    #}
    wv <- which(val)
    parList[[i]] <- wv
    lens[i] <- length(wv)
    if(verbose && !(i %% 100)) { cat(paste0('Done with ', i, ' of ', nr, '\n')) }
  }
  jss <- rep(1L:nr, times=lens)
  iss <- unlist(parList)
  rm(parList, lens)
  gc()
  isPar <- sparseMatrix(i=iss, j=jss, x=.5, dims=c(nr, nr), dimnames=list(ped$ID, ped$ID))
  if(verbose){cat('Completed first degree relatives (adjacency)\n')}
  # isPar is the adjacency matrix.  'A' matrix from RAM
  isChild <- apply(ped[,c('momID', 'dadID')], 1, function(x){2^(-!all(is.na(x)))})
  # isChild is the 'S' matrix from RAM
  r <- Diagonal(x=1, n=nr)
  gen <- rep(1, nr)
  mtSum <- sum(r, na.rm=TRUE)
  newIsPar <- isPar
  count <- 0
  maxCount <- max.gen + 1
  # resl <- list(r, isPar)
  # r is I + A + A^2 + ... = (I-A)^-1 from RAM
  while(mtSum != 0 & count < maxCount){
    r <- r + newIsPar
    gen <- gen + (rowSums(newIsPar) > 0)
    newIsPar <- newIsPar %*% isPar
    #dimnames(newIsPar) <- list(ped$ID, ped$ID)
    mtSum <- sum(newIsPar)
    count <- count + 1
    # resl <- c(resl, list(newIsPar))
    if(verbose){cat(paste0('Completed ', count-1, ' degree relatives\n'))}
  }
  if(verbose){cat('About to do RAM path tracing\n')}
  # compute rsq <- r %*% sqrt(diag(isChild))
  # compute rel <- tcrossprod(rsq)
  rm(isPar, newIsPar)
  gc()
  if(verbose){cat('Doing I-A inverse times diagonal multiplication\n')}
  r2 <- r %*% Diagonal(x=sqrt(isChild), n=nr)
  rm(r, isChild)
  gc()
  if(verbose){cat('Doing tcrossprod\n')}
  r <- tcrossprod(r2)
  #return(list(r, resl))
  if(gen.only){ return(gen) } else { return(r) }
}

ped2addv0 <- function(ped, max.gen=Inf, gen.only=FALSE, verbose=FALSE){
  nr <- nrow(ped)
  if(verbose){cat(paste0('Family Size = ', nr, '\n'))}
  #isPar <- sparseMatrix(i=1, j=1, x=0, dims=c(nr, nr), dimnames=list(ped$ID, ped$ID))
  #isPar[1,1] <- 0
  parList <- list()
  lens <- integer(nr)
  # Is person in column j the parent of the person in row i? .5 for yes, 0 for no.
  for(i in 1:nr){
    x <- ped[i,, drop=FALSE]
    val <- (as.numeric(x['ID']) == as.numeric(ped$momID)) | (as.numeric(x['ID']) == as.numeric(ped$dadID))
    val[is.na(val)] <- FALSE
    # TODO make this indexing more efficient
    # Use sparseMatrix initializer and sum the sparse matrices?
    # keep track of indices only, and then initialize a single sparse matrix?  <- this one
    #if(any(val)){
    #  isPar[val, i] <- .5
    #}
    wv <- which(val)
    parList[[i]] <- wv
    lens[i] <- length(wv)
    if(verbose && !(i %% 100)) { cat(paste0('Done with ', i, ' of ', nr, '\n')) }
  }
  jss <- rep(1L:nr, times=lens)
  iss <- unlist(parList)
  rm(parList, lens)
  gc()
  isPar <- sparseMatrix(i=iss, j=jss, x=.5, dims=c(nr, nr), dimnames=list(ped$ID, ped$ID))
  if(verbose){cat('Completed first degree relatives (adjacency)\n')}
  # isPar is the adjacency matrix.  'A' matrix from RAM
  isChild <- apply(ped[,c('momID', 'dadID')], 1, function(x){2^(-!all(is.na(x)))})
  # isChild is the 'S' matrix from RAM
  r <- Diagonal(x=1, n=nr)
  gen <- rep(1, nr)
  mtSum <- sum(r, na.rm=TRUE)
  newIsPar <- isPar
  count <- 0
  maxCount <- max.gen + 1
  # resl <- list(r, isPar)
  # r is I + A + A^2 + ... = (I-A)^-1 from RAM
  while(mtSum != 0 & count < maxCount){
    r <- r + newIsPar
    gen <- gen + (rowSums(newIsPar) > 0)
    newIsPar <- newIsPar %*% isPar
    #dimnames(newIsPar) <- list(ped$ID, ped$ID)
    mtSum <- sum(newIsPar)
    count <- count + 1
    # resl <- c(resl, list(newIsPar))
    if(verbose){cat(paste0('Completed ', count-1, ' degree relatives\n'))}
  }
  if(verbose){cat('About to do RAM path tracing\n')}
  # compute rsq <- r %*% sqrt(diag(isChild))
  # compute rel <- tcrossprod(rsq)
  rm(isPar, newIsPar)
  gc()
  if(verbose){cat('Doing I-A inverse times diagonal multiplication\n')}
  r2 <- r %*% Diagonal(x=sqrt(isChild), n=nr)
  rm(r, isChild)
  gc()
  if(verbose){cat('Doing tcrossprod\n')}
  r <- tcrossprod(r2)
  #return(list(r, resl))
  if(gen.only){ return(gen) } else { return(r) }
}


# Take a pedigree and turn it into common nuclear environments
## source examplePedigreeFunctions

### Hard to conclusively determine just from pedigree
### Could assume children with the same parents have the same rearing environment?
ped2cn <- function(ped){
  sameMom <- apply(ped, 1, function(x){val <- as.numeric(x['momID']) == as.numeric(ped$momID); val[is.na(val)] <- FALSE; return(val)})
  sameDad <- apply(ped, 1, function(x){val <- as.numeric(x['dadID']) == as.numeric(ped$dadID); val[is.na(val)] <- FALSE; return(val)})
  r <- sameMom * sameDad
  diag(r) <- 1
  dimnames(r) <- list(ped$ID, ped$ID)
  return(r)
}

ped2cn_v2 <- function(ped, verbose=FALSE){
  nr <- nrow(ped)
  if(verbose){cat(paste0('Family Size = ', nr, '\n'))}
  parList <- list()
  lens <- integer(nr)
  # Is person in column j the parent of the person in row i? .5 for yes, 0 for no.
  for(i in 1:nr){
    x <- ped[i,, drop=FALSE]
    sameMom <- (as.numeric(x['momID']) == as.numeric(ped$momID))
    sameMom[is.na(sameMom)] <- FALSE
    sameDad <- (as.numeric(x['dadID']) == as.numeric(ped$dadID))
    sameDad[is.na(sameDad)] <- FALSE
    wv <- which(sameMom & sameDad)
    parList[[i]] <- wv
    lens[i] <- length(wv)
    if(verbose && !(i %% 100)) { cat(paste0('Done with ', i, ' of ', nr, '\n')) }
  }
  jss <- rep(1L:nr, times=lens)
  iss <- unlist(parList)
  rm(parList, lens)
  gc()
  r <- sparseMatrix(i=iss, j=jss, x=1, dims=c(nr, nr), dimnames=list(ped$ID, ped$ID))
  if(verbose){cat('Completed first degree relatives (adjacency)\n')}
  diag(r) <- 1
  return(r)
}


# Take a pedigree and turn it into common extended environments

# Assumes person ID variable is called ID
# Assumes each row is a unique person
ped2ce <- function(ped){
  matrix(1, nrow=nrow(ped), ncol=nrow(ped), dimnames=list(ped$ID, ped$ID))
}



#------------------------------------------------------------------------------
# Take a pedigree and turn it into mitochondrial relatedness

# Iterated isMomOrSib
ped2mt_v1 <- function(ped){
  r <- matrix(0, nrow=nrow(ped), ncol=nrow(ped), dimnames=list(ped$ID, ped$ID))
  # Is person in column j the mom of the person in row i? 1 for yes, 0 for no.
  isMom <- apply(ped, 1, function(x){val <- x['ID'] == ped$momID; val[is.na(val)] <- FALSE; return(val)})
  isMomSib <- apply(ped, 1, function(x){val <- x['momID'] == ped$momID; val[is.na(val)] <- FALSE; return(val)})
  diag(r) <- 1
  isMom <- isMom | isMomSib
  mtSum <- sum(r, na.rm=TRUE)
  count <- 0
  maxCount <- max(ped$Gen) + 1
  newIsMom <- isMom
  while(mtSum != 0 & count < maxCount){
    r <- r + newIsMom + t(newIsMom)
    newIsMom <- newIsMom %*% isMom
    mtSum <- sum(newIsMom)
    count <- count + 1
  }
  r[r > 0] <- 1
  return(r)
}

# RAM inverse
ped2mt_v2 <- function(ped){
  r <- matrix(0, nrow=nrow(ped), ncol=nrow(ped), dimnames=list(ped$ID, ped$ID))
  # Is person in column j the mom of the person in row i? 1 for yes, 0 for no.
  isMom <- apply(ped, 1, function(x){val <- x['ID'] == ped$momID; val[is.na(val)] <- FALSE; return(val)})
  diag(r) <- 1
  ram <- solve(r - isMom) %*% r %*% t(solve(r - isMom))
  dimnames(ram) <- list(ped$ID, ped$ID)
  ram[ram > 0] <- 1
  return(ram)
}

# RAM iteration
ped2mt_v3 <- function(ped, max.gen=Inf){
  r <- matrix(0, nrow=nrow(ped), ncol=nrow(ped), dimnames=list(ped$ID, ped$ID))
  # Is person in column j the mom of the person in row i? 1 for yes, 0 for no.
  isMom <- apply(ped, 1, function(x){val <- (as.numeric(x['ID']) == as.numeric(ped$momID)); val[is.na(val)] <- FALSE; return(val)})
  diag(r) <- 1
  mtSum <- sum(r, na.rm=TRUE)
  newIsMom <- isMom
  count <- 0
  maxCount <- max.gen + 1
  while(mtSum != 0 & count < maxCount){
    r <- r + newIsMom
    newIsMom <- newIsMom %*% isMom
    mtSum <- sum(newIsMom)
    count <- count + 1
  }
  r <- r %*% t(r)
  r[r > 0] <- 1
  return(r)
}

# For large sparse matrices
# Note: v4 gives the full mt pattern, need to set anything greater than 0 to 1
ped2mt_v4 <- function(ped, max.gen=Inf, verbose=FALSE){
  nr <- nrow(ped)
  if(verbose){cat(paste0('Family Size = ', nr, '\n'))}
  #isPar <- sparseMatrix(i=1, j=1, x=0, dims=c(nr, nr), dimnames=list(ped$ID, ped$ID))
  #isPar[1,1] <- 0
  parList <- list()
  lens <- integer(nr)
  # Is person in column j the parent of the person in row i? .5 for yes, 0 for no.
  for(i in 1:nr){
    x <- ped[i,, drop=FALSE]
    val <- (as.numeric(x['ID']) == as.numeric(ped$momID))
    val[is.na(val)] <- FALSE
    wv <- which(val)
    parList[[i]] <- wv
    lens[i] <- length(wv)
    if(verbose && !(i %% 100)) { cat(paste0('Done with ', i, ' of ', nr, '\n')) }
  }
  jss <- rep(1L:nr, times=lens)
  iss <- unlist(parList)
  rm(parList, lens)
  gc()
  isMom <- sparseMatrix(i=iss, j=jss, x=.5, dims=c(nr, nr), dimnames=list(ped$ID, ped$ID))
  if(verbose){cat('Completed first degree relatives (adjacency)\n')}
  # isMom is the adjacency matrix.  'A' matrix from RAM
  r <- Diagonal(x=1, n=nr)
  gen <- rep(1, nr)
  mtSum <- sum(r, na.rm=TRUE)
  newIsMom <- isMom
  count <- 0
  maxCount <- max.gen + 1
  # resl <- list(r, isPar)
  # r is I + A + A^2 + ... = (I-A)^-1 from RAM
  while(mtSum != 0 & count < maxCount){
    r <- r + newIsMom
    gen <- gen + (rowSums(newIsMom) > 0)
    newIsMom <- newIsMom %*% isMom
    mtSum <- sum(newIsMom)
    count <- count + 1
    if(verbose){cat(paste0('Completed ', count-1, ' degree relatives\n'))}
  }
  if(verbose){cat('About to do RAM path tracing\n')}
  # compute rsq <- r %*% t(r) using tcrossprod
  rm(isMom, newIsMom)
  gc()
  if(verbose){cat('Doing tcrossprod\n')}
  r2 <- tcrossprod(r)
  rm(r)
  gc()
  #return(list(r, resl))
  return(r2)
}


#------------------------------------------------------------------------------
# not in 
`%notin%` <- Negate(`%in%`)



#try return NA

try_NA = function(expr){
  tryCatch(expr,error=function(err) NA)
}


