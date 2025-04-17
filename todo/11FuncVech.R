#------------------------------------------------------------------------------
# Author: Michael D. Hunter
# Date: 2023-04-07
# Filename: 11FuncVech.R
# Purpose: Functions for new, efficient half vectorization
#------------------------------------------------------------------------------



for(j in 1:(nr-1)){
    for(i in (j+1):nr){
        cat(exmat[i, j], '\n')
    }
}

require(Matrix)

em <- Matrix(c(pi, 0, 3, 0, 0, 2*pi, 0, 2, 3, 0, 1.5*pi, 4.5, 0, 2, 4.5, 0), 4, 4, sparse=TRUE)
fm <- Matrix(c( 1, 2, 0, 4,
                2, 0, 0, 0,
                0, 0, 3, 0,
                4, 0, 0, 2), 4, 4, sparse=TRUE)


for(j in 2L:nr){
    for(i in 1L:(j-1)){
        cat(exmat[i, j], '\n')
    }
}

iss <- em@i + 1
pss <- em@p + 1
count <- 1
for(j in 2L:nr){
    for(i in 1L:(j-1)){
        if(iss[count] == i && )
    }
}

# loop through nonzero values
iss <- em@i + 1
pss <- em@p + 1
newColPos <- em@p + 1
nnz <- length(em@x)
tcol <- 1
for(i in 1L:nnz){
    if(i >= newColPos[tcol+1]) tcol <- tcol + 1
    iind <- iss[i]
    jind <- tcol
    val <- em@x[i]
    cat(iind, jind, val, '\n', sep=' ')
}



j <- 1
while(j < ncol(em)){
    vv <- j:(newColPos[j+1]-1)
    iinds <- iss[vv]
    jind <- j
    vals <- em@x[vv]
    j <- j + 1
}


# loop through columns
for(j in 1:ncol(em)){
    vv <- newColPos[j]:(newColPos[j+1]-1)
    for(v in vv){
        cat(iss[v], j, em@x[v], '\n', sep=' ')
    }
}

# THIS IS LIKELY THE MONEY-MAKER
# TODO Make more efficient, vectorize if possible
# loop through columns
for(j in 1L:ncol(em)){
    vv <- newColPos[j]:(newColPos[j+1]-1)
    for(i in 1L:j){
        if(i %in% iss[vv]){
            v <- vv[which(i == iss[vv])]
            cat(i, j, em@x[v], '\n', sep=' ')
        } else{
            cat(i, j, 0, '\n', sep=' ')
        }
    }
}



#------------------------------------------------------------------------------
# Full encapsulated example

require(Matrix)

em <- Matrix(c(pi, 0, 3, 0, 0, 2*pi, 0, 2, 3, 0, 1.5*pi, 4.5, 0, 2, 4.5, 0), 4, 4, sparse=TRUE)
fm <- Matrix(c( 1, 2, 0, 4,
                2, 0, 0, 0,
                0, 0, 3, 0,
                4, 0, 0, 2), 4, 4, sparse=TRUE)


newColPos1 <- em@p + 1
iss1 <- em@i + 1
newColPos2 <- fm@p + 1
iss2 <- fm@i + 1
numCol <- ncol(em)
for(j in 1L:numCol){
    vv1 <- newColPos1[j]:(newColPos1[j+1]-1)
    vv2 <- newColPos2[j]:(newColPos2[j+1]-1)
    for(i in 1L:j){
        if(i %in% iss1[vv1]){
            v1 <- vv1[which(i == iss1[vv1])]
            v1val <- em@x[v1]
        } else {v1val <- 0}
        if(i %in% iss2[vv2]){
            v2 <- vv2[which(i == iss2[vv2])]
            v2val <- fm@x[v2]
        } else {v2val <- 0}
        cat(i, j, v1val, v2val, '\n', sep=' ')
    }
}

#--------------------------------------
# Alternative form, trying to be faster

em <- Matrix(c(pi, 0, 3, 0, 0, 2*pi, 0, 2, 3, 0, 1.5*pi, 4.5, 0, 2, 4.5, 0), 4, 4, sparse=TRUE)
fm <- Matrix(c( 1, 2, 0, 4,
                2, 0, 0, 0,
                0, 0, 3, 0,
                4, 0, 0, 2), 4, 4, sparse=TRUE)


