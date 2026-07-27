# check data version for ASOIAF
asoiaf_nrow <- 699

.align_with_alignped_stages <- function(ped,
                                        packed = TRUE,
                                        width = 10,
                                        align = TRUE,
                                        hints = ped$hints,
                                        classic = TRUE) {
  if (is.null(hints)) {
    hints <- try(
      {
        kinship2_autohint(ped, classic = classic)
      },
      silent = TRUE
    )

    if ("try-error" %in% class(hints)) {
      hints <- list(order = seq_len(max(1, dim(ped))))
    }
  } else {
    hints <- kinship2_check.hint(hints, ped$sex)
  }

  n <- length(ped$id)
  dad <- ped$findex
  mom <- ped$mindex

  if (any(dad == 0 & mom > 0) || any(dad > 0 & mom == 0)) {
    stop("Everyone must have 0 parents or 2 parents, not just one")
  }

  level <- 1 + kinship2_kindepth(ped, align = TRUE)
  horder <- hints$order

  if (is.null(ped$relation)) {
    relation <- NULL
  } else {
    relation <- cbind(
      as.matrix(ped$relation[, 1:2]),
      as.numeric(ped$relation[, 3])
    )
  }

  if (!is.null(hints$spouse)) {
    tsex <- ped$sex[hints$spouse[, 1]]
    spouselist <- cbind(
      0,
      0,
      1 + (tsex != "male"),
      hints$spouse[, 3]
    )
    spouselist[, 1] <- ifelse(tsex == "male", hints$spouse[, 1], hints$spouse[, 2])
    spouselist[, 2] <- ifelse(tsex == "male", hints$spouse[, 2], hints$spouse[, 1])
  } else {
    spouselist <- matrix(0L, nrow = 0L, ncol = 4L)
  }

  if (!is.null(relation) && any(relation[, 3] == 4)) {
    trel <- relation[relation[, 3] == 4, , drop = FALSE]
    tsex <- ped$sex[trel[, 1]]
    trel[tsex != "male", 1:2] <- trel[tsex != "male", 2:1]

    spouselist <- rbind(
      spouselist,
      cbind(
        trel[, 1],
        trel[, 2],
        0,
        0
      )
    )
  }

  if (any(dad > 0 & mom > 0)) {
    who <- which(dad > 0 & mom > 0)
    spouselist <- rbind(spouselist, cbind(dad[who], mom[who], 0, 0))
  }

  hash <- spouselist[, 1] * n + spouselist[, 2]
  spouselist <- spouselist[!duplicated(hash), , drop = FALSE]

  noparents <- dad[spouselist[, 1]] == 0 & dad[spouselist[, 2]] == 0
  dupmom <- spouselist[noparents, 2][duplicated(spouselist[noparents, 2])]
  dupdad <- spouselist[noparents, 1][duplicated(spouselist[noparents, 1])]
  foundmom <- spouselist[noparents & !(spouselist[, 1] %in% c(dupmom, dupdad)), 2]

  founders <- unique(c(dupmom, dupdad, foundmom))
  founders <- founders[order(horder[founders])]

  rval <- kinship2_alignped1(
    founders[1],
    dad,
    mom,
    level,
    horder,
    packed = packed,
    spouselist = spouselist,
    classic = classic
  )

  if (length(founders) > 1) {
    spouselist <- rval$spouselist

    for (i in 2:length(founders)) {
      rval2 <- kinship2_alignped1(
        founders[i],
        dad,
        mom,
        level,
        horder,
        packed = packed,
        spouselist = spouselist,
        classic = classic
      )

      spouselist <- rval2$spouselist

      rval <- kinship2_alignped3(
        rval,
        rval2,
        packed = packed,
        classic = classic
      )
    }
  }

  nid <- matrix(as.integer(floor(rval$nid)), nrow = nrow(rval$nid))
  spouse <- 1L * (rval$nid != nid)
  maxdepth <- nrow(nid)

  ancestor <- function(me, momid, dadid) {
    alist <- me

    repeat {
      newlist <- c(alist, momid[alist], dadid[alist])
      newlist <- sort(unique(newlist[newlist > 0]))

      if (length(newlist) == length(alist)) {
        break
      }

      alist <- newlist
    }

    alist[alist != me]
  }

  for (i in seq_along(spouse)[spouse > 0]) {
    a1 <- ancestor(nid[i], mom, dad)
    a2 <- ancestor(nid[i + maxdepth], mom, dad)

    if (any(duplicated(c(a1, a2)))) {
      spouse[i] <- 2L
    }
  }

  if (!is.null(relation) && any(relation[, 3] < 4)) {
    twins <- 0 * nid
    who <- relation[, 3] < 4
    ltwin <- relation[who, 1]
    rtwin <- relation[who, 2]
    ttype <- relation[who, 3]

    ntemp <- ifelse(rval$fam > 0, nid, 0)
    ltemp <- seq_along(ntemp)[match(ltwin, ntemp, nomatch = 0)]
    rtemp <- seq_along(ntemp)[match(rtwin, ntemp, nomatch = 0)]

    twins[pmin(ltemp, rtemp)] <- ttype
  } else {
    twins <- NULL
  }

  if ((is.numeric(align) || align) && max(level) > 1) {
    pos <- kinship2_alignped4(
      rval = rval,
      spouse = spouse > 0,
      level = level,
      width = width,
      align = align,
      classic = classic
    )
  } else {
    pos <- rval$pos
  }

  if (is.null(twins)) {
    list(
      n = rval$n,
      nid = nid,
      pos = pos,
      fam = rval$fam,
      spouse = spouse
    )
  } else {
    list(
      n = rval$n,
      nid = nid,
      pos = pos,
      fam = rval$fam,
      spouse = spouse,
      twins = twins
    )
  }
}


