library(microbenchmark)
library(Matrix)
library(tidyverse)
library(BGmisc)


# make big data
set.seed(15)
Ngen <- 5
kpc <- 5
sexR <- .50
marR <- .7

ped <- simulatePedigree(kpc = kpc, Ngen = Ngen, sexR = sexR, marR = marR) %>%
  mutate(
    fam = "fam 1"
  )

set.seed(151)
Ngen <- 5
marR <- .8
id_offset <- max(ped$ID, na.rm = TRUE)

ped2 <- simulatePedigree(kpc = kpc, Ngen = Ngen, sexR = sexR, marR = marR) %>%
  mutate(
    fam = "fam 2",
    ID = ID + id_offset,
    momID = if_else(is.na(momID) | momID == 0, momID, momID + id_offset),
    dadID = if_else(is.na(dadID) | dadID == 0, dadID, dadID + id_offset),
    spouseID = if_else(is.na(spouseID) | spouseID == 0, spouseID, spouseID + id_offset)
  )

set.seed(1151)
kpc <- 8
Ngen <- 6
id_offset <- max(ped2$ID, na.rm = TRUE)

ped3 <- simulatePedigree(kpc = kpc, Ngen = Ngen, sexR = sexR, marR = marR) %>%
  mutate(
    fam = "fam 3",
    ID = ID + id_offset,
    momID = if_else(is.na(momID) | momID == 0, momID, momID + id_offset),
    dadID = if_else(is.na(dadID) | dadID == 0, dadID, dadID + id_offset),
    spouseID = if_else(is.na(spouseID) | spouseID == 0, spouseID, spouseID + id_offset)
  )

id_offset <- max(ped3$ID, na.rm = TRUE)

ped3b <- ped3 %>%
  mutate(
    fam = "fam 4",
    ID = ID + id_offset,
    momID = if_else(is.na(momID) | momID == 0, momID, momID + id_offset),
    dadID = if_else(is.na(dadID) | dadID == 0, dadID, dadID + id_offset),
    spouseID = if_else(is.na(spouseID) | spouseID == 0, spouseID, spouseID + id_offset)
  )

#ped3 <- rbind(ped3b, ped3)

set.seed(11513)
kpc <- 2
Ngen <- 10
id_offset <- max(ped3$ID, na.rm = TRUE)

ped4 <- simulatePedigree(kpc = kpc, Ngen = Ngen, sexR = sexR, marR = marR) %>%
  mutate(
    fam = "fam 5",
    ID = ID + id_offset,
    momID = if_else(is.na(momID) | momID == 0, momID, momID + id_offset),
    dadID = if_else(is.na(dadID) | dadID == 0, dadID, dadID + id_offset),
    spouseID = if_else(is.na(spouseID) | spouseID == 0, spouseID, spouseID + id_offset)
  )


ped_big <- rbind(ped, ped2)
ped_big <- rbind(ped_big, ped4)
ped_mega <- rbind(ped_big, ped3)


# Convert simulated data to pedigree objects.
# This mirrors the data-shaping pattern in your existing tests.
ped_small_obj <- with(ped2, ggpedigree:::pedigree(ID, dadID, momID, sex))
ped_big_obj <- with(ped_big, ggpedigree:::pedigree(ID, dadID, momID, sex, famid = fam))
ped_mega_obj <- with(ped_mega, ggpedigree:::pedigree(ID, dadID, momID, sex, famid = fam))