# Try a variation on this one
# loop through columns
loop_col <- function(inmat){
    fname <- 'bench1Del.csv'
    ds <- data.frame(i=integer(0), j=integer(0), val=numeric(0))
    write.table(ds, row.names=FALSE, col.names=TRUE, sep=',', file=fname)
    newColPos <- inmat@p + 1L
    iss <- inmat@i + 1L
    nc <- ncol(inmat)
    for(j in 1L:nc){
        if(newColPos[j] < newColPos[j+1]){
            vv <- newColPos[j]:(newColPos[j+1]-1L)
            out <- matrix(c(iss[vv], rep(j, length(vv)), inmat@x[vv]), nrow=length(vv), ncol=3L)
            write.table(out, file=fname, row.names=FALSE, col.names=FALSE, append=TRUE, sep=',')
        }
    }
}

loop_col2 <- function(inmat1, inmat2){
    fname <- 'bench1Del.csv'
    ds <- data.frame(i=integer(0), j=integer(0), val1=numeric(0), val2=numeric(0))
    write.table(ds, row.names=FALSE, col.names=TRUE, sep=',', file=fname)
    newColPos1 <- inmat1@p + 1L
    iss1 <- inmat1@i + 1L
    newColPos2 <- inmat2@p + 1L
    iss2 <- inmat2@i + 1L
    nc <- ncol(inmat1)
    for(j in 1L:nc){
        ncp1 <- newColPos1[j]
        ncp1p <- newColPos1[j+1L]
        cond1 <- ncp1 < ncp1p
        if(cond1){
            vv1 <- ncp1:(ncp1p-1L)
        }
        ncp2 <- newColPos2[j]
        ncp2p <- newColPos2[j+1L]
        cond2 <- ncp2 < ncp2p
        if(cond2){
            vv2 <- ncp2:(ncp2p-1L)
        }
        if(cond1 && !cond2){
            out <- matrix(c(iss1[vv1], rep(j, length(vv1)), inmat1@x[vv1], rep(0, length(vv1))), nrow=length(vv1), ncol=4L)
            write.table(out, file=fname, row.names=FALSE, col.names=FALSE, append=TRUE, sep=',')
        } else if(!cond1 && cond2){
            out <- matrix(c(iss2[vv2], rep(j, length(vv2)), rep(0, length(vv2)), inmat2@x[vv2]), nrow=length(vv2), ncol=4L)
            write.table(out, file=fname, row.names=FALSE, col.names=FALSE, append=TRUE, sep=',')
        } else if(cond1 && cond2){
            #browser()
            iss1vv <- iss1[vv1]
            iss2vv <- iss2[vv2]
            u <- sort(union(iss1vv, iss2vv))
            tds <- data.frame(i=u, j=j, val1=0, val2=0)
            #tds$j <- j
            #tds$val1 <- 0
            #tds$val2 <- 0
            tds$val1[tds$i %in% iss1vv] <- inmat1@x[vv1]
            tds$val2[tds$i %in% iss2vv] <- inmat2@x[vv2]
            write.table(tds, file=fname, row.names=FALSE, col.names=FALSE, append=TRUE, sep=',')
        }
    }
}


