test_that("test that data loads", {
  library(ggpedigree)
  expect_true(exists("redsquirrels"))
  expect_true(is.data.frame(redsquirrels))
  expect_true(nrow(redsquirrels) > 0)
  expect_true(ncol(redsquirrels) > 0)
  expect_true(all(c("ars_max", "ars_med", "ars_min", "ars_sd", "ars_n", "year_first", "year_last") %in% names(redsquirrels)))
})
