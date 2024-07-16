calculateConnections <- function(ped) {
  # Create connections based on parent-child relationships
  connections <- ped %>%
    select(personID, x_pos, y_pos, dadID, momID)

  # Separate mom and dad coordinates
  mom_connections <- connections %>%
    filter(!is.na(momID)) %>%
    left_join(ped, by = c("momID" = "personID"), suffix = c("", "_mom")) %>%
    rename(x_mom = x_pos_mom, y_mom = y_pos_mom) %>%
    select(personID, momID, x_mom, y_mom)

  dad_connections <- connections %>%
    filter(!is.na(dadID)) %>%
    left_join(ped, by = c("dadID" = "personID"), suffix = c("", "_dad")) %>%
    rename(x_dad = x_pos_dad, y_dad = y_pos_dad) %>%
    select(personID, dadID, x_dad, y_dad)

  # Combine mom and dad connections with the original dataset
  connections <- connections %>%
    left_join(mom_connections, by = "personID") %>%
    left_join(dad_connections, by = "personID")

  # Create midpoints for parents
  parent_midpoints <- connections %>%
    filter(!is.na(dadID) & !is.na(momID)) %>%
    group_by(dadID, momID) %>%
    summarize(
      x_midparent = mean(c(first(x_dad), first(x_mom))),
      y_midparent = mean(c(first(y_dad), first(y_mom))) - 0.5,
      .groups = 'drop'
    )

  # Merge midpoints back to connections
  connections <- connections %>%
    left_join(parent_midpoints, by = c("dadID", "momID")) %>%
    mutate(
      x_midparent = ifelse(is.na(x_midparent), x_pos, x_midparent),
      y_midparent = ifelse(is.na(y_midparent), y_pos, y_midparent)
    )

  return(connections)
}
