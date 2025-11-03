---
title: "ggpedigree: Visualizing Pedigrees with 'ggplot2' and 'plotly'"
output:
  md_document:
    variant: markdown
    preserve_yaml: true
  rticles::joss_article:
    keep_md: TRUE
  rmarkdown::html_vignette:
    keep_md: TRUE
tags:
  - R
  - pedigrees
  - family trees
  - quantitative genetics
  - behavior genetics
  - visualization
  - ggplot2
  - plotly
authors:
  - name: S. Mason Garrison^[corresponding author]
    orcid: 0000-0002-4804-6003
    affiliation: 1
affiliations:
 - name: Department of Psychology, Wake Forest University, North Carolina, USA
   index: 1
citation_author: Garrison
csl: apa.csl
journal: JOSS
date: "03 November, 2025"
bibliography: paper.bib
vignette: >
  %\VignetteEncoding{UTF-8}
  %\VignetteIndexEntry{modelingandrelatedness}
  %\VignetteIndexEntry{pedigree}
  %\VignetteEngine{knitr::rmarkdown}
---

# Summary

Pedigree diagrams underpin research and practice across genetics, animal
breeding, genealogy, forensics, and counseling. They help medical
geneticists trace the inheritance of Mendelian diseases and identify
at-risk relatives; enable dairy breeders to plan matings that improve
milk yield; support genealogists in reconstructing ancestry; assist
forensic scientists in establishing familial connections in criminal
investigations; and facilitate family therapists and counselors in
understanding their clients' relationships [@genograms_2020]. Early R
tools such as kinship2 [@kinship2] plot simple nuclear families
effectively, but they do not scale to today's pedigrees that can exceed
1,000s of individuals. As datasets have grown, researchers now work with
increasingly complex family structures, including large-scale plant
breeding pedigrees [@shaw2014], web-based pedigree management systems
[@Ranaweera2018open], interactive pedigree editors [@pedigreejs], and
behavior genetic studies of extended family structures
[@hunter_analytic_2021; @garrison_analyzing_2023]. That complexity
exposes the limitations of existing tools, which often struggle with
large and complex datasets. `ggpedigree` addresses this need by
combining a vectorised layout algorithm, ggplot2 output, and optional
plotly interactivity.

# Statement of need

Pedigree visualization has traditionally relied on proprietary software
(e.g., Progeny, GenoPro, Pedigree Viewer) or R packages like `kinship2`
[@kinship2], pedtools [@pedtools], or `pedtricks` [@pedtricks]. While
these tools are functional for many use cases, their limitations become
pronounced when working with complex, modern pedigree datasets or when
more detailed customization is required. Most R packages focus on base
graphics or simple `ggplot2` implementations.

Existing R solutions face three main challenges. First, current
solutions are often poorly integrated with tidyverse workflows and do
not expose the full theming and layering capabilities familiar to
`ggplot2` users [@wickham_ggplot2_2016]. In animal-focused workflows,
rapid rendering seems to takes precedence over aesthetic flexibility. I
suspect that this is because users tend to work with more uniform data
and fewer phenotypes. By contrast, human-focused
workflows---particularly in behavior genetics and genetic epidemiology
[@garrison_analyzing_2023; @lyu2025; @mcardleRAM]---require closer
integration with tidyverse pipelines and more flexible plotting systems
to accommodate complex pedigree structures and harmonization of
phenotypes across data sources. In other words, the needs are different.

Second, most R-based tools offer no interactivity. Static graphics are
often sufficient for publication, but interactivity improves exploration
and communication during model development or data cleaning. A notable
exception is `pedtools` [@vigeland2021], which offers a sister shiny
app, `QuickPed` [@vigeland2022]. While the R ecosystem includes
libraries, like `plotly`, that support interactive plotting, these
features have yet to be integrated into pedigree functions.

Third, scalability and extensibility remain limited across existing
tools. Several R packages attempt to address these challenges with
built-in pedigree plotting functions. `kinship2` [@kinship2] remains
widely used but produces static base graphics and relies on
non-vectorized recursive layout functions that do not scale well to
large families. A partial `ggplot2` implementation exists in a
modernized `kinship2` [called Pedixplorer, @pedixplorer], but is
non-vectorized and incompatible with other ggplot2 layers. `pedtricks`,
a revival of `pedantics` [@morrissey2010], provides a ggplot2-based
implementation for large animal pedigrees but lacks extensibility and
interactivity. The `geneHapR` [@Zhang2023] package focuses on haplotype
visualization rather than general pedigree structure. The `pedgene`
package [@pedgene] offers some plotting functions but is primarily
designed for association testing. The `pedigreejs` package [@pedigreejs]
provides an interactive pedigree editor but does not integrate with R or
ggplot2, limiting its utility for R users.

None of these packages offers the combination of modern `ggplot2`
integration, interactive capabilities, and extensibility that
`ggpedigree` provides. `ggpedigree` addresses these limitations by
providing a comprehensive visualization framework built on modern R
graphics infrastructure. It leverages the extensive customization
capabilities of `ggplot2` while adding specialized functionality for
pedigree-specific visualization challenges.

