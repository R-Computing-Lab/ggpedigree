test_that("checking the input a bit more thoroughly", {
  df = data.frame(personID = c("1", "2", "3"), momID = c(NA, NA, "1"),
                  dadID = c(NA, NA, "2"), sex = c(2, 1, 2))
  df
  #>   personID momID dadID sex
  #> 1        1  <NA>  <NA>   2
  #> 2        2  <NA>  <NA>   1
  #> 3        3     1     2   2
  ggPedigree(df,config = list(debug=TRUE))
  expect_no_error(ggPedigree(df))

  #> Error in `dplyr::mutate()`:
  #> ℹ In argument: `couple_hash = .makeSymmetricKey(.data$personID,
  #>   .data$spouseID)`.
  #> Caused by error in `.makeSymmetricKey()`:
  #> ! id1 and id2 must be of the same type. id1 is numeric and id2 is character
})
test_that("checking the input a bit more thoroughly", {
  df = data.frame(personID = c("1", "2", "3"), momID = c(NA, NA, "1"),
                  dadID = c(NA, NA, "2"), sex = c(0, 1, 0))
  df
  #>   personID momID dadID sex
  #>   1        1  <NA>  <NA>   0
  #>   2        2  <NA>  <NA>   1
  #>   3        3     1     2   0
  ggPedigree(df,config = list(debug=TRUE))
  expect_no_error(ggPedigree(df))
#  ebug mode is ON. Debugging information will be printed.
 # Coordinates calculated. Number of individuals: 3
#  NA types - personID: numeric, momID: character, dadID: character
  #> Error in `dplyr::mutate()`:
  #> ℹ In argument: `couple_hash = .makeSymmetricKey(.data$personID,
  #>   .data$spouseID)`.
  #> Caused by error in `.makeSymmetricKey()`:
  #> ! id1 and id2 must be of the same type. id1 is numeric and id2 is character
})
