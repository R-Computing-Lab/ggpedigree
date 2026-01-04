test_that("simulated pedigree plots correctly", {
  library(BGmisc)
  library(kinship2)
  set.seed(5)
  Ngen <- 4
  kpc <- 4
  sexR <- .50
  marR <- .7

  results <- simulatePedigree(kpc = kpc, Ngen = Ngen, sexR = sexR, marR = marR)

  expect_no_error(kinship2_plotPedigree(results, verbose = FALSE))

  kpc <- 2
  results2 <- simulatePedigree(kpc = kpc, Ngen = Ngen, sexR = sexR, marR = marR)
  results2$fam <- paste0("fam 2")
  results <- rbind(results, results2)
  expect_output(kinship2_plotPedigree(results, verbose = TRUE))
})


test_that("pedigree plots correctly with affected variables", {
  library(BGmisc)
  set.seed(5)
  Ngen <- 4
  kpc <- 4
  sexR <- .50
  marR <- .7

  results <- BGmisc::simulatePedigree(kpc = kpc, Ngen = Ngen, sexR = sexR, marR = marR)
  affected <- rbinom(
    n = nrow(results),
    size = 1, prob = .1
  )
  expect_error(kinship2_plotPedigree(results, verbose = TRUE, affected = affected[1:10]))
  results$affected <- affected
  expect_output(kinship2_plotPedigree(results, verbose = TRUE, affected = "affected"))
  expect_output(kinship2_plotPedigree(results, verbose = TRUE, affected = results$affected))

  # file.remove("Rplots.pdf")
})
# file.remove("Rplots.pdf")

test_that("pedigree errs when affected variables named", {
  library(BGmisc)
  data(inbreeding)

  expect_error(kinship2_plotPedigree(data, verbose = TRUE, affected = "affected"))
})


test_that("pedigree plots multiple families", {
  library(BGmisc)
  data(inbreeding)
  plotPedigree(inbreeding, verbose = TRUE)
  expect_message(kinship2_plotPedigree(inbreeding, verbose = TRUE))
})
