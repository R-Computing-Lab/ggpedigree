test_that("kinship2_bitSize works", {
  ped <- pedigree(
    id = 1:5, dadid = c(0, 0, 1, 1, 1),
    momid = c(0, 0, 2, 2, 2),
    sex = c(1, 2, 1, 2, 1)
  )

  results <- kinship2_bitSize(ped)

  expect_equal(results$bitSize, 4)
  expect_equal(results$nFounder, 2)
  expect_equal(results$nNonFounder, 3)
  expect_equal((results$nFounder + results$nNonFounder), length(ped$id))
})
