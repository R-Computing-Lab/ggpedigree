# ggpedigree (development version)
# ==============================

## API notes
* Documented `ggPedigree()` / `ggPedigreeInteractive()` / `ggRelatednessMatrix()` as canonical entry points while retaining backward-compatible aliases.

# ggpedigree 1.1.0.2

## New data
* Added a preliminary Wars of the Roses pedigree dataset.
* Improved dataset documentation.
* Tweaked the GoT dataset example for improved clarity.
* Split the squirrel dataset into smaller pedigrees for testing.

## New features
* Added a greyscale option to `color_theme`.
* Added automatic point scaling based on pedigree size.
* Added optional segment size scaling based on pedigree size.
* Hid the Sex key by default in `ggpedigree`.
* Added a vignette describing `ggpedigree` configuration options.

## Validation and messages
* Performed required-column checks earlier in `ggpedigree()`, including `sex`.
* Improved errors for invalid or non-standard `sex` coding.
* Improved the warning message used in `tryCatch()`.
* Made `code_male` handling more resilient when using config values.

## Bug fixes
* Standardized naming by replacing `midparent` with `mid_parent`.
* Fixed inconsistent handling of character vs numeric IDs.

## Internal changes
* Saved raw Excel inputs as CSV for non-proprietary storage.
* Refactored `kinship2` internals for maintainability.
* Refactored node-adding internals.
* Remove reshape2 dependency

## Testing
* Expanded tests for ID and sex-code inputs, including type, missingness, and configuration scenarios.


# ggpedigree 1.0.0.1
## cran resubmission
* Fixed a minor documentation issue with a URL whose certificate had expired.

# ggpedigree 1.0.0
## cran submission
* Integrated kinship2 functions to remove the dependency
* Made kinship2 package optional, required for plotPedigree (a kinship2 wrapper)
* Importing relevant tests from kinship2 package
* Updated documentation to reflect changes
* Refactored code to improve maintainability
* Added more unit tests for the new functions
* Add max_message_n to pedigree function to allow users to get more messages about pedigree complexity

# ggpedigree 0.9.1
* Minor documentation revisions to complement JOSS paper update
* Added test coverage for buildSpouseSegments

# ggpedigree 0.9.0
## cran release
* smarter segment coloring
* added setting to hide legend for sex
* avoided sapply() in ggPedigreeInteractive
* added subfunction for adding twins
* add non-dot versions of internal functions for evaluating complexity
* added alpha settings
* added compatibility with pedigree objects from kinship2
* exposed code_female, code_na to config
* added tests for kinship2 compatibility
* Updated JOSS paper
* Refactored step 2+3 of the ggpedigree function to .transformPed()
* Renamed p variable as plotObject in ggpedigree subfunctions
* Smarter implementation of aliases
* Updated hex to actually use ggpedigree
* Exposed 'relations' and 'hints' inputs to ggpedigree
* Added more intuitive defaults
* refactor calcCoordinates with alignPedigreeWithHints and alignPedigreeWithRelations
* Vectorized part of calcCoordinates
* removed redundant plotPedigree  verbose section
* add log2 option for relatedness
* Improve plotly conversion

# ggpedigree 0.8.0
## joss paper submitted
* Makes ggrepel a suggested package instead of a required one.
* Make connections included in the plot by default.
* Expose linejoin in ggRelatednessMatrix
* Expose outline_additive and outline_alpha to ggpedigree
* Refactored the ggpedigree function to improve readability and maintainability.
* Transferring ASOIAF data from BGmisc to ggpedigree

# ggpedigree 0.7.1
* Fixed focal_fill ID indexing to row order instead of ID order.
* Fixed bug in using fam_x and fam_y in with generation_height
* Add option to add phantom parents to the pedigree plot.
* Alerts when duplicate or bad configs appear
* Make palleter suggested instead of required

# ggpedigree 0.7.0
* Changed the default behavior of `ggPedigree` to use x_fam and y_fam for positioning families, rather than x_mid_parent and y_mid_parent. This change improves visualization of pedigrees with many families.
* Changed the get midpoint of curvature to better approximate geom_curv behavior.
* reduced redundancy in code base by not calculating the parent midpoints when not needed.
* Added default_config support for ggRelatednessMatrix functions.

