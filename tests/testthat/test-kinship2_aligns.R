test_that("align.pedigree works with sample ped", {
  library(kinship2)
  data("sample.ped")
  ped <- with(sample.ped, ggpedigree:::pedigree(id, father, mother, sex))
  withr::local_options(width = 50)
  # expect_snapshot(kinship2_align.pedigree(ped))
  align <- kinship2_align.pedigree(ped)

  expect_equal(align$n, c(8, 19, 22, 8))
  expect_equal(dim(align$nid), c(4, 22))
  expect_equal(dim(align$pos), c(4, 22))
  expect_equal(dim(align$fam), c(4, 22))
})

test_that("test autohint works with sample.ped", {
  library(kinship2)
  data("sample.ped")
  ped <- with(sample.ped, ggpedigree:::pedigree(id, father, mother, sex))
  newhint <- kinship2_autohint(ped) # this fixes up marriages and such
  plist <- kinship2_align.pedigree(ped,
    packed = TRUE, align = TRUE,
    width = 8, hints = newhint
  )
  expect_snapshot(plist)
})

test_that("align.pedigree works with ASOIAF", {
  data("ASOIAF")
  df_ASOIAF <- BGmisc::checkParentIDs(ASOIAF,
    addphantoms = TRUE,
    repair = TRUE,
    parentswithoutrow = FALSE,
    repairsex = FALSE
  )

  ped <- with(df_ASOIAF, ggpedigree:::pedigree(ID, dadID, momID, sex))
  withr::local_options(width = 50)
  # expect_snapshot(kinship2_align.pedigree(ped))
  align <- kinship2_align.pedigree(ped)

  expect_equal(align$n, c(
    34, 63, 68, 52, 22, 11, 19, 37, 93,
    92, 41, 23, 30, 24, 26, 20, 30, 26, 19, 43, 36
  ))
  expect_equal(dim(align$nid), c(21, 93))
  expect_equal(dim(align$pos), c(21, 93))
  expect_equal(dim(align$fam), c(21, 93))
})


test_that("test autohint works with ASOIAF", {
  data("ASOIAF")
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
  expect_snapshot(plist)
})



test_that("align.pedigree works when packed false ", {
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
  expect_snapshot(plist)
})
