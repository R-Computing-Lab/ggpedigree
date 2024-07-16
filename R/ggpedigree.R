#' ggplot2-based pedigree plotting function
#'
#' @param  pedigree A data frame with columns \code{id}, \code{father}, \code{mother}, and
#' @return plot


plot_pedigree_ggplotv0 <- function(pedigree) {
  # Convert factors to numeric for plotting efficiency if they are not already
  pedigree$sex <- as.numeric(factor(pedigree$sex))

  # Initialize an empty data frame for connections
  connections <- data.frame(x = numeric(), y = numeric(), xend = numeric(), yend = numeric())

  # Check and create connections for fathers
  if (any(!is.na(pedigree$father_id))) {
    father_connections <- pedigree[pedigree$father_id %in% pedigree$id,]
    father_connections <- merge(pedigree, father_connections, by.x = "father_id", by.y = "id", suffixes = c("", "_end"))
    connections <- rbind(connections, father_connections[,c("x", "y", "x_end", "y_end")])
  }

  # Check and create connections for mothers
  if (any(!is.na(pedigree$mother_id))) {
    mother_connections <- pedigree[pedigree$mother_id %in% pedigree$id,]
    mother_connections <- merge(pedigree, mother_connections, by.x = "mother_id", by.y = "id", suffixes = c("", "_end"))
    connections <- rbind(connections, mother_connections[,c("x", "y", "x_end", "y_end")])
  }

  # Prepare plot
  p <- ggplot() +
    geom_segment(data = connections, aes(x = x, y = -y, xend = x_end, yend = -y_end),
                 arrow = arrow(length = unit(0.02, "npc"))) +
    geom_point(data = pedigree, aes(x = x, y = -y, color = as.factor(sex)), size = 4) +
    geom_text(data = pedigree, aes(x = x, y = -y, label = id), vjust = -1, size = 3) +
    scale_color_manual(values = c("blue", "red")) +  # Assuming 1 = Male, 2 = Female
    theme_minimal() +
    labs(title = "Pedigree Chart") +
    coord_fixed(ratio = 1)  # Ensuring aspect ratio is 1:1 for better spatial representation

  return(p)
}

plot_pedigree_ggplotv1 <- function(pedigree, affected = NULL, status = NULL) {
  # Example data preparation
  individuals <- data.frame(
    id = pedigree$id,
    x = runif(length(pedigree$id)),  # Random placement, needs proper computation
    y = runif(length(pedigree$id)),
    sex = factor(pedigree$sex, levels = c(1, 2), labels = c("Male", "Female")),
    affected = ifelse(is.null(affected), 0, affected),
    status = ifelse(is.null(status), 0, status)
  )

  # Set up the basic ggplot
  p <- ggplot(individuals, aes(x = x, y = y)) +
    geom_point(aes(color = sex, shape = sex), size = 4) +  # Nodes by sex
    geom_text(aes(label = id), vjust = -1) +  # Node labels
    theme_minimal()

  # Add affected status if not null
  if (!is.null(affected)) {
    p <- p + geom_point(aes(fill = factor(affected)), shape = 21)
  }

  # Typically you would compute parent-child and spouse connections separately

  # Example of adding parent-child connections
  connections <- data.frame(
    x = c(rep(individuals$x[1], 2), rep(individuals$x[2], 2)),
    y = c(rep(individuals$y[1], 2), rep(individuals$y[2], 2)),
    xend = c(individuals$x[3], individuals$x[4], individuals$x[5], individuals$x[6]),
    yend = c(individuals$y[3], individuals$y[4], individuals$y[5], individuals$y[6])
  )
  p <- p + geom_segment(data = connections, aes(xend = xend, yend = yend), arrow = arrow())

  # Final adjustments and plot return
  p + labs(title = "Pedigree Chart") + coord_fixed()
}




# Function to compute generational levels and horizontal positions
compute_positions <- function(ped) {
  ped <- ped %>%
    mutate(parent = pmax(father, mother, na.rm = TRUE)) %>%
    replace_na(list(parent = 0)) %>%
    arrange(parent) %>%
    mutate(generation = ifelse(parent == 0, 1, NA))

  # Propagate generational levels
  max_gen <- max(ped$generation, na.rm = TRUE)
  while(any(is.na(ped$generation))) {
    ped <- ped %>%
      left_join(ped %>% select(id, generation), by = c("parent" = "id")) %>%
      mutate(generation = ifelse(is.na(generation.x), generation.y + 1, generation.x)) %>%
      select(-generation.x, -generation.y)
    max_gen <- max_gen + 1
    if (max_gen > nrow(ped)) break  # Prevent infinite loops
  }

  # Assign initial x positions (naive approach)
  ped <- ped %>%
    group_by(generation) %>%
    mutate(x = row_number())

  # Refine x positions by aligning to the average parent x position
  for (gen in 2:max(ped$generation)) {
    parent_positions <- ped %>%
      filter(generation == gen - 1) %>%
      select(id, x)

    child_positions <- ped %>%
      filter(generation == gen) %>%
      mutate(parent_x = map_dbl(parent, ~mean(parent_positions$x[parent_positions$id == .], na.rm = TRUE)))

    ped <- ped %>%
      mutate(x = if_else(generation == gen, child_positions$parent_x, x))
  }

  ped
}

# Main plotting function
plot_pedigree_ggplot <- function(pedigree) {
  # Compute positions
  positions <- compute_positions(pedigree)

  # Set up the ggplot
  p <- ggplot(positions, aes(x = x, y = -generation)) +
    geom_point(aes(color = as.factor(sex)), size = 4) +
    geom_text(aes(label = id), vjust = 1.5, size = 3) +
    labs(color = "Sex") +
    theme_minimal() +
    theme(axis.title.y = element_blank(),
          axis.text.y = element_blank(),
          axis.ticks.y = element_blank())

  p
}


