test_that("extraction_operator_linter skips allowed usages", {
  linter <- extraction_operator_linter()

  expect_lint("x[[1]]", NULL, linter)
  expect_lint("x[-1]", NULL, linter)
  expect_lint("x[1, 'a']", NULL, linter)
  expect_lint("self$a", NULL, linter)
  expect_lint(".self $\na", NULL, linter)
  expect_lint("x[NULL]", NULL, linter)
})

test_that("extraction_operator_linter blocks disallowed usages", {
  linter <- extraction_operator_linter()
  msg_b <- rex::escape("Use `[[` instead of `[` to extract an element.")
  msg_d <- rex::escape("Use `[[` instead of `$` to extract an element.")

  expect_lint("x$a", list(message = msg_d, line_number = 1L, column_number = 2L), linter)
  expect_lint("x $\na", list(message = msg_d, line_number = 1L, column_number = 3L), linter)
  expect_lint("x[++ + 3]", list(message = msg_b, line_number = 1L, column_number = 2L), linter)
  expect_lint(
    "c(x['a'], x [ 1 ])",
    list(
      list(message = msg_b, line_number = 1L, column_number = 4L),
      list(message = msg_b, line_number = 1L, column_number = 13L)
    ),
    linter
  )
})
