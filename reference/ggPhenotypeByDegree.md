# Plot correlation of genetic relatedness by phenotype

This function plots the phenotypic correlation as a function of genetic
relatedness.

## Usage

``` r
ggPhenotypeByDegree(
  df,
  y_var,
  y_se = NULL,
  y_stem_se = NULL,
  y_ci_lb = NULL,
  y_ci_ub = NULL,
  config = list(),
  data_prep = TRUE,
  ...
)
```

## Arguments

- df:

  Data frame containing pairwise summary statistics. Required columns:

  addRel_min

  :   Minimum relatedness per group

  addRel_max

  :   Maximum relatedness per group

  n_pairs

  :   Number of pairs at that relatedness

  cnu

  :   Indicator for shared nuclear environment (1 = yes, 0 = no)

  mtdna

  :   Indicator for shared mitochondrial DNA (1 = yes, 0 = no)

- y_var:

  Name of the y-axis variable column (e.g., "r_pheno_rho").

- y_se:

  Name of the standard error column (e.g., "r_pheno_se").

- y_stem_se:

  Optional; base stem used to construct SE ribbon bounds. (e.g.,
  "r_pheno")

- y_ci_lb:

  Optional; lower bound for confidence interval (e.g., "r_pheno_ci_lb").

- y_ci_ub:

  Optional; upper bound for confidence interval (e.g., "r_pheno_ci_ub").

- config:

  A list of configuration overrides. Valid entries include:

  filter_n_pairs

  :   Minimum number of pairs to include (default: 500)

  filter_degree_min

  :   Minimum degree of relatedness (default: 0)

  filter_degree_max

  :   Maximum degree of relatedness (default: 7)

  plot_title

  :   Plot title

  plot_subtitle

  :   Plot subtitle

  color_scale

  :   Paletteer color scale name (e.g., "ggthemes::calc")

  use_only_classic_kin

  :   If TRUE, only classic kin are shown

  group_by_kin

  :   If TRUE, use classic kin × mtDNA for grouping

  drop_classic_kin

  :   If TRUE, remove classic kin rows

  drop_non_classic_sibs

  :   If TRUE, remove non-classic sibs (default: TRUE)

  annotate_include

  :   If TRUE, annotate mother/father/sibling points

  annotate_x_shift

  :   Relative x-axis shift for annotations

  annotate_y_shift

  :   Relative y-axis shift for annotations

  point_size

  :   Size of geom_point points (default: 1)

  use_relative_degree

  :   If TRUE, x-axis uses degree-of-relatedness scaling

  grouping_column

  :   Grouping column name (default: mtdna_factor)

  value_rounding_digits

  :   Number of decimal places for rounding (default: 2)

  match_threshold_percent

  :   Tolerance % for matching known degrees

  max_degree_levels

  :   Maximum number of degrees to consider

- data_prep:

  Logical; if TRUE, performs data preparation steps.

- ...:

  Additional arguments passed to \`ggplot2\` functions.

## Value

A ggplot object containing the correlation plot.
