
expect_roundtrip <- function(df,
                             cols = c("personID", "momID", "dadID", "sex"),
                             NA_id_value = NA,
                             expect_warnings = FALSE
                             ) {

  if (expect_warnings) {
    expect_warning(ggPedigree(df), NA)
    ped_df <- suppressWarnings(ggPedigree(df, config = list(debug = TRUE)))
    ped_df <- ped_df[["data"]]
  } else {
    expect_silent(ggPedigree(df))
    ped_df <- ggPedigree(df, config = list(debug = TRUE))[["data"]]
  }


  if (!is.na(NA_id_value)) {
    df$momID[df$momID == NA_id_value] <- NA
    df$dadID[df$dadID == NA_id_value] <- NA
  }
  expect_equal(ped_df[, cols, drop = FALSE],
               df[, cols, drop = FALSE],
               ignore_attr = TRUE)

  expect_equal(nrow(ped_df), nrow(df))

  expect_no_error(ggPedigree(df) %>% suppressWarnings())
}
# still dealing with elegant handling of sex repair that doesn't break existing functionality
case_char <- function(sex = c(0,1,0),
                      missing_parent= NA_character_
                      ) {
  data.frame(
  personID = c("1","2","3"),
  momID = c(missing_parent, missing_parent, "1"),
  dadID = c(missing_parent, missing_parent, "2"),
  sex = sex
)
}
case_num <- function(sex=c(0,1,0),
                     missing_parent = NA_real_
                     ) {
  data.frame(
  personID = 1:3,
  dadID = c(missing_parent, missing_parent, 1),
  momID = c(missing_parent, missing_parent, 2),
  sex = sex
)
}


test_that("char ids; 0 missingid; 1/2",  {
  expect_roundtrip(case_char(c(2,1,2),"0"), NA_id_value = "0")
#  Error in `pedigree(id = ped[[personID]], dadid = ped[[dadID]], momid = ped[[momID]], sex = ped_recode[[sexVar]])`: Id not male, but is a father: 2
})
test_that("char ids; 0 missingid; 1/2 + NA", {
  expect_roundtrip(case_char(c(2,1,NA), "0"), NA_id_value = "0", expect_warnings= TRUE)
  })
test_that("char ids; 0 missingid; 0/1",{
  expect_roundtrip(case_char(c(1,0,1),  "0"), NA_id_value = "0")
})
test_that("char ids; 0 missingid; 0/1 + NA",{
  expect_roundtrip(case_char(c(1,0,NA), "0"), NA_id_value = "0")
})

test_that("char ids; NA missingid; 0/1",{
  expect_roundtrip(case_char(c(1,0,1),  NA_character_))
})
test_that("char ids; NA missingid; 0/1 + NA",{
  expect_roundtrip(case_char(c(1,0,NA), NA_character_))
})
test_that("char ids; NA missingid; 1/2 + NA",{
  expect_roundtrip(case_char(c(2,1,NA), NA_character_))
})

test_that("num ids; 0 missingid; 1/2",{     expect_roundtrip(case_num(c(2,1,2),  0), NA_id_value = 0)
          })
test_that("num ids; 0 missingid; 1/2 + NA", {expect_roundtrip(case_num(c(2,1,NA), 0), NA_id_value = 0)
          })
test_that("num ids; 0 missingid; 0/1",   { expect_roundtrip(case_num(c(1,0,1),  0), NA_id_value = 0)
          })
test_that("num ids; 0 missingid; 0/1 + NA", {expect_roundtrip(case_num(c(1,0,NA), 0), NA_id_value = 0)
          })

test_that("num ids; NA missingid; 0/1", {expect_roundtrip(case_num(c(1,0,1), NA))
          })
test_that("num ids; NA missingid; 0/1 + NA",{ expect_roundtrip(case_num(c(1,0,NA), NA))
          })
test_that("num ids; NA missingid; 1/2 + NA", {expect_roundtrip(case_num(c(2,1,NA), NA))
          })



