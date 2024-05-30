
<!-- README.md is generated from README.Rmd. Please edit that file -->

# BGmisc

<!-- badges: start -->

[![status](https://joss.theoj.org/papers/ee3a025be4f61584f977a7657d936187/status.svg)](https://joss.theoj.org/papers/10.21105/joss.06203)
</br> [![Project Status: Active – The project has reached a stable,
usable state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![R package
version](https://www.r-pkg.org/badges/version/BGmisc)](https://cran.r-project.org/package=BGmisc)
[![Package
downloads](https://cranlogs.r-pkg.org/badges/grand-total/BGmisc)](https://cran.r-project.org/package=BGmisc)</br>
[![R-CMD-check](https://github.com/R-Computing-Lab/BGmisc/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/R-Computing-Lab/BGmisc/actions/workflows/R-CMD-check.yaml)
[![Dev Main
branch](https://github.com/R-Computing-Lab/BGmisc/actions/workflows/R-CMD-dev_maincheck.yaml/badge.svg)](https://github.com/R-Computing-Lab/BGmisc/actions/workflows/R-CMD-dev_maincheck.yaml)
[![codecov](https://codecov.io/gh/R-Computing-Lab/BGmisc/graph/badge.svg?token=2IARK2XSA6)](https://codecov.io/gh/R-Computing-Lab/BGmisc)
![License](https://img.shields.io/badge/License-GPL_v3-blue.svg)
<!-- badges: end -->

The BGmisc R package offers a comprehensive suite of functions tailored
for extended behavior genetics analysis, including model identification,
calculating relatedness, pedigree conversion, pedigree simulation, and
more.

## Installation

You can install the released version of BGmisc from
[CRAN](https://cran.r-project.org/) with:

``` r
install.packages("BGmisc")
```

To install the development version of BGmisc from
[GitHub](https://github.com/) use:

``` r
# install.packages("devtools")
devtools::install_github("R-Computing-Lab/BGmisc")
```

## Citation

If you use BGmisc in your research or wish to refer to it, please cite
the following paper:

    citation(package = "BGmisc")

Garrison, S. Mason, Hunter, Michael D., Lyu, Xuanyu, Trattner, Jonathan
D., Burt, S. Alexandra (2024). “BGmisc: An R Package for Extended
Behavior Genetics Analysis.” *Journal of Open Source Software*, *9*(94).
<doi:10.21105/joss.06203> <https://doi.org/10.21105/joss.06203>.

A BibTeX entry for LaTeX users is

    @Article{bgmisc,
      title = {BGmisc: An R Package for Extended Behavior Genetics Analysis},
      author = {{Garrison, S. Mason} and {Hunter, Michael D.} and {Lyu, Xuanyu} and {Trattner, Jonathan D.} and {Burt, S. Alexandra}},
      journal = {Journal of Open Source Software},
      year = {2024},
      volume = {9},
      number = {94},
      doi = {10.21105/joss.06203},
    }

## Contributing

Contributions to the BGmisc project are welcome. For guidelines on how
to contribute, please refer to the [Contributing
Guidelines](https://github.com/R-Computing-Lab/BGmisc/blob/main/CONTRIBUTING.md).
Issues and pull requests should be submitted on the GitHub repository.
For support, please use the GitHub issues page.

### Branching and Versioning System

The development of BGmisc follows a [GitFlow branching
strategy](https://tilburgsciencehub.com/topics/automation/version-control/advanced-git/git-branching-strategies/):

- **Feature Branches**: All major changes and new features should be
  developed on separate branches created from the dev_main branch. Name
  these branches according to the feature or change they are meant to
  address.
- **Development Branches**: Our approach includes two development
  branches, each serving distinct roles:
  - **`dev_main`**: This branch is the final integration stage before
    changes are merged into the `main` branch. It is considered stable,
    and only well-tested features and updates that are ready for the
    next release cycle are merged here.
  - **`dev`**: This branch serves as a less stable, active development
    environment. Feature branches are merged here. Changes here are more
    fluid and this branch is at a higher risk of breaking.
- **Main Branch** (`main`): The main branch mirrors the stable state of
  the project as seen on CRAN. Only fully tested and approved changes
  from the dev_main branch are merged into main to prepare for a new
  release.

## License

BGmisc is licensed under the GNU General Public License v3.0. For more
details, see the
[LICENSE.md](https://github.com/R-Computing-Lab/BGmisc/blob/main/LICENSE.md)
file.