loop_col3 <- function(inmat1, inmat2, inmat3){
    fname <- 'bench1Del.csv'
    ds <- data.frame(i=integer(0), j=integer(0), val1=numeric(0), val2=numeric(0), val3=numeric(0))
    write.table(ds, row.names=FALSE, col.names=TRUE, sep=',', file=fname)
    newColPos1 <- inmat1@p + 1L
    iss1 <- inmat1@i + 1L
    newColPos2 <- inmat2@p + 1L
    iss2 <- inmat2@i + 1L
    newColPos3 <- inmat3@p + 1L
    iss3 <- inmat3@i + 1L
    nc <- ncol(inmat1)
    for(j in 1L:nc){
        ncp1 <- newColPos1[j]
        ncp1p <- newColPos1[j+1L]
        cond1 <- ncp1 < ncp1p
        if(cond1){
            vv1 <- ncp1:(ncp1p-1L)
            iss1vv <- iss1[vv1]
        }
        ncp2 <- newColPos2[j]
        ncp2p <- newColPos2[j+1L]
        cond2 <- ncp2 < ncp2p
        if(cond2){
            vv2 <- ncp2:(ncp2p-1L)
            iss2vv <- iss2[vv2]
        }
        ncp3 <- newColPos3[j]
        ncp3p <- newColPos3[j+1L]
        cond3 <- ncp3 < ncp3p
        if(cond3){
            vv3 <- ncp3:(ncp3p-1L)
            iss3vv <- iss3[vv3]
        }
        u <- sort(union(union(if(cond1){iss1vv}, if(cond2){iss2vv}), if(cond3){iss3vv}))
        #browser()
        if(cond1 || cond2 || cond3){
            tds <- data.frame(i=u, j=j, val1=0, val2=0, val3=0)
            if(cond1){ tds$val1[tds$i %in% iss1vv] <- inmat1@x[vv1] }
            if(cond2){ tds$val2[tds$i %in% iss2vv] <- inmat2@x[vv2] }
            if(cond3){ tds$val3[tds$i %in% iss3vv] <- inmat3@x[vv3] }
            write.table(tds, file=fname, row.names=FALSE, col.names=FALSE, append=TRUE, sep=',')
        }
    }
}


loop_allif <- function(inmat){
    fname <- 'bench2Del.csv'
    ds <- data.frame(i=integer(0), j=integer(0), val=numeric(0))
    write.table(ds, row.names=FALSE, col.names=TRUE, sep=',', file=fname)
    newColPos1 <- inmat@p + 1L
    iss1 <- inmat@i + 1L
    numCol <- ncol(inmat)
    for(j in 1L:numCol){
        vv1 <- newColPos1[j]:(newColPos1[j+1]-1)
        for(i in 1L:j){
            if(i %in% iss1[vv1]){
                v1 <- vv1[which(i == iss1[vv1])]
                v1val <- inmat@x[v1]
            } else {v1val <- 0}
            if(v1val != 0){
                write.table(matrix(c(i, j, v1val), nrow=1, ncol=3), file=fname, row.names=FALSE, col.names=FALSE, append=TRUE, sep=',')
            }
        }
    }
}

loop_allif2 <- function(inmat1, inmat2){
    fname <- 'bench2Del.csv'
    ds <- data.frame(i=integer(0), j=integer(0), val1=numeric(0), val2=numeric(0))
    write.table(ds, row.names=FALSE, col.names=TRUE, sep=',', file=fname)
    newColPos1 <- inmat1@p + 1L
    iss1 <- inmat1@i + 1L
    newColPos2 <- inmat2@p + 1L
    iss2 <- inmat2@i + 1L
    numCol <- ncol(inmat1)
    for(j in 1L:numCol){
        vv1 <- newColPos1[j]:(newColPos1[j+1]-1)
        vv2 <- newColPos2[j]:(newColPos2[j+1]-1)
        cond1 <- (newColPos1[j] < newColPos1[j+1])
        cond2 <- (newColPos2[j] < newColPos2[j+1])
        for(i in 1L:j){
            if( (i %in% iss1[vv1]) && cond1 ){
                v1 <- vv1[which(i == iss1[vv1])]
                v1val <- inmat1@x[v1]
            } else {v1val <- 0}
            if( (i %in% iss2[vv2]) && cond2 ){
                v2 <- vv2[which(i == iss2[vv2])]
                v2val <- inmat2@x[v2]
            } else {v2val <- 0}
            if( (v1val != 0) || (v2val != 0)){
                write.table(matrix(c(i, j, v1val, v2val), nrow=1, ncol=4), file=fname, row.names=FALSE, col.names=FALSE, append=TRUE, sep=',')
            }
        }
    }
}

