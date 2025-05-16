
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ggpedigree

<!-- badges: start -->

[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![R package
version](https://www.r-pkg.org/badges/version/ggpedigree)](https://www.r-pkg.org/badges/version/ggpedigree)
[![Package
downloads](https://cranlogs.r-pkg.org/badges/grand-total/ggpedigree)](https://cranlogs.r-pkg.org/badges/grand-total/ggpedigree)</br>
[![R-CMD-check](https://github.com/R-Computing-Lab/ggpedigree/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/R-Computing-Lab/ggpedigree/actions/workflows/R-CMD-check.yaml)
[![Dev
branch](https://github.com/R-Computing-Lab/ggpedigree/actions/workflows/R-CMD-devcheck.yaml/badge.svg)](https://github.com/R-Computing-Lab/ggpedigree/actions/workflows/R-CMD-devcheck.yaml)
[![codecov](https://app.codecov.io/gh/R-Computing-Lab/ggpedigree/graph/badge.svg?token=xXWYDcD9CF)](https://app.codecov.io/gh/R-Computing-Lab/ggpedigree)
![License](https://img.shields.io/badge/License-GPL_v3-blue.svg)
<!-- badges: end -->

The ggpedigree R package complements the BGmisc package by providing a
set of functions for visualizing pedigree data using ggplot2. It is
designed to work seamlessly with the BGmisc package, which provides
tools for simulating, manipulating, and modeling pedigree data. It
extends the plotting functionality of the `kinship2` package, which is
widely used for pedigree analysis in R.

## Installation

You can install the released version of ggpedigree from
[CRAN](https://cran.r-project.org/) with:

``` r
install.packages("ggpedigree")
```

To install the development version of ggpedigree from
[GitHub](https://github.com/) use:

``` r
# install.packages("devtools")
devtools::install_github("R-Computing-Lab/ggpedigree")
```

## Citation

If you use ggpedigree in your research or wish to refer to it, please
cite the following:

    citation(package = "ggpedigree")

Garrison S (05.16.2025). *ggpedigree: ggplot2 Extensions for Pedigree
Diagrams*. R package version 0.3.0,
<https://github.com/R-Computing-Lab/ggpedigree/>.

A BibTeX entry for LaTeX users is

    @Manual{,
      title = {ggpedigree: ggplot2 Extensions for Pedigree Diagrams},
      author = {S. Mason Garrison},
      year = {05.16.2025},
      note = {R package version 0.3.0},
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