expect_align_stage_equal <- function(classic, optimized, tolerance = 1e-8) {
  expect_equal(optimized$n, classic$n)
  expect_equal(optimized$nid, classic$nid)
  expect_equal(optimized$fam, classic$fam)
  expect_equal(optimized$spouse, classic$spouse)
  expect_equal(optimized$pos, classic$pos, tolerance = tolerance)

  if (!is.null(classic$twins) || !is.null(optimized$twins)) {
    expect_equal(optimized$twins, classic$twins)
  }
}


test_that("align.pedigree works with sample ped", {
  skip_if_not_installed("kinship2")
  library(kinship2)
  data("sample.ped")
  ped <- with(sample.ped, ggpedigree:::pedigree(id, father, mother, sex))
  withr::local_options(width = 50)
  # expect_snapshot(kinship2_align.pedigree(ped))
  align <- kinship2_align.pedigree(ped, classic = TRUE)

  expect_equal(align$n, c(8, 19, 22, 8))
  expect_equal(dim(align$nid), c(4, 22))
  expect_equal(dim(align$pos), c(4, 22))
  expect_equal(dim(align$fam), c(4, 22))
})

test_that("test autohint works with sample.ped", {
  skip_if_not_installed("kinship2")
  library(kinship2)
  data("sample.ped")
  ped <- with(sample.ped, ggpedigree:::pedigree(id, father, mother, sex))
  newhint <- kinship2_autohint(ped) # this fixes up marriages and such
  plist <- kinship2_align.pedigree(ped,
    packed = TRUE, align = TRUE,
    width = 8, hints = newhint,
    classic = TRUE
  )
  #  expect_snapshot(plist)
  expect_equal(plist$n, c(8, 19, 22, 8))
  expect_equal(dim(plist$nid), c(4, 22))
  expect_equal(dim(plist$pos), c(4, 22))
  expect_equal(dim(plist$fam), c(4, 22))
})

test_that("align.pedigree works with ASOIAF", {
  data("ASOIAF")
  # skip if not the correct data version
  if (!exists("ASOIAF") || !is.data.frame(ASOIAF) || nrow(ASOIAF) != asoiaf_nrow) {
    skip("ASOIAF data not available, or not the correct version")
  }
  df_ASOIAF <- BGmisc::checkParentIDs(ASOIAF,
    addphantoms = TRUE,
    repair = TRUE,
    parentswithoutrow = FALSE,
    repairsex = FALSE
  )

  ped <- with(df_ASOIAF, ggpedigree:::pedigree(ID, dadID, momID, sex))
  withr::local_options(width = 50)
  #  expect_snapshot(kinship2_align.pedigree(ped))
  align <- kinship2_align.pedigree(ped)

  expect_equal(align$n, c(
    41, 74, 94, 128, 97, 41, 14, 12, 20, 17, 11,
    21, 30, 25, 26, 20, 30, 26, 19, 43, 36
  ))

  expect_equal(dim(align$nid), c(21, 128))
  expect_equal(dim(align$pos), c(21, 128))
  expect_equal(dim(align$fam), c(21, 128))
})


test_that("test autohint works with ASOIAF", {
  data("ASOIAF")

  # skip if not the correct data version
  if (!exists("ASOIAF") || !is.data.frame(ASOIAF) || nrow(ASOIAF) != asoiaf_nrow) {
    skip("ASOIAF data not available, or not the correct version")
  }

  df_ASOIAF <- BGmisc::checkParentIDs(ASOIAF,
    addphantoms = TRUE,
    repair = TRUE,
    parentswithoutrow = FALSE,
    repairsex = FALSE
  )

  ped <- with(df_ASOIAF, ggpedigree:::pedigree(ID, dadID, momID, sex))
  newhint <- kinship2_autohint(ped) # this fixes up marriages and such
  plist <- kinship2_align.pedigree(ped,
    packed = TRUE, align = TRUE,
    width = 8, hints = newhint
  )
  expect_equal(plist$n, c(
    41, 74, 94, 128, 97, 41, 14, 12, 20, 17, 11,
    21, 30, 25, 26, 20, 30, 26, 19, 43, 36
  ))
  expect_equal(dim(plist$nid), c(21, 128))
  expect_equal(dim(plist$pos), c(21, 128))
  expect_equal(dim(plist$fam), c(21, 128))
})