loop_allif3 <- function(inmat1, inmat2, inmat3){
    fname <- 'bench2Del.csv'
    ds <- data.frame(i=integer(0), j=integer(0), val1=numeric(0), val2=numeric(0), val3=numeric(0))
    write.table(ds, row.names=FALSE, col.names=TRUE, sep=',', file=fname)
    newColPos1 <- inmat1@p + 1L
    iss1 <- inmat1@i + 1L
    newColPos2 <- inmat2@p + 1L
    iss2 <- inmat2@i + 1L
    newColPos3 <- inmat3@p + 1L
    iss3 <- inmat3@i + 1L
    numCol <- ncol(inmat1)
    for(j in 1L:numCol){
        vv1 <- newColPos1[j]:(newColPos1[j+1]-1)
        vv2 <- newColPos2[j]:(newColPos2[j+1]-1)
        vv3 <- newColPos3[j]:(newColPos3[j+1]-1)
        cond1 <- (newColPos1[j] < newColPos1[j+1])
        cond2 <- (newColPos2[j] < newColPos2[j+1])
        cond3 <- (newColPos3[j] < newColPos3[j+1])
        for(i in 1L:j){
            if( (i %in% iss1[vv1]) && cond1 ){
                v1 <- vv1[which(i == iss1[vv1])]
                v1val <- inmat1@x[v1]
            } else {v1val <- 0}
            if( (i %in% iss2[vv2]) && cond2 ){
                v2 <- vv2[which(i == iss2[vv2])]
                v2val <- inmat2@x[v2]
            } else {v2val <- 0}
            if( (i %in% iss3[vv3]) && cond3 ){
                v3 <- vv3[which(i == iss3[vv3])]
                v3val <- inmat3@x[v3]
            } else {v3val <- 0}
            if( (v1val != 0) || (v2val != 0) || (v3val != 0) ){
                write.table(matrix(c(i, j, v1val, v2val, v3val), nrow=1, ncol=5), file=fname, row.names=FALSE, col.names=FALSE, append=TRUE, sep=',')
            }
        }
    }
}


#a <-  rsparsematrix(400, 400, density=.4, symmetric=TRUE)
loop_col(a)
loop_allif(a)


require(rbenchmark)
benchmark(loop_col(a), loop_allif(a), replications=5)
# 30x+ speed up for loop_col


a1 <- rsparsematrix(1000, 1000, density=.01, symmetric=TRUE)
a2 <- rsparsematrix(1000, 1000, density=.01, symmetric=TRUE)
benchmark(loop_col2(a1, a2), loop_allif2(a1, a2), replications=5)

loop_allif2(a1, a2)
loop_col2(a1, a2)


a1 <- rsparsematrix(1000, 1000, density=.01, symmetric=TRUE)
a2 <- rsparsematrix(1000, 1000, density=.01, symmetric=TRUE)
a3 <- rsparsematrix(1000, 1000, density=.01, symmetric=TRUE)
benchmark(loop_col3(a1, a2, a3), loop_allif3(a1, a2, a3), replications=5)

loop_allif3(a1, a2, a3)
loop_col3(a1, a2, a3)


# New version

# Previous version

newColPos1 <- em@p + 1
iss1 <- em@i + 1
newColPos2 <- fm@p + 1
iss2 <- fm@i + 1
numCol <- ncol(em)
for(j in 1L:numCol){
    vv1 <- newColPos1[j]:(newColPos1[j+1]-1)
    vv2 <- newColPos2[j]:(newColPos2[j+1]-1)
    for(i in 1L:j){
        if(i %in% iss1[vv1]){
            v1 <- vv1[which(i == iss1[vv1])]
            v1val <- em@x[v1]
        } else {v1val <- 0}
        if(i %in% iss2[vv2]){
            v2 <- vv2[which(i == iss2[vv2])]
            v2val <- fm@x[v2]
        } else {v2val <- 0}
        cat(i, j, v1val, v2val, '\n', sep=' ')
    }
}


