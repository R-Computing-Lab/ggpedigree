library(dplyr)
library(tidyr)
library(purrr)
library(psych)

result_lrs_icc_adjusted <- dataRelatedPair_merge %>%
  # Stack both members' data into a long form: personID + trait value
  select(addRel_factor, mitRel, cnuRel, ID1, ID2, lrs_k1, lrs_k2) %>%
  pivot_longer(
    cols = c(ID1, ID2, lrs_k1, lrs_k2),
    names_to = c(".value", "k"),
    names_pattern = "(ID|lrs)_(k[12])"
  ) %>%
  rename(personID = ID) %>%
  filter(!is.na(lrs)) %>%
  group_by(addRel_factor, mitRel, cnuRel) %>%
  group_nest() %>%
  mutate(
    # Compute ICC(1) for each relatedness bin
    icc = map_dbl(data, function(df) {
      wide <- df %>%
        group_by(personID) %>%
        mutate(obs = row_number()) %>%
        ungroup() %>%
        pivot_wider(id_cols = personID, names_from = obs, values_from = lrs)

      datamat <- wide %>% select(-personID)
      datamat <- datamat[rowSums(!is.na(datamat)) > 1, , drop = FALSE]

      if (nrow(datamat) >= 2) {
        psych::ICC(datamat)$results %>%
          filter(type == "ICC1") %>%
          pull(ICC)
      } else {
        NA_real_
      }
    }),
    # Compute average number of lrs observations per person
    avg_m = map_dbl(data, ~ .x %>%
      count(personID) %>%
      summarise(mean(n)) %>%
      pull()),
    # Join to your existing correlation results
    .keep = "unused"
  ) %>%
  right_join(result, by = c("addRel_factor", "mitRel" = "mtdna", "cnuRel" = "cnu")) %>%
  mutate(
    se_lrs_raw = cor_lrs / cor_lrs_stat,
    cor_lrs_se_adj = adjust_se_by_icc(se_lrs_raw, icc, avg_m),
    cor_lrs_ci_lb_adj = cor_lrs - 1.96 * cor_lrs_se_adj,
    cor_lrs_ci_ub_adj = cor_lrs + 1.96 * cor_lrs_se_adj
  )

compute_icc1_from_long <- function(df, person_col = "personID", value_col = "value") {
  wide <- df %>%
    filter(!is.na(.data[[value_col]])) %>%
    group_by(.data[[person_col]]) %>%
    mutate(obs = row_number()) %>%
    ungroup() %>%
    pivot_wider(
      id_cols = .data[[person_col]],
      names_from = .data$obs,
      values_from = .data[[value_col]]
    )

  datamat <- wide %>% select(-all_of(person_col))
  datamat <- datamat[rowSums(!is.na(datamat)) > 1, , drop = FALSE]

  if (nrow(datamat) >= 2) {
    icc_out <- psych::ICC(datamat)
    return(icc_out$results[icc_out$results$type == "ICC1", "ICC"])
  } else {
    return(NA_real_)
  }
}

compute_avg_m_from_long <- function(df, person_col = "personID", value_col = "value") {
  df %>%
    filter(!is.na(.data[[value_col]])) %>%
    count(.data[[person_col]]) %>%
    summarise(avg_m = mean(n)) %>%
    pull(.data$avg_m)
}
adjust_se_by_icc <- function(se_raw, icc, avg_m) {
  if (is.na(se_raw) || is.na(icc) || is.na(avg_m)) {
    return(NA_real_)
  }
  design_effect <- 1 + (avg_m - 1) * icc
  se_raw * sqrt(design_effect)
}



extract_person_trait_long <- function(df, trait) {
  # Extracts personID and trait values from *_k1 and *_k2
  id_col1 <- sym("ID1")
  id_col2 <- sym("ID2")
  trait_k1 <- sym(paste0(trait, "_k1"))
  trait_k2 <- sym(paste0(trait, "_k2"))

  df %>%
    select(addRel_factor, mitRel, cnuRel, !!id_col1, !!id_col2, !!trait_k1, !!trait_k2) %>%
    pivot_longer(
      cols = c(!!id_col1, !!id_col2, !!trait_k1, !!trait_k2),
      names_to = c(".value", "k"),
      names_pattern = paste0("(", trait, "|ID)_(k[12])")
    ) %>%
    rename(personID = ID)
}