test_that("align.pedigree works when packed false ", {
  skip_if_not_installed("kinship2")
  library(kinship2)
  data("sample.ped")
  ped <- with(sample.ped, ggpedigree:::pedigree(id, father, mother, sex))
  withr::local_options(width = 50)
  #  expect_snapshot(kinship2_align.pedigree(ped, packed = FALSE))
  align <- kinship2_align.pedigree(ped, packed = FALSE)
  expect_equal(align$n, c(8, 19, 22, 8))
  expect_equal(dim(align$nid), c(4, 22))
  expect_equal(dim(align$pos), c(4, 22))
  expect_equal(dim(align$fam), c(4, 22))
})

test_that("test autohint works when packed false", {
  library(kinship2)
  data("sample.ped")
  ped <- with(sample.ped, ggpedigree:::pedigree(id, father, mother, sex))
  newhint <- kinship2_autohint(ped, packed = FALSE) # this fixes up marriages and such
  plist <- kinship2_align.pedigree(ped,
    packed = FALSE, align = TRUE,
    width = 8, hints = newhint
  )
  expect_equal(plist$n, c(8, 19, 22, 8))
  expect_equal(dim(plist$nid), c(4, 22))
  expect_equal(dim(plist$pos), c(4, 22))
  expect_equal(dim(plist$fam), c(4, 22))
})


test_that("classic option passes through kinship2_alignped stages with sample.ped", {
  skip_if_not_installed("quadprog")
  skip_if_not_installed("kinship2")
  library(kinship2)

  data("sample.ped")
  ped <- with(sample.ped, ggpedigree:::pedigree(id, father, mother, sex))

  withr::local_options(width = 50)

  classic <- .align_with_alignped_stages(
    ped = ped,
    packed = TRUE,
    width = 10,
    align = TRUE,
    classic = TRUE
  )

  optimized <- .align_with_alignped_stages(
    ped = ped,
    packed = TRUE,
    width = 10,
    align = TRUE,
    classic = FALSE
  )

  expect_align_stage_equal(classic, optimized)

  expect_equal(optimized$n, c(8, 19, 22, 8))
  expect_equal(dim(optimized$nid), c(4, 22))
  expect_equal(dim(optimized$pos), c(4, 22))
  expect_equal(dim(optimized$fam), c(4, 22))
})


test_that("classic option passes through kinship2_alignped stages with sample.ped autohint", {
  skip_if_not_installed("quadprog")
  skip_if_not_installed("kinship2")
  library(kinship2)

  data("sample.ped")
  ped <- with(sample.ped, ggpedigree:::pedigree(id, father, mother, sex))
  newhint <- kinship2_autohint(ped)

  classic <- .align_with_alignped_stages(
    ped = ped,
    packed = TRUE,
    align = TRUE,
    width = 8,
    hints = newhint,
    classic = TRUE
  )

  optimized <- .align_with_alignped_stages(
    ped = ped,
    packed = TRUE,
    align = TRUE,
    width = 8,
    hints = newhint,
    classic = FALSE
  )

  expect_align_stage_equal(classic, optimized)

  expect_equal(optimized$n, c(8, 19, 22, 8))
  expect_equal(dim(optimized$nid), c(4, 22))
  expect_equal(dim(optimized$pos), c(4, 22))
  expect_equal(dim(optimized$fam), c(4, 22))
})


test_that("classic option passes through kinship2_alignped stages with ASOIAF", {
  skip_if_not_installed("quadprog")
  data("ASOIAF")
  # skip if not the correct data version
  if (!exists("ASOIAF") || !is.data.frame(ASOIAF) || nrow(ASOIAF) != asoiaf_nrow) {
    skip("ASOIAF data not available, or not the correct version")
  }

  df_ASOIAF <- BGmisc::checkParentIDs(
    ASOIAF,
    addphantoms = TRUE,
    repair = TRUE,
    parentswithoutrow = FALSE,
    repairsex = FALSE
  )

  ped <- with(df_ASOIAF, ggpedigree:::pedigree(ID, dadID, momID, sex))

  withr::local_options(width = 50)

  classic <- .align_with_alignped_stages(
    ped = ped,
    packed = TRUE,
    width = 10,
    align = TRUE,
    classic = TRUE
  )

  optimized <- .align_with_alignped_stages(
    ped = ped,
    packed = TRUE,
    width = 10,
    align = TRUE,
    classic = FALSE
  )

  expect_align_stage_equal(classic, optimized)

  expect_equal(optimized$n, c(
    41, 74, 94, 129, 97, 41, 14, 12, 20, 17, 11,
    22, 31, 24, 26, 20, 31, 26, 19, 43, 36
  ))
  expect_equal(dim(optimized$nid), c(21, 129))
  expect_equal(dim(optimized$pos), c(21, 129))
  expect_equal(dim(optimized$fam), c(21, 129))
})


