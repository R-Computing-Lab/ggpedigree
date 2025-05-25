
# Description
This is a hotfix for the previous submission of the package "ggpedigree" (v0.4.0). I found a small error that occurs if you try to make an interactive plot using a custom ID name and a want the plot to be returned as a ggplot object. 

# Test Environments

1. Local OS: Windows 11 x64 (build 26120), R version 4.5.0 (2025-04-11 ucrt)
2. **GitHub Actions**:  
    - [Link](https://github.com/R-Computing-Lab/ggpedigree/actions/runs/15145889225)
    - macOS (latest version) with the latest R release.
    - Windows (latest version) with the latest R release.
    - Ubuntu (latest version) with:
        - The development version of R.
        - The latest R release.


## R CMD check results

── R CMD check results ─────────────────────────────── ggpedigree 0.4.0 ────
Duration: 2m 3s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

R CMD check succeeded
