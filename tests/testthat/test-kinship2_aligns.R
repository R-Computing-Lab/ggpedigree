test_that("align.pedigree works", {
  library(kinship2)
  data("sample.ped")
  ped <- with(sample.ped, ggpedigree:::pedigree(id, father, mother, sex))
  withr::local_options(width = 50)
  expect_snapshot(kinship2_align.pedigree(ped))
  align <- kinship2_align.pedigree(ped)
  expect_equal(align$n, c(8, 19, 22, 8))
})

test_that("test autohint works", {
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