test_that("classic option passes through kinship2_alignped stages with ASOIAF autohint", {
  skip_if_not_installed("quadprog")

  data("ASOIAF")
  # skip if not the correct data version
  if (!exists("ASOIAF") || !is.data.frame(ASOIAF) || nrow(ASOIAF) != asoiaf_nrow) {
    skip("ASOIAF data not available, or not the correct version")
  }
  df_ASOIAF <- BGmisc::checkParentIDs(
    ASOIAF,
    addphantoms = TRUE,
    repair = TRUE,
    parentswithoutrow = FALSE,
    repairsex = FALSE
  )

  ped <- with(df_ASOIAF, ggpedigree:::pedigree(ID, dadID, momID, sex))
  newhint <- kinship2_autohint(ped)

  classic <- .align_with_alignped_stages(
    ped = ped,
    packed = TRUE,
    align = TRUE,
    width = 8,
    hints = newhint,
    classic = TRUE
  )

  optimized <- .align_with_alignped_stages(
    ped = ped,
    packed = TRUE,
    align = TRUE,
    width = 8,
    hints = newhint,
    classic = FALSE
  )

  expect_align_stage_equal(classic, optimized)

  expect_equal(optimized$n, c(
    41, 74, 94, 128, 97, 41, 14, 12, 20,
    17, 11, 21, 30, 25, 26, 20, 30, 26, 19, 43, 36
  ))
  expect_equal(dim(optimized$nid), c(21, 128))
  expect_equal(dim(optimized$pos), c(21, 128))
  expect_equal(dim(optimized$fam), c(21, 128))
})


test_that("classic option passes through kinship2_alignped stages when packed is FALSE", {
  skip_if_not_installed("quadprog")
  library(kinship2)

  data("sample.ped")
  ped <- with(sample.ped, ggpedigree:::pedigree(id, father, mother, sex))

  withr::local_options(width = 50)

  classic <- .align_with_alignped_stages(
    ped = ped,
    packed = FALSE,
    width = 10,
    align = TRUE,
    classic = TRUE
  )

  optimized <- .align_with_alignped_stages(
    ped = ped,
    packed = FALSE,
    width = 10,
    align = TRUE,
    classic = FALSE
  )

  expect_align_stage_equal(classic, optimized)

  expect_equal(optimized$n, c(8, 19, 22, 8))
  expect_equal(dim(optimized$nid), c(4, 22))
  expect_equal(dim(optimized$pos), c(4, 22))
  expect_equal(dim(optimized$fam), c(4, 22))
})


test_that("classic option passes through kinship2_alignped stages with autohint when packed is FALSE", {
  skip_if_not_installed("quadprog")
  library(kinship2)

  data("sample.ped")
  ped <- with(sample.ped, ggpedigree:::pedigree(id, father, mother, sex))
  newhint <- kinship2_autohint(ped, packed = FALSE)

  classic <- .align_with_alignped_stages(
    ped = ped,
    packed = FALSE,
    align = TRUE,
    width = 8,
    hints = newhint,
    classic = TRUE
  )

  optimized <- .align_with_alignped_stages(
    ped = ped,
    packed = FALSE,
    align = TRUE,
    width = 8,
    hints = newhint,
    classic = FALSE
  )

  expect_align_stage_equal(classic, optimized)

  expect_equal(optimized$n, c(8, 19, 22, 8))
  expect_equal(dim(optimized$nid), c(4, 22))
  expect_equal(dim(optimized$pos), c(4, 22))
  expect_equal(dim(optimized$fam), c(4, 22))
})


# ── helpers for direct-function unit tests ──────────────────────────────────