# ggpedigree 0.6.1
* Transferred `plotPedigree()` function from BGmisc to ggpedigree.

# ggpedigree 0.6.0
* Implemented fill by matID, patID using various scales, such as hue, viridis, and others.
* Added support for emojis in the `ggpedigree` function.
* Solved the bug that created excessive branches
* Made the twin sibling segments smarter
* Adding more debug support

# ggpedigree 0.5.1
* Fix tooltip appearing in `ggPedigreeInteractive` when tooltip_include is FALSE.

# ggpedigree 0.5.0
* Added segment_linetype and custom affected labels to the `ggpedigree` function.
* Added usage of color_palette to the `ggpedigree` function.
* Added curvature option to the `ggpedigree` function.
* Add support for custom affected labels for affected individuals in the `ggpedigree` function.
* Add support for removing diagonal, upper triangle, and lower triangle in the `ggRelatednessMatrix` function.
* Add support for labeling tiles
* Added new tests for the `ggRelatednessMatrix` function.
* Added new phenotype plotting function `ggPhenotypebyDegree` to visualize phenotypes by degree of relatedness.
* Added new vignette to explain `ggPhenotypebyDegree`.
* Added a new function `getDefaultPlotConfig` to set default configuration options for the package.
* Harmonized the configuration options across the package to use `getDefaultPlotConfig` and buildPlotConfig
* Added unit tests for `getDefaultPlotConfig` and `ggPhenotypebyDegree`
* Added workaround for plotly non-support for geom_curve with computeCurvedMidpoint
* Adding fully twin plotting features
* Added ability to fill colors as a function of the degree of relatedness to a focal person
* Add getDefaultPlotConfig functionality to ggPhenotypebyDegree
* Fully documented getDefaultPlotConfig so that each config option is clear and understandable.

# ggpedigree 0.4.1
## Status: Submitted to CRAN
* Fixed a bug in the `ggpedigree` function that caused an error when using a custom ID name and requesting the plot as a ggplot object.

# ggpedigree 0.4.0
* Allows support for character-based IDs
* Added linejoin, lineend, segment_self_linetype, option to the `ggpedigree` functions.
* Added unit tests for calculateConnections and ggpedigree functions.
* Refactored ggpedigree function into ggpedigree.core and .addScales and .addLabels functions to improve readability and maintainability.
* Renamed symKey to makeSymmetricKey, extended it to support character-based IDs, and added unit tests.
* Added a new function `ggPedigreeInteractive` to create interactive pedigree plots using `plotly`. Added a vignette to show its usage.
* Added redsquirrels dataset to the package for testing and examples.
* Added a new function `ggRelatednessMatrix` and subfunction `ggRelatednessMatrix.core` to create heatmaps of relatedness matrices.
* Added new vignette to explain ggRelatednessMatrix
* Added graphic tests for `ggpedigree`, `ggPedigreeInteractive`, and `ggRelatednessMatrix` functions.
* Updated the README and vignettes to reflect the new features and improvements.
* Updated description to meet CRAN policies.

# ggpedigree 0.3.0
* Expose more labeling options in the `ggpedigree` function to allow for more customization, including nudging labels, and changing the variable used.
* Added option to add an outline to the pedigree plot.
* Made the config options more consistent and user-friendly.
* Enhance the narrative of the plotting vignette to explain the new features and provide clearer examples.
* Added missing examples to the `ggpedigree` function documentation.

# ggpedigree 0.2.0
* Extended functionality to include new plotting features, like handling repeated instances of the same individual in a pedigree.
* Improved documentation and examples for better user guidance.
* Added unit tests for describeHelpers

# ggpedigree 0.1.0
* Implemented pedigree plotting functions for `ggplot2`.
* Added vignette to explain the use of the package in basic plotting.
* Created a `DESCRIPTION` file to define the package and its dependencies.
* Added a `LICENSE` file to specify the terms under which the package applies.
* Created a `CODE_OF_CONDUCT.md` file to outline the expected behavior of contributors and maintainers.
* Added a `NEWS.md` file to track changes to the package.
* Created a `CONTRIBUTING.md` file to guide contributors on how to contribute to the package.
* Added a `README.Rmd` file to provide an overview of the package and its functions.
* Added a `cran-comments.md` file to document the submission process to CRAN.
* Initial version launched
