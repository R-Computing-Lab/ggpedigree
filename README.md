
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

<!-- badges: end -->

`ggpedigree` provides modern tools for visualizing pedigree structures
using both ‘ggplot2’ and ‘plotly’. It is designed to work seamlessly
with the `BGmisc` package for simulated or empirical pedigree data, and
extends the plotting capabilities of the base-graphics functions in
`kinship2`.

The package supports:

- Static, publication-ready pedigree plots using the `ggplot2` framework

- Interactive pedigree visualizations using `plotly`

- Layout customization, complex mating structures, and duplicated
  individuals

`ggpedigree` is useful in behavior genetics, kinship analysis, and any
research involving complex pedigree data.

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

## Citation

If you use ggpedigree in your research or wish to refer to it, please
cite the following:

    citation(package = "ggpedigree")

Garrison S (2025). *ggpedigree: Visualizing Pedigrees with ‘ggplot2’ and
‘plotly’*. R package version 0.7.0,
<https://github.com/R-Computing-Lab/ggpedigree/>.

A BibTeX entry for LaTeX users is

    @Manual{,
      title = {ggpedigree: Visualizing Pedigrees with 'ggplot2' and 'plotly'},
      author = {S. Mason Garrison},
      year = {2025},
      note = {R package version 0.7.0},
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
strategy](https://tilburgsciencehub.com/topics/automation/version-control/advanced-git/git-branching-strategies/):

- **Feature Branches**: All major changes and new features should be
  developed on separate branches created from the dev branch. Name these
  branches according to the feature or change they are meant to address.
- **Development Branch**: Our approach includes two development
  branches, each serving distinct roles:
  - **`dev`**: This branch is the final integration stage before changes
    are merged into the `main` branch. It is considered stable, and only
    well-tested features and updates that are ready for the next release
    cycle are merged here.
- **Main Branch** (`main`): The main branch mirrors the stable state of
  the project as seen on CRAN. Only fully tested and approved changes
  from the dev_main branch are merged into main to prepare for a new
  release.

## License

ggpedigree is licensed under the GNU General Public License v3.0. For
more details, see the
[LICENSE.md](https://github.com/R-Computing-Lab/ggpedigree/blob/main/LICENSE.md)
file.
