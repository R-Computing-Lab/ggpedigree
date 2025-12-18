# Tests for ggPedigree data input handling
sex_map <- list(
  s212 = c(2, 1, 2),
  s21NA = c(2, 1, NA),
  s121 = c(1, 2, 1),
  s12NA = c(1, 2, NA),
  s101 = c(1, 0, 1),
  s10NA = c(1, 0, NA),
  s01NA = c(0, 1, NA),
  s010 = c(0, 1, 0)
)

id_map_char <- list(
  id_char = c("1", "2", "3"),
  id_char_alpha = c("a", "b", "c")
)
id_map_num <- list(
  id_num = c(1, 2, 3)
)
missing_parent_char <- list(
  mp_char_0 = "0",
  mp_char_empty = "",
  mp_char_NA = NA_character_
)

missing_parent_num <- list(
  mp_num_0   = 0,
  mp_num_NA  = NA_real_
)

config_map <- list(
  cfg_skip = "cfg_skip",
  cfg_dbg = list(debug = TRUE),
  cfg_m2 = list(code_male = 2),
  cfg_m1 = list(code_male = 1),
  cfg_m0 = list(code_male = 0)
)

# 1) Create a full cross product of "dimensions"
grid_char <- expand.grid(
  id_type = "char",
  id_case = names(id_map_char),
  missing_parent = names(missing_parent_char),
  sex_case = names(sex_map),
  config_case = names(config_map),
  stringsAsFactors = FALSE
)
grid_num <- expand.grid(
  id_type = "num",
  id_case = names(id_map_num),
  missing_parent = names(missing_parent_num),
  sex_case = names(sex_map),
  config_case = names(config_map),
  stringsAsFactors = FALSE
)

# Combine character and numeric grids
grid <- rbind(grid_char, grid_num)
# 2) Define exceptions where warnings or errors are expected

grid$expect_warnings <- FALSE
grid$expect_errors <- FALSE

grid <- grid %>% mutate(
  expect_warnings = case_when(
    sex_case %in% c("s12NA", "s10NA", "s01NA", "s21NA") ~ TRUE,
    TRUE ~ expect_warnings
  ),
  expect_errors = case_when(
    config_case %in% c("cfg_skip", "cfg_dbg", "cfg_m1") &
      sex_case %in% c("s121", "s101", "s10NA", "s12NA") ~ TRUE,
    # cfg_m2 fixes 1/2 but not 0/1
    config_case == "cfg_m2" &
      sex_case %in% c("s101", "s10NA", "s212", "s21NA", "s01NA", "s010") ~ TRUE,
    # cfg_m0 fixes 0/1 but not 1/2
    config_case == "cfg_m0" &
      sex_case %in% c("s121", "s12NA", "s212", "s21NA", "s01NA", "s010") ~ TRUE,
    TRUE ~ expect_errors
  )
)


expect_roundtrip <- function(
  df,
  cols = c("personID", "momID", "dadID", "sex"),
  NA_id_value = NA,
  expect_warnings = FALSE,
  expect_errors = FALSE,
  config = list(debug = TRUE),
  info = NULL
) {
  run_ped <- function() {
    if (is.null(config) || config == "cfg_skip") ggPedigree(df) else ggPedigree(df, config = config)
  }

  if (expect_errors && expect_warnings) {
    expect_warning(expect_error(run_ped(), info = info), info = info)
    return(invisible(NULL))
  }
  if (expect_errors) {
    expect_error(run_ped(), info = info)
    return(invisible(NULL))
  }

  if (expect_warnings) {
    expect_warning(run_ped(), info = info)
    ped_df <- suppressWarnings(run_ped())[["data"]]
  } else {
    expect_no_warning(run_ped())
    ped_df <- run_ped()[["data"]]
  }


  if (!is.na(NA_id_value)) {
    df$momID[df$momID == NA_id_value] <- NA
    df$dadID[df$dadID == NA_id_value] <- NA
  }

  expect_equal(ped_df[, cols, drop = FALSE], df[, cols, drop = FALSE],
    ignore_attr = TRUE, info = info
  )
  expect_equal(nrow(ped_df), nrow(df), info = info)

  invisible(NULL)
}

# still dealing with elegant handling of sex repair that doesn't break existing functionality

make_df <- function(person_ids,
                    mom_id,
                    dad_id,
                    sex = c(0, 1, 0),
                    missing_parent = NA_character_) {
  data.frame(
    personID = person_ids,
    momID = c(missing_parent, missing_parent, mom_id),
    dadID = c(missing_parent, missing_parent, dad_id),
    sex = sex
  )
}
make_df_char <- function(sex = c(0, 1, 0),
                         missing_parent = NA_character_,
                         person_ids = c("1", "2", "3"),
                         mom_id = "1",
                         dad_id = "2") {
  make_df(
    person_ids = person_ids,
    mom_id = mom_id,
    dad_id = dad_id,
    sex = sex,
    missing_parent = missing_parent
  )
}


make_df_num <- function(sex = c(0, 1, 0),
                        missing_parent = NA_real_,
                        person_ids = 1:3,
                        mom_id = 1,
                        dad_id = 2) {
  make_df(
    person_ids = person_ids,
    mom_id = mom_id,
    dad_id = dad_id,
    sex = sex,
    missing_parent = missing_parent
  )
}




test_that("full cross: strict expectations + roundtrip invariant", {
  for (i in seq_len(nrow(grid))) {
    row <- grid[i, ]

    sex <- sex_map[[row$sex_case]]
    cfg <- config_map[[row$config_case]]


    mp <- if (row$id_type == "char") missing_parent_char[[row$missing_parent]] else missing_parent_num[[row$missing_parent]]
    df <- if (row$id_type == "char") {
      make_df_char(sex = sex, missing_parent = mp)
    } else {
      make_df_num(sex = sex, missing_parent = mp)
    }


    info <- paste0(
      "id_type=", row$id_type,
      " mp=", row$missing_parent,
      " sex=", row$sex_case,
      " cfg=", row$config_case
    )

    tryCatch(expect_roundtrip(
      df,
      NA_id_value = mp,
      expect_warnings = row$expect_warnings,
      expect_errors = row$expect_errors,
      config = cfg,
      info = info
    ), error = function(e) {
      stop(paste0("Failed test with info: ", info, "\n", e$message))
    })
  }
})




# Tests for various error conditions
test_that("errors for character ids", {
  df <- data.frame(
    personID = c("a", "b", "c"), dadID = c(NA, NA, "a"),
    momID = c(NA, NA, "b"), sex = c(1, 0, 1)
  )
  expect_silent(ggPedigree(df))
  # Warning message: from bgmisc
  # In data.frame(V1 = as.numeric(names(wcc$membership)), V2 = wcc$membership) :
  #   NAs introduced by coercion

  # in bgmisc from non-numeric ID strings
})
