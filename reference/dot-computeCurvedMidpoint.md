# Compute point along a curved segment (quadratic Bézier)

Computes the x–y coordinates of a point along a curved segment
connecting (x0, y0) to (x1, y1) using a quadratic Bézier construction.
The control point is defined by an orthogonal offset from the
straight-line midpoint, scaled by curvature \* len and rotated by
angle + shift (degrees). Vectorized over input coordinates and t.

## Usage

``` r
.computeCurvedMidpoint(x0, y0, x1, y1, curvature, angle, shift = 0, t = 0.5)

computeCurvedMidpoint(x0, y0, x1, y1, curvature, angle, shift = 0, t = 0.5)
```

## Arguments

- x0:

  Numeric vector. X-coordinates of start points.

- y0:

  Numeric vector. Y-coordinates of start points.

- x1:

  Numeric vector. X-coordinates of end points.

- y1:

  Numeric vector. Y-coordinates of end points.

- curvature:

  Curvature scale factor (as in \*geom_curve\*-style helpers): the
  control point is placed at a distance \`curvature \* len\` from the
  segment midpoint in the rotated-perpendicular direction. Changing the
  sign flips the bend to the opposite side (after rotation).

- angle:

  Scalar numeric. Base rotation in degrees applied to the perpendicular
  before offsetting.

- shift:

  Scalar numeric. Additional rotation in degrees (default 0). Effective
  rotation is angle + shift.

- t:

  Numeric scalar or vector in \[0, 1\]. Bézier parameter where 0 is the
  start point, 1 is the end point; default 0.5.

## Value

A data frame with columns x, y, and t representing the coordinates along
the curved segment.

## Details

\* The unit perpendicular is constructed from the segment direction
\`(dx, dy)\` as \`(-uy, ux)\` where \`(ux, uy) = (dx, dy) / len\`. \* If
an input pair yields \`len = 0\` (identical endpoints), the unit
direction is undefined and the resulting coordinates will be \`NA\` due
to division by zero; inputs should avoid zero-length segments. \* Inputs
of unequal length are recycled by base R. Prefer supplying conformable
vectors to avoid unintended recycling.

## See also

Related drawing helpers such as \`ggplot2::geom_curve()\` for visual
reference on curvature semantics.