# loop through columns
loop_col_id <- function(inmat, file='bench1Del.csv'){
  fname <- file
  nc <- ncol(inmat)
  ids <- as.numeric(dimnames(inmat)[[1]])
  ds <- data.frame(i=integer(0), j=integer(0), val=numeric(0))
  write.table(ds, row.names=FALSE, col.names=TRUE, sep=',', file=fname)
  newColPos <- inmat@p + 1L
  iss <- inmat@i + 1L
  nc <- ncol(inmat)
  for(j in 1L:nc){
    if(newColPos[j] < newColPos[j+1]){
      vv <- newColPos[j]:(newColPos[j+1]-1L)
      ID1 <- ids[iss[vv]]
      ID2 <- ids[j]
      out <- matrix(c(ID1, rep(ID2, length(vv)), inmat@x[vv]), nrow=length(vv), ncol=3L)
      write.table(out, file=fname, row.names=FALSE, col.names=FALSE, append=TRUE, sep=',')
    }
    if( !(j %% 1000) ) { cat(paste0('Done with ', j, ' of ', nc, '\n')) }
  }
}


#------------------------------------------------------------------------------
# Write the damned thing


require(Matrix)

load('dataBiggestCnPedigree.Rdata')
biggestCnPed <- as(biggestCnPed, "symmetricMatrix")
load('dataBiggestPedigree.Rdata')
load('dataBiggestMtPedigree.Rdata')
biggestMtPed@x[biggestMtPed@x > 0] <- 1


fname <- 'dataBiggestRelatedPairsTake2.csv'
ds <- data.frame(ID1=numeric(0), ID2=numeric(0), addRel=numeric(0), mitRel=numeric(0), cnuRel=numeric(0))
write.table(ds, file=fname, sep=',', append=FALSE, row.names=FALSE)
ids <- as.numeric(dimnames(biggestCnPed)[[1]])
newColPos1 <- biggestPed@p + 1L
iss1 <- biggestPed@i + 1L
newColPos2 <- biggestMtPed@p + 1L
iss2 <- biggestMtPed@i + 1L
newColPos3 <- biggestCnPed@p + 1L
iss3 <- biggestCnPed@i + 1L
nc <- ncol(biggestPed)
for(j in 1L:nc){
  ID2 <- ids[j]
  ncp1 <- newColPos1[j]
  ncp1p <- newColPos1[j+1L]
  cond1 <- ncp1 < ncp1p
  if(cond1){
    vv1 <- ncp1:(ncp1p-1L)
    iss1vv <- iss1[vv1]
  }
  ncp2 <- newColPos2[j]
  ncp2p <- newColPos2[j+1L]
  cond2 <- ncp2 < ncp2p
  if(cond2){
    vv2 <- ncp2:(ncp2p-1L)
    iss2vv <- iss2[vv2]
  }
  ncp3 <- newColPos3[j]
  ncp3p <- newColPos3[j+1L]
  cond3 <- ncp3 < ncp3p
  if(cond3){
    vv3 <- ncp3:(ncp3p-1L)
    iss3vv <- iss3[vv3]
  }
  u <- sort(union(union(if(cond1){iss1vv}, if(cond2){iss2vv}), if(cond3){iss3vv}))
  #browser()
  if(cond1 || cond2 || cond3){
    ID1 <- ids[u]
    tds <- data.frame(ID1=ID1, ID2=ID2, addRel=0, mitRel=0, cnuRel=0)
    if(cond1){ tds$addRel[u %in% iss1vv] <- biggestPed@x[vv1] }
    if(cond2){ tds$mitRel[u %in% iss2vv] <- biggestMtPed@x[vv2] }
    if(cond3){ tds$cnuRel[u %in% iss3vv] <- biggestCnPed@x[vv3] }
    write.table(tds, file=fname, row.names=FALSE, col.names=FALSE, append=TRUE, sep=',')
  }
  if( !(j %% 100) ) { cat(paste0('Done with ', j, ' of ', nc, '\n')) }
}


# R.utils::countLines(fname)
# 687692457
# 687,692,457 == 6.87e8 == 687 million lines
# system("find /c /v \"\" dataBiggestRelatedPairsTake2.csv")
#---------- DATABIGGESTRELATEDPAIRSTAKE2.CSV: 687692457
#[1] 0


dd <- read.csv('dataBiggestRelatedPairsTake2.csv', nrows=1e5L) #100,000,000

