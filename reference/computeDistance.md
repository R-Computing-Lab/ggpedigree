# Compute distance between two points

This function calculates the distance between two points in a 2D space
using Minkowski distance. It can be used to compute Euclidean or
Manhattan distance. It is a utility function for calculating distances
in pedigree layouts. Defaults to Euclidean distance if no method is
specified.

## Usage

``` r
computeDistance(method = "euclidean", x1, y1, x2, y2, p = NULL)
```

## Arguments

- method:

  Character. Method of distance calculation. Options are "euclidean",
  "cityblock", and "Minkowski".

- x1:

  Numeric. X-coordinate of the first point.

- y1:

  Numeric. Y-coordinate of the first point.

- x2:

  Numeric. X-coordinate of the second point.

- y2:

  Numeric. Y-coordinate of the second point.

- p:

  Numeric. The order of the Minkowski distance. If NULL, defaults to 2
  for Euclidean and 1 for Manhattan. If Minkowski method is used, p
  should be specified.
