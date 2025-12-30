# Pick First Matching Rule

This function evaluates a list of rules and returns the action
associated with the first rule that matches. If no rules match, it
returns a default value.

## Usage

``` r
.pick_first(rules, default = NULL)
```

## Arguments

- rules:

  A list of rules, where each rule is a list with \`when\` and \`do\`
  elements.

- default:

  The default value to return if no rules match (default is NULL).

## Value

The action associated with the first matching rule, or the default
value.