# Replicates the setup portion of .align_with_alignped_stages() without
# running any alignment, returning the raw vectors needed to call the
# individual alignped functions directly.
.make_align_inputs <- function(ped, hints = ped$hints) {
  if (is.null(hints)) {
    hints <- try(kinship2_autohint(ped), silent = TRUE)
    if ("try-error" %in% class(hints)) {
      hints <- list(order = seq_len(max(1, dim(ped))))
    }
  } else {
    hints <- kinship2_check.hint(hints, ped$sex)
  }

  n <- length(ped$id)
  dad <- ped$findex
  mom <- ped$mindex
  level <- 1 + kinship2_kindepth(ped, align = TRUE)
  horder <- hints$order

  if (is.null(ped$relation)) {
    relation <- NULL
  } else {
    relation <- cbind(
      as.matrix(ped$relation[, 1:2]),
      as.numeric(ped$relation[, 3])
    )
  }

  if (!is.null(hints$spouse)) {
    tsex <- ped$sex[hints$spouse[, 1]]
    spouselist <- cbind(0, 0, 1 + (tsex != "male"), hints$spouse[, 3])
    spouselist[, 1] <- ifelse(tsex == "male",
      hints$spouse[, 1], hints$spouse[, 2]
    )
    spouselist[, 2] <- ifelse(tsex == "male",
      hints$spouse[, 2], hints$spouse[, 1]
    )
  } else {
    spouselist <- matrix(0L, nrow = 0L, ncol = 4L)
  }

  if (!is.null(relation) && any(relation[, 3] == 4)) {
    trel <- relation[relation[, 3] == 4, , drop = FALSE]
    tsex <- ped$sex[trel[, 1]]
    trel[tsex != "male", 1:2] <- trel[tsex != "male", 2:1]
    spouselist <- rbind(spouselist, cbind(trel[, 1], trel[, 2], 0, 0))
  }

  if (any(dad > 0 & mom > 0)) {
    who <- which(dad > 0 & mom > 0)
    spouselist <- rbind(spouselist, cbind(dad[who], mom[who], 0, 0))
  }

  hash <- spouselist[, 1] * n + spouselist[, 2]
  spouselist <- spouselist[!duplicated(hash), , drop = FALSE]

  noparents <- dad[spouselist[, 1]] == 0 & dad[spouselist[, 2]] == 0
  dupmom <- spouselist[noparents, 2][duplicated(spouselist[noparents, 2])]
  dupdad <- spouselist[noparents, 1][duplicated(spouselist[noparents, 1])]
  foundmom <- spouselist[
    noparents & !(spouselist[, 1] %in% c(dupmom, dupdad)), 2
  ]
  founders <- unique(c(dupmom, dupdad, foundmom))
  founders <- founders[order(horder[founders])]

  list(
    dad = dad, mom = mom, level = level, horder = horder,
    spouselist = spouselist, founders = founders
  )
}


# ── kinship2_alignped3 unit tests (constructed inputs) ───────────────────────

test_that("kinship2_alignped3 classic and optimized are equivalent (packed=TRUE, no overlap)", {
  # x1: couple (1,2) with three children (3,4,5)
  # x2: couple (6,7) with two children (8,9) — no shared subjects
  x1 <- list(
    n   = c(2L, 3L),
    nid = matrix(c(1.5, 2L, 0L, 3L, 4L, 5L), nrow = 2L, byrow = TRUE),
    pos = matrix(c(0.0, 1.0, 0.0, 0.0, 1.0, 2.0), nrow = 2L, byrow = TRUE),
    fam = matrix(c(0L, 0L, 0L, 1L, 1L, 1L), nrow = 2L, byrow = TRUE)
  )
  x2 <- list(
    n   = c(2L, 2L),
    nid = matrix(c(6.5, 7L, 8L, 9L), nrow = 2L, byrow = TRUE),
    pos = matrix(c(0.0, 1.0, 0.0, 1.0), nrow = 2L, byrow = TRUE),
    fam = matrix(c(0L, 0L, 1L, 1L), nrow = 2L, byrow = TRUE)
  )

  classic <- kinship2_alignped3(x1, x2, packed = TRUE, classic = TRUE)
  optimized <- kinship2_alignped3(x1, x2, packed = TRUE, classic = FALSE)

  expect_equal(optimized$n, classic$n)
  expect_equal(optimized$nid, classic$nid)
  expect_equal(optimized$fam, classic$fam)
  expect_equal(optimized$pos, classic$pos)
})


test_that("kinship2_alignped3 classic and optimized are equivalent (packed=FALSE, no overlap)", {
  x1 <- list(
    n   = c(2L, 3L),
    nid = matrix(c(1.5, 2L, 0L, 3L, 4L, 5L), nrow = 2L, byrow = TRUE),
    pos = matrix(c(0.0, 1.0, 0.0, 0.0, 1.0, 2.0), nrow = 2L, byrow = TRUE),
    fam = matrix(c(0L, 0L, 0L, 1L, 1L, 1L), nrow = 2L, byrow = TRUE)
  )
  x2 <- list(
    n   = c(2L, 2L),
    nid = matrix(c(6.5, 7L, 8L, 9L), nrow = 2L, byrow = TRUE),
    pos = matrix(c(0.0, 1.0, 0.0, 1.0), nrow = 2L, byrow = TRUE),
    fam = matrix(c(0L, 0L, 1L, 1L), nrow = 2L, byrow = TRUE)
  )

  classic <- kinship2_alignped3(x1, x2, packed = FALSE, classic = TRUE)
  optimized <- kinship2_alignped3(x1, x2, packed = FALSE, classic = FALSE)

  expect_equal(optimized$n, classic$n)
  expect_equal(optimized$nid, classic$nid)
  expect_equal(optimized$fam, classic$fam)
  expect_equal(optimized$pos, classic$pos)
})


