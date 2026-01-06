
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ggpedigree

<!-- badges: start -->

<a href="https://r-computing-lab.github.io/ggpedigree/"><img src="man/figures/hex.png" align="right" height="139" alt="ggpedigree website" /></a>
[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![CRAN
version](https://www.r-pkg.org/badges/version/ggpedigree)](https://CRAN.R-project.org/package=ggpedigree)
[![CRAN
checks](https://badges.cranchecks.info/worst/ggpedigree.svg)](https://cran.r-project.org/web/checks/check_results_ggpedigree.html)
[![Package
downloads](https://cranlogs.r-pkg.org/badges/grand-total/ggpedigree)](https://cranlogs.r-pkg.org/badges/grand-total/ggpedigree)
[![codecov](https://codecov.io/gh/R-Computing-Lab/ggpedigree/branch/main/graph/badge.svg?token=xXWYDcD9CF)](https://app.codecov.io/gh/R-Computing-Lab/ggpedigree)</br>
[![R-CMD-check](https://github.com/R-Computing-Lab/ggpedigree/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/R-Computing-Lab/ggpedigree/actions/workflows/R-CMD-check.yaml)
[![Dev
branch](https://github.com/R-Computing-Lab/ggpedigree/actions/workflows/R-CMD-devcheck.yaml/badge.svg)](https://github.com/R-Computing-Lab/ggpedigree/actions/workflows/R-CMD-devcheck.yaml)
[![Website
Deployed](https://github.com/R-Computing-Lab/ggpedigree/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/R-Computing-Lab/ggpedigree/actions/workflows/pkgdown.yaml)
[![License](https://img.shields.io/badge/License-GPL_v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0.html)
[![status](https://joss.theoj.org/papers/e5116b83b03e2740960d1153c45f9480/status.svg)](https://joss.theoj.org/papers/e5116b83b03e2740960d1153c45f9480)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.18165893.svg)](https://doi.org/10.5281/zenodo.18165893)
<!-- badges: end -->

`ggpedigree` provides modern tools for visualizing family trees and
pedigree structures using both `ggplot2` and `plotly`. Specifically, it
enables the creation of static and interactive pedigree plots that can
accommodate complex family relationships, including duplicated
individuals and various mating structures.

The package complements the behavior genetics toolkit `BGmisc`
\[Garrison et al. (2024) <doi:10.21105/joss.06203>\] for tasks such as
pedigree validation and computing relatedness matrices. Core plotting
functions (`ggPedigree()`, `ggPedigreeInteractive()`,
`calculateCoordinates()`) work on any rectangular pedigree and ship with
built-in example data, while relatedness workflows reuse matrix builders
from `BGmisc`. Due to the impending deprecation of `kinship2`, version
1.0 incorporates the layout helper functions from kinship2. The pedigree
alignment algorithms are adapted from ‘kinship2’ \[Sinnwell et
al. (2014) <doi:10.1159/000363105>\]. We gratefully acknowledge the
original authors: Jason Sinnwell, Terry Therneau, Daniel Schaid, and
Elizabeth Atkinson for their foundational work.

See the [package
vignettes](https://r-computing-lab.github.io/ggpedigree/articles/) for
end-to-end tutorials, including relatedness matrices and interactive
plots.

## Installation

You can install the released version of ggpedigree from
[CRAN](https://cran.r-project.org/) with:

``` r
install.packages("ggpedigree")
```

To install the development version of `ggpedigree` from
[GitHub](https://github.com/) use:

``` r
# install.packages("devtools")
devtools::install_github("R-Computing-Lab/ggpedigree")
```

## Demonstration

Here is a basic example of how to use `ggpedigree` to visualize a
pedigree structure. The `potter` dataset contains simulated pedigree
data for the Weasley family from the Harry Potter series.

``` r
library(ggpedigree) # ggPedigree lives here
library(BGmisc) # helper utilities & example data
potter <- BGmisc::potter # load example data
ggPedigree(potter,
  famID = "famID",
  personID = "personID"
)
```

<img src="man/figures/README-basic-usage-1.png" alt="" width="80%" />

``` r
ggPedigree(potter,
  famID = "famID",
  personID = "personID",
  config = list(
    color_theme = "greyscale"
  )
)
```

<img src="man/figures/README-slightly-usage-1.png" alt="" width="80%" />

## Citation

If you use ggpedigree in your research or wish to refer to it, please
cite the following:

    citation(package = "ggpedigree")

Garrison S (2026). *ggpedigree: Visualizing Pedigrees with ‘ggplot2’ and
‘plotly’*. R package version 1.1.0.3,
<https://github.com/R-Computing-Lab/ggpedigree/>.

A BibTeX entry for LaTeX users is

    @Manual{,
      title = {ggpedigree: Visualizing Pedigrees with 'ggplot2' and 'plotly'},
      author = {S. Mason Garrison},
      year = {2026},
      note = {R package version 1.1.0.3},
      url = {https://github.com/R-Computing-Lab/ggpedigree/},
    }

## Contributing

Contributions to the ggpedigree project are welcome. For guidelines on
how to contribute, please refer to the [Contributing
Guidelines](https://github.com/R-Computing-Lab/ggpedigree/blob/main/CONTRIBUTING.md).
Issues and pull requests should be submitted on the GitHub repository.
For support, please use the GitHub issues page.

### Branching and Versioning System

The development of ggpedigree follows a [GitFlow branching
strategy](https://docs.gitlab.com/user/project/repository/branches/strategies/):

- **Feature Branches**: All major changes and new features should be
  developed on separate branches created from the dev branch. Name these
  branches according to the feature or change they are meant to address.
- **Development Branch**: The `dev` branch is the main development
  branch where all feature branches are merged. This branch contains the
  latest changes and is used for testing and development purposes.
- **Main Branch** (`main`): The main branch mirrors the stable state of
  the project as seen on CRAN. Only fully tested and approved changes
  from the dev branch are merged into main to prepare for a new release.

## License

ggpedigree is licensed under the GNU General Public License v3.0. For
more details, see the
[LICENSE.md](https://github.com/R-Computing-Lab/ggpedigree/blob/main/LICENSE.md)
file.
