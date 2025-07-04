
# Description
This version adds new features and bug fixes to the `ggpedigree` package, enhancing its functionality for visualizing pedigrees with `ggplot2` and `plotly`. Key updates include support for character-based IDs, improved configuration options, and new plotting features such as `ggPhenotypebyDegree`. I've done my best to keep the files in this package as small as possible, but plotly makes this difficult.

I am also moving the lone plotting function from BGmisc to this package. I maintain both packages. Once this package is on CRAN, I will upload the new version of BGmisc that does not include the plotting function. 

## revdepcheck results

We checked 2 reverse dependencies, comparing R CMD check results across CRAN and dev versions of this package.

 * We saw 2 new problems
 * We failed to check 0 packages

Issues with CRAN packages are summarised below.

### New problems
(This reports the first line of each new failure)

* `BGmisc` (version 1.4.3.1)
  checking running R code from vignettes ...

* `discord ` (version 1.2.4.1)
  checking running R code from vignettes ...
  

# Test Environments

1. Local OS: Windows 11 x64 (build 26120), R version 4.5.0 (2025-04-11 ucrt)
2. **GitHub Actions**:  
    - [Link](https://github.com/R-Computing-Lab/ggpedigree/actions/runs/15547086987)
    - macOS (latest version) with the latest R release.
    - Windows (latest version) with the latest R release.
    - Ubuntu (latest version) with:
        - The development version of R.
        - The latest R release.


## R CMD check results

── R CMD check results ─────────────────────────────── ggpedigree 0.7.0 ────
Duration: 1m 59.2s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

R CMD check succeeded