test_that("kinship2_alignped3 classic and optimized are equivalent (packed=TRUE, with subject overlap)", {
  # Subject 2 appears as the last entry in x1 at level 1 AND as the left
  # spouse marker (2.5) in x2.  floor(2.5)==2 triggers the overlap branch;
  # max(2, 2.5) must preserve the .5 spouse marker.
  x1 <- list(
    n   = c(2L, 2L),
    nid = matrix(c(1.5, 2L, 3L, 4L), nrow = 2L, byrow = TRUE),
    pos = matrix(c(0.0, 1.0, 0.0, 1.0), nrow = 2L, byrow = TRUE),
    fam = matrix(c(0L, 0L, 1L, 1L), nrow = 2L, byrow = TRUE)
  )
  x2 <- list(
    n   = c(2L, 2L),
    nid = matrix(c(2.5, 5L, 6L, 7L), nrow = 2L, byrow = TRUE),
    pos = matrix(c(0.0, 1.0, 0.0, 1.0), nrow = 2L, byrow = TRUE),
    fam = matrix(c(0L, 0L, 1L, 1L), nrow = 2L, byrow = TRUE)
  )

  classic <- kinship2_alignped3(x1, x2, packed = TRUE, classic = TRUE)
  optimized <- kinship2_alignped3(x1, x2, packed = TRUE, classic = FALSE)

  expect_equal(optimized$n, classic$n)
  expect_equal(optimized$nid, classic$nid)
  expect_equal(optimized$fam, classic$fam)
  expect_equal(optimized$pos, classic$pos)
})


test_that("kinship2_alignped3 classic and optimized are equivalent (packed=FALSE, with subject overlap)", {
  x1 <- list(
    n   = c(2L, 2L),
    nid = matrix(c(1.5, 2L, 3L, 4L), nrow = 2L, byrow = TRUE),
    pos = matrix(c(0.0, 1.0, 0.0, 1.0), nrow = 2L, byrow = TRUE),
    fam = matrix(c(0L, 0L, 1L, 1L), nrow = 2L, byrow = TRUE)
  )
  x2 <- list(
    n   = c(2L, 2L),
    nid = matrix(c(2.5, 5L, 6L, 7L), nrow = 2L, byrow = TRUE),
    pos = matrix(c(0.0, 1.0, 0.0, 1.0), nrow = 2L, byrow = TRUE),
    fam = matrix(c(0L, 0L, 1L, 1L), nrow = 2L, byrow = TRUE)
  )

  classic <- kinship2_alignped3(x1, x2, packed = FALSE, classic = TRUE)
  optimized <- kinship2_alignped3(x1, x2, packed = FALSE, classic = FALSE)

  expect_equal(optimized$n, classic$n)
  expect_equal(optimized$nid, classic$nid)
  expect_equal(optimized$fam, classic$fam)
  expect_equal(optimized$pos, classic$pos)
})


# ── kinship2_alignped1 unit tests ────────────────────────────────────────────

test_that("kinship2_alignped1 classic and optimized are equivalent on minimal pedigree (packed=TRUE)", {
  # 4-subject pedigree: father(1) + mother(2) -> child(3) + child(4)
  dad <- c(0L, 0L, 1L, 1L)
  mom <- c(0L, 0L, 2L, 2L)
  level <- c(1L, 1L, 2L, 2L)
  horder <- c(1.0, 2.0, 1.0, 2.0)
  spouselist <- matrix(c(1L, 2L, 0L, 0L), nrow = 1L, ncol = 4L)

  classic <- kinship2_alignped1(1L, dad, mom, level, horder,
    packed = TRUE, spouselist, classic = TRUE
  )
  optimized <- kinship2_alignped1(1L, dad, mom, level, horder,
    packed = TRUE, spouselist, classic = FALSE
  )

  expect_equal(optimized$n, classic$n)
  expect_equal(optimized$nid, classic$nid)
  expect_equal(optimized$fam, classic$fam)
  expect_equal(optimized$pos, classic$pos, tolerance = 1e-8)
  expect_equal(nrow(optimized$spouselist), nrow(classic$spouselist))
})


