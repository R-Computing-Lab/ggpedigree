# Score a pedigree layout

Returns a single non-negative number summarising layout quality;
\*\*lower is better\*\*. Five methods are available, controlled by
\`method\`:

- \`"parent_stub"\`:

  Sum of \`\|x_fam - x_pos\|\` over all placed individuals. Measures
  total diagonal parent-stub length: children ideally sit directly below
  their parent midpoint. Fast, O(n).

- \`"crossings"\`:

  Count of parent-stub inversion pairs within each generation: two stubs
  cross when the lateral order of children is reversed relative to the
  order of their parent midpoints. O(n²) per generation but still fast
  for typical pedigree sizes.

- \`"duplications"\`:

  Number of individuals kinship2 had to place twice (\`extra = TRUE\`
  rows). Each duplication produces a self-loop in the plot; fewer is
  better.

- \`"twin_penalty"\`:

  Sum of intruder positions separating co-twins within their generation
  row. For N twins placed adjacently the penalty is 0; each non-twin
  slot that separates them adds 1. Twins in different generation rows
  receive a heavy flat penalty.

- \`"composite"\`:

  Weighted sum: \`parent_stub + 10 \* crossings + 20 \* twin_penalty +
  100 \* duplications\`. Penalizes duplications most heavily, then twin
  separation, then crossings, then stub length. Good default when you
  have no strong preference.

Used by the \`founder_order_tries\` search to rank candidate layouts
when \`founder_order_tries \> 1\` or \`founder_order_seed\` is set.

Returns a single non-negative number summarising layout quality;
\*\*lower is better\*\*. Five methods are available, controlled by
\`method\`:

- \`"parent_stub"\`:

  Sum of \`\|x_fam - x_pos\|\` over all placed individuals. Measures
  total diagonal parent-stub length: children ideally sit directly below
  their parent midpoint. Fast, O(n).

- \`"crossings"\`:

  Count of parent-stub inversion pairs within each generation: two stubs
  cross when the lateral order of children is reversed relative to the
  order of their parent midpoints. O(n²) per generation but still fast
  for typical pedigree sizes.

- \`"duplications"\`:

  Number of individuals kinship2 had to place twice (\`extra = TRUE\`
  rows). Each duplication produces a self-loop in the plot; fewer is
  better.

- \`"twin_penalty"\`:

  Sum of intruder positions separating co-twins within their generation
  row. For N twins placed adjacently the penalty is 0; each non-twin
  slot that separates them adds 1. Twins in different generation rows
  receive a heavy flat penalty.

- \`"composite"\`:

  Weighted sum: \`parent_stub + 10 \* crossings + 20 \* twin_penalty +
  100 \* duplications\`. Penalises duplications most heavily, then twin
  separation, then crossings, then stub length. Good default when you
  have no strong preference.

Used by the \`founder_order_tries\` search to rank candidate layouts
when \`founder_order_tries \> 1\` or \`founder_order_seed\` is set.

## Usage

``` r
.layoutScore(
  ds,
  method = c("parent_stub", "crossings", "duplications", "twin_penalty", "composite",
    "parent_offset", "minimal_duplicates"),
  twinID = "twinID",
  cross_gen_penalty = 10L,
  twin_penalty_weight = 20L,
  duplication_weight = 100L
)

.layoutScore(
  ds,
  method = c("parent_stub", "crossings", "duplications", "twin_penalty", "composite",
    "parent_offset", "minimal_duplicates"),
  twinID = "twinID",
  cross_gen_penalty = 10L,
  twin_penalty_weight = 20L,
  duplication_weight = 100L
)
```

## Arguments

- ds:

  Data frame produced by \`calculateCoordinates\`.

- method:

  One of \`"parent_stub"\` (default), \`"crossings"\`,
  \`"duplications"\`, \`"twin_penalty"\`, or \`"composite"\`.

- twinID:

  Character name of the twin-group ID column in \`ds\`. Passed to
  \`.layoutScoreTwinPenalty()\`. Defaults to \`"twinID"\`.

- cross_gen_penalty:

  Numeric penalty for twins in different generation rows. Passed to
  \`.layoutScoreTwinPenalty()\`. Default is 10.

- twin_penalty_weight:

  Numeric weight for the twin penalty in the composite score. Default is
  20.

- duplication_weight:

  Numeric weight for the duplication count in the composite score.
  Default is 100.

## Value

A single numeric value (≥ 0).

A single numeric value (≥ 0).
