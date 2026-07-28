#' Repair a `config` argument broken by a trailing comma
#' @description
#' Internal helper. Writing `config = list(point_size = 6, )` makes R throw
#' `"argument N is empty"` the moment the `config` promise is forced, because
#' the trailing comma leaves a missing argument in the call. Since the error
#' happens while forcing the promise, the original unevaluated call is still
#' available via `substitute()`. This re-evaluates that call with the empty
#' argument(s) removed so the user does not have to manually delete the comma.
#' Any error that isn't caused by a trailing/empty argument inside a direct
#' `list()`/`c()` call is rethrown unchanged.
#' @param config_expr The unevaluated expression bound to `config`, captured
#'   via `substitute(config)` before `config` is touched.
#' @param envir The environment in which `config_expr` should be evaluated
#'   (the caller's environment).
#' @param original_error The condition caught while forcing `config`,
#'   rethrown verbatim when the expression cannot be repaired.
#' @return The repaired `config` value.
#' @keywords internal
.repairTrailingCommaConfig <- function(config_expr, envir, original_error) {
  fn <- if (is.call(config_expr)) config_expr[[1]] else NULL
  can_repair <- !is.null(fn) && (identical(fn, quote(list)) || identical(fn, quote(c)))

  if (can_repair) {
    args <- as.list(config_expr)
    is_empty <- vapply(args, identical, logical(1), quote(expr = ))
    can_repair <- any(is_empty)
  }

  if (!can_repair) {
    stop(original_error)
  }

  fixed_expr <- as.call(args[!is_empty])
  message(
    "Detected and removed a trailing comma in `config`; ",
    "consider deleting it to avoid this message in the future."
  )
  eval(fixed_expr, envir = envir)
}