if (TRUE) {
  # Define parameters
  packed <- TRUE
  align <- TRUE
  width <- 8

  # method_approach <- 1
  # Run benchmarking for "loop" and "indexed" methods in ped2com()
  benchmark_results <- microbenchmark(
    classic_big = {
      ggpedigree:::kinship2_align.pedigree(
        ped_big_obj,
        packed = packed,
        align = align,
        width = width,
        classic = TRUE
      )
    },
    optimized_big = {
      ggpedigree:::kinship2_align.pedigree(
        ped_big_obj,
        packed = packed,
        align = align,
        width = width,
        classic = FALSE
      )
    },
    optimized_mega = {
      ggpedigree:::kinship2_align.pedigree(
        ped_mega_obj,
        packed = packed,
        align = align,
        width = width,
        classic = FALSE
      )
    },
    classic_mega = {
      ggpedigree:::kinship2_align.pedigree(
        ped_mega_obj,
        packed = packed,
        align = align,
        width = width,
        classic = TRUE
      )
    },
    classic = {
      ggpedigree:::kinship2_align.pedigree(
        ped_small_obj,
        packed = packed,
        align = align,
        width = width,
        classic = TRUE
      )
    },
    optimized = {
      ggpedigree:::kinship2_align.pedigree(
        ped_small_obj,
        packed = packed,
        align = align,
        width = width,
        classic = FALSE
      )
    },
    times = 15
  )

  summary(benchmark_results)


  df_plot <- benchmark_results %>%
    as_tibble() %>%
    mutate(
      expr = as.character(expr),
      size = case_when(
        expr %in% c("classic", "optimized") ~ "small",
        expr %in% c("classic_big", "optimized_big") ~ "big",
        expr %in% c("classic_mega", "optimized_mega") ~ "mega"
      ),
      method = case_when(
        expr %in% c("classic", "classic_big",
                    "classic_mega") ~ "classic",
        expr %in% c("optimized", "optimized_big",
                    "optimized_mega") ~ "optimized"

      ),
      time_seconds = time / 1e9
    )

  df_plot$method <- factor(df_plot$method, levels = c("classic", "optimized"))
  df_plot$size <- factor(df_plot$size, levels = c("small", "big", "mega"))

  lm(time_seconds ~ method * size, data = df_plot) %>%
    summary() %>%
    print()

  p <- ggplot(df_plot, aes(x = method, y = time_seconds)) +
    geom_boxplot(aes(fill = size), alpha = 0.5) +
    labs(
      title = "Benchmarking Alignment Results",
      x = "Method",
      y = "Time (seconds)"
    ) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))

  p
  print(benchmark_results)

  write.csv(
    summary(benchmark_results),
    "benchmark_alignment_results.csv",
    row.names = FALSE
  )
  # Print benchmark
}

if (FALSE) {
  verbose <- FALSE
  ad_ped_matrix <- ped2com(ped,
                           component = "additive",
                           adjacency_method = "direct", sparse = TRUE
  )
  mit_ped_matrix <- ped2com(ped,
                            component = "mitochondrial",
                            adjacency_method = "direct", sparse = TRUE
  )
  cn_ped_matrix <- ped2com(ped,
                           component = "common nuclear",
                           adjacency_method = "indexed", sparse = TRUE
  )
  benchmark_results <- microbenchmark(
    beta = {
      com2links.beta(
        ad_ped_matrix = ad_ped_matrix,
        mit_ped_matrix = mit_ped_matrix,
        cn_ped_matrix = cn_ped_matrix,
        writetodisk = TRUE,
        verbose = verbose
      )
      file.remove("dataRelatedPairs.csv")
    }, regular = {
      com2links(
        ad_ped_matrix = ad_ped_matrix,
        mit_ped_matrix = mit_ped_matrix,
        cn_ped_matrix = cn_ped_matrix,
        writetodisk = TRUE,
        verbose = verbose
      )
      file.remove("dataRelatedPairs.csv")
    }, legacy = {
      com2links(
        ad_ped_matrix = ad_ped_matrix,
        mit_ped_matrix = mit_ped_matrix,
        cn_ped_matrix = cn_ped_matrix,
        verbose = verbose,
        legacy = TRUE
      )
      file.remove("dataRelatedPairs.csv")
    },
    times = 100 # Run each method 100 times
  )

  summary(benchmark_results)

  lm(benchmark_results$time ~ benchmark_results$expr) %>%
    summary()
  # Print benchmark results
  print(benchmark_results)

  # Optional: Save results to CSV for later analysis
  write.csv(summary(benchmark_results),
            "benchmark_results.csv",
            row.names = FALSE
  )
}
