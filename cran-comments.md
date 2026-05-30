# Description

This update adds new plotting options, including more flexible overlays, polar coordinate support, and advanced segment aesthetics. It also fixes overlay filtering, preset forwarding, palette handling in `ggRelatednessMatrix()`, and minor documentation and example issues. More specifics are detailed in the NEWS file.


## Note Comment

On occasion, a note may appear about how a suggested package (OpenMx) wasn't available for r-oldrel-windows-x86_64. This is expected behavior due to perpetual changes in `OpenMx` dependencies. It does not impact the functionality of `ggpedigree`, as `OpenMx` is not a required dependency.

Therneau and Schaid are spelled correctly in the DESCRIPTION file.


# Test Environments

1. Local OS: Windows 11 x64 (build 26200), R version 4.6.0 (2026-04-24 ucrt)
    - All package dependencies up to date as of 2026-05-29.
2. **GitHub Actions**:  
    - [Link](https://github.com/R-Computing-Lab/ggpedigree/actions/runs/26672838834)
    - macOS (latest version) with the latest R release.
    - Windows (latest version) with the latest R release.
    - Ubuntu (latest version) with:
        - The development version of R.
        - The latest R release.


## R CMD check results

── R CMD check results ──────── ggpedigree 1.2.0 ────
Duration: 2m 32.6s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

R CMD check succeeded


## revdepcheck results
> pak::pkg_install("r-lib/revdepcheck")
> revdepcheck::revdep_check()


We checked 2 reverse dependencies, comparing R CMD check results across CRAN and dev versions of this package.

 * We saw 0 new problems
 * We failed to check 0 packages



## urlchecker results
> urlchecker::url_check()
✔ All URLs are correct!
