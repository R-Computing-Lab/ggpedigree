#------------------------------------------------------------------------------
# Author: Michael D. Hunter & Mason Garrison
# Date: 2023-10-07
# Filename: 09writeFamilies.R
# Purpose: Write the damned thing
#------------------------------------------------------------------------------



#------------------------------------------------------------------------------
# 

# all but biggest
require(Matrix)


load('dataAllbutBiggestCnPedigree.Rdata')
AllbutbiggestCnPed <- as(AllbutbiggestCnPed, "symmetricMatrix")
load('dataAllbutBiggestPedigree.Rdata')
load('dataAllbutBiggestMtPedigree.Rdata')
AllbutbiggestMtPed@x[AllbutbiggestMtPed@x > 0] <- 1


fname <- 'dataAllbutBiggestRelatedPairsTake2.csv'
ds <- data.frame(ID1=numeric(0), ID2=numeric(0), addRel=numeric(0), mitRel=numeric(0), cnuRel=numeric(0))
write.table(ds, file=fname, sep=',', append=FALSE, row.names=FALSE)
ids <- as.numeric(dimnames(AllbutbiggestCnPed)[[1]])
newColPos1 <- AllbutbiggestPed@p + 1L
iss1 <- AllbutbiggestPed@i + 1L
newColPos2 <- AllbutbiggestMtPed@p + 1L
iss2 <- AllbutbiggestMtPed@i + 1L
newColPos3 <- AllbutbiggestCnPed@p + 1L
iss3 <- AllbutbiggestCnPed@i + 1L
nc <- ncol(AllbutbiggestPed)

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
  u <- sort(igraph::union(igraph::union(if(cond1){iss1vv}, if(cond2){iss2vv}), if(cond3){iss3vv}))
  #browser()
  if(cond1 || cond2 || cond3){
    ID1 <- ids[u]
    tds <- data.frame(ID1=ID1, ID2=ID2, addRel=0, mitRel=0, cnuRel=0)
    if(cond1){ tds$addRel[u %in% iss1vv] <- AllbutbiggestPed@x[vv1] }
    if(cond2){ tds$mitRel[u %in% iss2vv] <- AllbutbiggestMtPed@x[vv2] }
    if(cond3){ tds$cnuRel[u %in% iss3vv] <- AllbutbiggestCnPed@x[vv3] }
    write.table(tds, file=fname, row.names=FALSE, col.names=FALSE, append=TRUE, sep=',')
  }
  if( !(j %% 100) ) { cat(paste0('Done with ', j, ' of ', nc, '\n')) }
}


# R.utils::countLines(fname)
# 687692457
# 687,692,457 == 6.87e8 == 687 million lines
# system("find /c /v \"\" dataAllbutBiggestRelatedPairsTake2.csv")
#---------- dataAllbutBiggestRELATEDPAIRSTAKE2.CSV: 687692457
#[1] 0


(dd <- read.csv('dataAllbutBiggestRelatedPairsTake2.csv', nrows=1e5L)) #100,000,000)


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
  u <- sort(igraph::union(igraph::union(if(cond1){iss1vv}, if(cond2){iss2vv}), if(cond3){iss3vv}))
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

# R.utils::countLines(fname)
#[1] 530648177
