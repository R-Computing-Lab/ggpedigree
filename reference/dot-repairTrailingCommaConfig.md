# Repair a \`config\` argument broken by a trailing comma

Internal helper. Writing \`config = list(point_size = 6, )\` makes R
throw \`"argument N is empty"\` the moment the \`config\` promise is
forced, because the trailing comma leaves a missing argument in the
call. Since the error happens while forcing the promise, the original
unevaluated call is still available via \`substitute()\`. This
re-evaluates that call with the empty argument(s) removed so the user
does not have to manually delete the comma. Any error that isn't caused
by a trailing/empty argument inside a direct \`list()\`/\`c()\` call is
rethrown unchanged.

## Usage

``` r
.repairTrailingCommaConfig(config_expr, envir, original_error)
```

## Arguments

- config_expr:

  The unevaluated expression bound to \`config\`, captured via
  \`substitute(config)\` before \`config\` is touched.

- envir:

  The environment in which \`config_expr\` should be evaluated (the
  caller's environment).

- original_error:

  The condition caught while forcing \`config\`, rethrown verbatim when
  the expression cannot be repaired.

## Value

The repaired \`config\` value.