test_that("kinship2_alignped1 classic and optimized are equivalent on minimal pedigree (packed=FALSE)", {
  dad <- c(0L, 0L, 1L, 1L)
  mom <- c(0L, 0L, 2L, 2L)
  level <- c(1L, 1L, 2L, 2L)
  horder <- c(1.0, 2.0, 1.0, 2.0)
  spouselist <- matrix(c(1L, 2L, 0L, 0L), nrow = 1L, ncol = 4L)

  classic <- kinship2_alignped1(1L, dad, mom, level, horder,
    packed = FALSE, spouselist, classic = TRUE
  )
  optimized <- kinship2_alignped1(1L, dad, mom, level, horder,
    packed = FALSE, spouselist, classic = FALSE
  )

  expect_equal(optimized$n, classic$n)
  expect_equal(optimized$nid, classic$nid)
  expect_equal(optimized$fam, classic$fam)
  expect_equal(optimized$pos, classic$pos, tolerance = 1e-8)
})


test_that("kinship2_alignped1 classic and optimized are equivalent on sample.ped (packed=TRUE)", {
  library(kinship2)
  data("sample.ped")
  ped <- with(sample.ped, ggpedigree:::pedigree(id, father, mother, sex))
  inputs <- .make_align_inputs(ped)
  f1 <- inputs$founders[1]

  classic <- kinship2_alignped1(f1, inputs$dad, inputs$mom, inputs$level,
    inputs$horder,
    packed = TRUE,
    inputs$spouselist, classic = TRUE
  )
  optimized <- kinship2_alignped1(f1, inputs$dad, inputs$mom, inputs$level,
    inputs$horder,
    packed = TRUE,
    inputs$spouselist, classic = FALSE
  )

  expect_equal(optimized$n, classic$n)
  expect_equal(optimized$nid, classic$nid)
  expect_equal(optimized$fam, classic$fam)
  expect_equal(optimized$pos, classic$pos, tolerance = 1e-8)
  expect_equal(nrow(optimized$spouselist), nrow(classic$spouselist))
})


test_that("kinship2_alignped1 classic and optimized are equivalent on sample.ped (packed=FALSE)", {
  library(kinship2)
  data("sample.ped")
  ped <- with(sample.ped, ggpedigree:::pedigree(id, father, mother, sex))
  inputs <- .make_align_inputs(ped)
  f1 <- inputs$founders[1]

  classic <- kinship2_alignped1(f1, inputs$dad, inputs$mom, inputs$level,
    inputs$horder,
    packed = FALSE,
    inputs$spouselist, classic = TRUE
  )
  optimized <- kinship2_alignped1(f1, inputs$dad, inputs$mom, inputs$level,
    inputs$horder,
    packed = FALSE,
    inputs$spouselist, classic = FALSE
  )

  expect_equal(optimized$n, classic$n)
  expect_equal(optimized$nid, classic$nid)
  expect_equal(optimized$fam, classic$fam)
  expect_equal(optimized$pos, classic$pos, tolerance = 1e-8)
})


# ── kinship2_alignped2 unit tests ────────────────────────────────────────────

test_that("kinship2_alignped2 classic and optimized are equivalent on minimal pedigree (packed=TRUE)", {
  # 5-subject pedigree: father(1) + mother(2) -> three siblings (3,4,5)
  dad <- c(0L, 0L, 1L, 1L, 1L)
  mom <- c(0L, 0L, 2L, 2L, 2L)
  level <- c(1L, 1L, 2L, 2L, 2L)
  horder <- c(1.0, 2.0, 1.0, 2.0, 3.0)
  spouselist <- matrix(c(1L, 2L, 0L, 0L), nrow = 1L, ncol = 4L)

  classic <- kinship2_alignped2(c(3L, 4L, 5L), dad, mom, level, horder,
    packed = TRUE, spouselist, classic = TRUE
  )
  optimized <- kinship2_alignped2(c(3L, 4L, 5L), dad, mom, level, horder,
    packed = TRUE, spouselist, classic = FALSE
  )

  expect_equal(optimized$n, classic$n)
  expect_equal(optimized$nid, classic$nid)
  expect_equal(optimized$fam, classic$fam)
  expect_equal(optimized$pos, classic$pos, tolerance = 1e-8)
})


