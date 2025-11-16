# Add annotates to ggplot Pedigree Plot

Add annotates to ggplot Pedigree Plot

## Usage

``` r
.addAnnotate(p, config, y_var_sym)

addAnnotate(p, config, y_var_sym)
```

## Arguments

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

## Value

A ggplot object with added labels.
