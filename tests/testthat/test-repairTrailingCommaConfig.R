test_that(".repairTrailingCommaConfig repairs a trailing comma in list()", {
  config_expr <- quote(list(point_size = 6, label_include = TRUE, ))
  original_error <- simpleError("argument 3 is empty")

  expect_message(
    result <- .repairTrailingCommaConfig(config_expr, parent.frame(), original_error),
    "trailing comma"
  )
  expect_equal(result, list(point_size = 6, label_include = TRUE))
})

test_that(".repairTrailingCommaConfig repairs a trailing comma in c()", {
  config_expr <- quote(c(a = 1, b = 2, ))
  original_error <- simpleError("argument 3 is empty")

  expect_message(
    result <- .repairTrailingCommaConfig(config_expr, parent.frame(), original_error),
    "trailing comma"
  )
  expect_equal(result, c(a = 1, b = 2))
})

test_that(".repairTrailingCommaConfig evaluates the repaired call in the supplied environment", {
  config_expr <- quote(list(point_size = my_point_size, ))
  env <- new.env()
  env$my_point_size <- 42
  original_error <- simpleError("argument 2 is empty")

  result <- suppressMessages(
    .repairTrailingCommaConfig(config_expr, env, original_error)
  )
  expect_equal(result, list(point_size = 42))
})

test_that(".repairTrailingCommaConfig rethrows the original error when there is no empty argument", {
  config_expr <- quote(list(point_size = stop("boom")))
  original_error <- simpleError("boom")

  expect_error(
    .repairTrailingCommaConfig(config_expr, parent.frame(), original_error),
    "boom"
  )
})

test_that(".repairTrailingCommaConfig rethrows the original error when config is not a list()/c() call", {
  config_expr <- quote(my_config_variable)
  original_error <- simpleError("object 'my_config_variable' not found")

  expect_error(
    .repairTrailingCommaConfig(config_expr, parent.frame(), original_error),
    "my_config_variable"
  )

  config_expr2 <- quote(some_function(a = 1, ))
  original_error2 <- simpleError("argument 2 is empty")

  expect_error(
    .repairTrailingCommaConfig(config_expr2, parent.frame(), original_error2),
    "argument 2 is empty"
  )
})