test_that("kinship2_alignped2 classic and optimized are equivalent on minimal pedigree (packed=FALSE)", {
  dad <- c(0L, 0L, 1L, 1L, 1L)
  mom <- c(0L, 0L, 2L, 2L, 2L)
  level <- c(1L, 1L, 2L, 2L, 2L)
  horder <- c(1.0, 2.0, 1.0, 2.0, 3.0)
  spouselist <- matrix(c(1L, 2L, 0L, 0L), nrow = 1L, ncol = 4L)

  classic <- kinship2_alignped2(c(3L, 4L, 5L), dad, mom, level, horder,
    packed = FALSE, spouselist, classic = TRUE
  )
  optimized <- kinship2_alignped2(c(3L, 4L, 5L), dad, mom, level, horder,
    packed = FALSE, spouselist, classic = FALSE
  )

  expect_equal(optimized$n, classic$n)
  expect_equal(optimized$nid, classic$nid)
  expect_equal(optimized$fam, classic$fam)
  expect_equal(optimized$pos, classic$pos, tolerance = 1e-8)
})


test_that("kinship2_alignped2 classic and optimized are equivalent on sample.ped (packed=TRUE)", {
  library(kinship2)
  data("sample.ped")
  ped <- with(sample.ped, ggpedigree:::pedigree(id, father, mother, sex))
  inputs <- .make_align_inputs(ped)
  f1 <- inputs$founders[1]

  r1 <- kinship2_alignped1(f1, inputs$dad, inputs$mom, inputs$level,
    inputs$horder,
    packed = TRUE,
    inputs$spouselist, classic = TRUE
  )
  sibs <- which((inputs$dad == f1 | inputs$mom == f1) &
    inputs$level == inputs$level[f1] + 1L)
  skip_if(length(sibs) == 0L, "No children found for first founder")

  classic <- kinship2_alignped2(sibs, inputs$dad, inputs$mom, inputs$level,
    inputs$horder,
    packed = TRUE,
    r1$spouselist, classic = TRUE
  )
  optimized <- kinship2_alignped2(sibs, inputs$dad, inputs$mom, inputs$level,
    inputs$horder,
    packed = TRUE,
    r1$spouselist, classic = FALSE
  )

  expect_equal(optimized$n, classic$n)
  expect_equal(optimized$nid, classic$nid)
  expect_equal(optimized$fam, classic$fam)
  expect_equal(optimized$pos, classic$pos, tolerance = 1e-8)
})


test_that("kinship2_alignped2 classic and optimized are equivalent on sample.ped (packed=FALSE)", {
  library(kinship2)
  data("sample.ped")
  ped <- with(sample.ped, ggpedigree:::pedigree(id, father, mother, sex))
  inputs <- .make_align_inputs(ped)
  f1 <- inputs$founders[1]

  r1 <- kinship2_alignped1(f1, inputs$dad, inputs$mom, inputs$level,
    inputs$horder,
    packed = FALSE,
    inputs$spouselist, classic = TRUE
  )
  sibs <- which((inputs$dad == f1 | inputs$mom == f1) &
    inputs$level == inputs$level[f1] + 1L)
  skip_if(length(sibs) == 0L, "No children found for first founder")

  classic <- kinship2_alignped2(sibs, inputs$dad, inputs$mom, inputs$level,
    inputs$horder,
    packed = FALSE,
    r1$spouselist, classic = TRUE
  )
  optimized <- kinship2_alignped2(sibs, inputs$dad, inputs$mom, inputs$level,
    inputs$horder,
    packed = FALSE,
    r1$spouselist, classic = FALSE
  )

  expect_equal(optimized$n, classic$n)
  expect_equal(optimized$nid, classic$nid)
  expect_equal(optimized$fam, classic$fam)
  expect_equal(optimized$pos, classic$pos, tolerance = 1e-8)
})


# ── alignped1 -> alignped3 intermediate merge test ───────────────────────────

test_that("kinship2_alignped3 classic and optimized agree on real pedigree-derived x1/x2 (sample.ped)", {
  library(kinship2)
  data("sample.ped")
  ped <- with(sample.ped, ggpedigree:::pedigree(id, father, mother, sex))
  inputs <- .make_align_inputs(ped)

  skip_if(length(inputs$founders) < 2L, "Need at least two founder groups")

  # Build x1 and x2 via the classic path so both merge calls start from
  # identical inputs, isolating alignped3 behaviour.
  x1 <- kinship2_alignped1(inputs$founders[1], inputs$dad, inputs$mom,
    inputs$level, inputs$horder,
    packed = TRUE,
    inputs$spouselist, classic = TRUE
  )
  x2 <- kinship2_alignped1(inputs$founders[2], inputs$dad, inputs$mom,
    inputs$level, inputs$horder,
    packed = TRUE,
    x1$spouselist, classic = TRUE
  )

  classic <- kinship2_alignped3(x1, x2, packed = TRUE, classic = TRUE)
  optimized <- kinship2_alignped3(x1, x2, packed = TRUE, classic = FALSE)

  expect_equal(optimized$n, classic$n)
  expect_equal(optimized$nid, classic$nid)
  expect_equal(optimized$fam, classic$fam)
  expect_equal(optimized$pos, classic$pos, tolerance = 1e-8)
})
