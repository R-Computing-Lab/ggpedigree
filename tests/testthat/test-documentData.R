test_that("data loads silently", {
  expect_silent(data(redsquirrels))
  expect_silent(data(ASOIAF))
})


test_that("test that data loads", {
  library(ggpedigree)
  expect_true(exists("redsquirrels"))
  expect_true(is.data.frame(redsquirrels))
  expect_true(nrow(redsquirrels) > 0)
  expect_true(ncol(redsquirrels) > 0)
  expect_true(all(c("ars_max", "ars_med", "ars_min", "ars_sd", "ars_n", "year_first", "year_last") %in% names(redsquirrels)))
})

test_that("ASOIAF data loads", {
  expect_silent(data(ASOIAF))
  expect_true(nrow(ASOIAF) > 600)
  expect_true(nrow(ASOIAF) == max(ASOIAF$id, na.rm = TRUE))
  checkis_acyclic <- BGmisc::checkPedigreeNetwork(ASOIAF,
    personID = "id",
    momID = "momID",
    dadID = "dadID",
    verbose = TRUE
  )
  expect_true(checkis_acyclic$is_acyclic)

  ggped <- ggPedigree(ASOIAF,
    famID = "famID",
    personID = "id",
    momID = "momID",
    dadID = "dadID",
    config = list(
      add_phantoms = TRUE,
      code_male = "M"
    )
  )
  expect_true(inherits(ggped, "ggplot"))
})