## Software Architecture

`ggpedigree` is built on a modular architecture that separates data
processing, layout calculation, and visualization layers. The core
workflow involves: (1) data standardization and family structure
analysis using BGmisc functions, (2) coordinate calculation using
algorithms adapted from kinship2, (3) relationship connection mapping,
and (4) layer-based plot construction using ggplot2 geometry functions.
This design allows users to customize any aspect of the visualization
while maintaining computational efficiency for large pedigrees. The
package integrates tightly with the broader R ecosystem, particularly
the tidyverse [@wickham2019] and BGmisc [@bgmisc]. All functions return
standard R objects (ggplot or plotly) that can be further customized.

## Features

I describe the main features of the `ggpedigree` package below. More
detailed descriptions of features and usage is available in the [package
vignettes](https://r-computing-lab.github.io/ggpedigree/articles/),
including examples of how to create static and interactive pedigree
plots, customize aesthetics, and visualize relatedness matrices.
Additional example data include squirrel data from the Kluane Red
Squirrel Project [@mcfarlane2015; @mcfarlane2014] and Targaryen family
data from the Song of Ice and Fire universe [@martin1997; @martin2018].

-   Data Standardization and Family Structure Analysis: `ggPedigree()`
    integrates with BGmisc functions like `ped2fam()` to organize
    individuals by family, `recodeSex()` to standardize sex coding, and
    `checkParentIDs()` to validate pedigree structures. The function
    handles consanguineous relationships and individuals appearing in
    multiple pedigree positions.

-   Coordinate Calculation: `calculateCoordinates()` computes optimal
    positioning for individuals using algorithms adapted from
    `kinship2::align.pedigree`, with enhancements for large
    multi-generational pedigrees and complex family structures. These
    steps are vectorized as much as possible to ensure computational
    efficiency and compatibility with ggplot2.

-   Relationship Connection Mapping: `calculateConnections()` generates
    connection paths between family members, mapping parent-child,
    sibling, spousal, and twin relationships. The function determines
    midpoints for line intersections and handles overlapping connections
    with specialized curved segments. These calculations are optimized
    for large datasets by using vectorized operations rather than the
    loop-based approaches used in kinship2.

-   Layer-based Plot Construction: `ggPedigree()` constructs plots using
    ggplot2 geometry functions, returning standard ggplot2 objects that
    integrate with existing R workflows. `ggPedigreeInteractive()`
    extends plots into interactive plotly widgets. A config system
    allows customization of over 100 aesthetic and layout parameters.

-   Individual Highlighting: Advanced functionality to highlight
    specific individuals and their relatives based on additive genetic,
    mitochondrial, or other relationship matrices.

-   Specific Visualization Functions: `ggPedigree()` creates static
    pedigree plots using ggplot2. `ggPedigreeInteractive()` generates
    interactive pedigree plots using plotly. `ggRelatednessMatrix()`
    creates customizable heatmaps for relatedness matrices with support
    for hierarchical clustering, and seamless integration with BGmisc
    relatedness calculations. `ggPhenotypeByDegree()` visualizes
    phenotypic correlations as a function of genetic relatedness,
    including confidence intervals and statistical summaries for
    quantitative genetic analysis.

### Code example

This example shows how to use `ggpedigree` to visualize a pedigree. The
`potter` dataset includes several wizarding families from the Harry
Potter series.

``` r
ggPedigree(potter,
  famID = "famID",
  personID = "personID"
)
```

`\includegraphics[width=0.55\textwidth,keepaspectratio]{potter_pedigree.png}`{=tex}

I demonstrate several advanced features by restyling the figure from
[@hunter2025tracing], to follow the Wake Forest brand identity
guidelines; source code is in the appendix.

`\includegraphics[width=0.95\textwidth,keepaspectratio]{wfu_potter_pedigree.png}`{=tex}

I have combined two figures using `patchwork` [@patchwork]: panel (a)
highlights unique mitochondrial lines in the Dursley and Evans families,
while panel (b) shows the full pedigree with Molly Weasley's
mitochondrial descendants in gold.

Collectively, these tools provide a valuable resource for behavior
geneticists and others who work with extended family data. They were
developed as part of a grant and have been used in several ongoing
projects, presentations [@garrison2024; @hunter2024], and forthcoming
papers [@lyu2025; @hunter2025tracing; @burt2025mtDNA].

# Availability

The `ggpedigree` package is open-source and available on both GitHub at
<https://github.com/R-Computing-Lab/ggpedigree> and the Comprehensive R
Archive Network (CRAN) at
<https://cran.r-project.org/package=ggpedigree>. It is licensed under
the GNU General Public License.

# Acknowledgments

The current research is supported by the National Institute on Aging
(NIA), RF1-AG073189. The author would like to thank Michael Hunter for
his enthusiasm for the development of this package.

# References

[^1]: corresponding author
