calculateConnections2 <- function(ped) {
  # Create connections based on parent-child relationships
  connections <- ped %>%
    select(personID, x_pos, y_pos, dadID, momID)

  # Separate mom and dad coordinates
  mom_connections <- connections %>%
    dplyr::filter(!is.na(momID)) %>%
    left_join(ped, by = c("momID" = "personID"), suffix = c("", "_mom")) %>%
    rename(x_mom = x_pos_mom, y_mom = y_pos_mom) %>%
    select(personID, momID, x_mom, y_mom)

  dad_connections <- connections %>%
    dplyr::filter(!is.na(dadID)) %>%
    left_join(ped, by = c("dadID" = "personID"), suffix = c("", "_dad")) %>%
    rename(x_dad = x_pos_dad, y_dad = y_pos_dad) %>%
    select(personID, dadID, x_dad, y_dad)

  spouse_connections <- ped %>%
    select(personID, x_pos, y_pos, spouseID) %>%
    left_join(ped, by = c("spouseID" = "personID"), suffix = c("", "_spouse")) %>%
    rename(x_spouse = x_pos_spouse, y_spouse = y_pos_spouse) %>%
    select(personID, spouseID, x_spouse, y_spouse)

  # Combine mom and dad connections with the original dataset
  connections <- connections %>%
    left_join(mom_connections) %>%
    left_join(dad_connections)

  # Create midpoints for parents
  parent_midpoints <- connections %>%
    dplyr::filter(!is.na(dadID) & !is.na(momID)) %>%
    group_by(dadID, momID) %>%
    summarize(
      x_midparent = mean(c(first(x_dad), first(x_mom))),
      y_midparent = mean(c(first(y_dad), first(y_mom))) - 0.5,
      .groups = 'drop'
    )

  # Calculate midpoints for siblings
  sibling_midpoints <- connections %>%
    group_by(dadID, momID) %>%
    summarize(
      x_mid_sib = mean(x_pos),
      y_mid_sib = first(y_pos) - 0.5,
      .groups = 'drop'
    )


  # Merge midpoints back to connections
  connections <- connections %>%
    left_join(parent_midpoints, by = c("dadID", "momID")) %>%
    mutate(
      x_midparent = ifelse(is.na(x_midparent), x_pos, x_midparent),
      y_midparent = ifelse(is.na(y_midparent), y_pos, y_midparent)
    ) %>% left_join(spouse_connections) %>%
    mutate(
      x_mid_spouse = ifelse(is.na(x_mid_spouse), x_pos, x_mid_spouse),
      y_mid_spouse = ifelse(is.na(y_mid_spouse), y_pos, y_mid_spouse)
    )

  return(connections)
}
