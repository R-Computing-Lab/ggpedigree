#' Calculate x and y coordinates for plotting a pedigree

#' @param ped a pedigree dataset.  Needs ID, momID, and dadID columns
#' @param personID character.  Name of the column in ped for the person ID variable
#' @param momID character.  Name of the column in ped for the mother ID variable
#' @param dadID character.  Name of the column in ped for the father ID variable
#' @param generation character.  Name of the column in ped the generation variable


calculate_coordinates <- function(ped, personID = "ID", momID = "momID",
                                  dadID = "dadID", generation = "generation",
                                  spouseID = "spouseID"
) {
  if (!inherits(ped, "data.frame")) stop("ped should be a data.frame or inherit to a data.frame")
  if (!all(c(personID, momID, dadID, generation) %in% names(ped))) {
    stop("At least one of the following needed ID variables were not found: personID, momID, dadID, generation")
  }
  var_personID <- personID
  # Initialize positions
  ped$x <- NA
  ped$y <- -ped[[generation]]  # Negative for plotting purposes
 # determine number of offspring to adjust width of graph
  ped$offspring <- 0
  # probably not the most efficient way to do this....
  for (i in 1:nrow(ped)) {
    ped$offspring[i] <- sum(ped$momID == ped$personID[i],na.rm = TRUE) + sum(ped$dadID == ped$personID[i],na.rm = TRUE)
  }
  ped$offspring <- as.numeric(ped$offspring)
  ped$parentid <- paste0(ped[[momID]],".",ped[[dadID]])
  ped$parentid[ped$parentid=="NA.NA"] <- NA

  # determine number of siblings to adjust width of graph
  ped <- ped %>% group_by(ped$parentid) %>% mutate(siborder = row_number(),
                                                   siblings = n()-1)
  # for orphans/parentless
  ped$siblings <- ifelse(is.na(ped$parentid),0,ped$siblings)

  ped$siborder <- ifelse(is.na(ped$parentid),1,
                         ped$siborder)


  # Sort by generation to process from oldest to youngest
  ped <- ped[order(ped[[generation]]),]

  for (gen in unique(ped[[generation]])) {
    current_gen <- subset(ped, generation == gen)

    for (i in seq_along(current_gen[[var_personID]])) {
      personID <- current_gen[[var_personID]][i]
      if (is.na(ped$x[ped[[var_personID]] == personID])) {
        # Find parents' x coordinates
        parent_ids <- c(current_gen[[dadID]][i], current_gen[[momID]][i])
        parent_coords <- ped$x[ped[[var_personID]] %in% parent_ids]
        siblings <- max(ped$offspring[ped[[var_personID]] %in% parent_ids], na.rm = TRUE)
        mid_parent_x <- mean(parent_coords, na.rm = TRUE)
        # need to spread out siblings
        if (siblings > 1) {
          mid_parent_x <- mid_parent_x + (ped$siborder - (siblings + 1)/2)
        }

        # need to allow for siblings


        # Assign x coordinate
        if (!is.na(mid_parent_x)) {
          ped$x[ped[[var_personID]] == personID] <- mid_parent_x
        } else {
          # No parents x found (might be top generation or orphan)
          # the width of the graph is a function of the number of generations
          ped$x[ped[[var_personID]] == personID] <- max(ped$x, na.rm = TRUE, 0) + 1*max(ped[[generation]])
        }
      }
    }
  }
  # sort by personID
  ped <- ped[order(ped[[var_personID]]),]
  return(ped)
}


calculate_connections <- function(ped) {
  # Create connections based on parent-child relationships
  connections <- ped %>%
    select(personID, x, y, dadID, momID) %>%
    gather(key = "parent_type", value = "parent_id", dadID, momID) %>%
    filter(!is.na(parent_id)) %>%
    left_join(ped %>% select(personID, x, y), by = c("parent_id" = "personID"),
              suffix = c("", "end") ) %>%
    left_join(ped %>% select(personID, x, y), by = c("personID" = "personID"),
              suffix = c("", ".y") ) %>%
    select(personID, x, y, xend, yend)

  return(connections)
}
