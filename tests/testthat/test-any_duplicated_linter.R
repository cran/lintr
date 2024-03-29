test_that("any_duplicated_linter skips allowed usages", {
  linter <- any_duplicated_linter()

  expect_lint("x <- any(y)", NULL, linter)
  expect_lint("y <- duplicated(z)", NULL, linter)

  # extended usage of any is not covered
  expect_lint("any(duplicated(y), b)", NULL, linter)
  expect_lint("any(b, duplicated(y))", NULL, linter)
})

test_that("any_duplicated_linter blocks simple disallowed usages", {
  expect_lint(
    "any(duplicated(x))",
    rex::rex("anyDuplicated(x, ...) > 0 is better"),
    any_duplicated_linter()
  )

  expect_lint(
    "any(duplicated(foo(x)))",
    rex::rex("anyDuplicated(x, ...) > 0 is better"),
    any_duplicated_linter()
  )

  # na.rm doesn't really matter for this since duplicated can't return NA
  expect_lint(
    "any(duplicated(x), na.rm = TRUE)",
    rex::rex("anyDuplicated(x, ...) > 0 is better"),
    any_duplicated_linter()
  )

  # also catch nested usage
  expect_lint(
    "foo(any(duplicated(x)))",
    rex::rex("anyDuplicated(x, ...) > 0 is better"),
    any_duplicated_linter()
  )
})

test_that("any_duplicated_linter catches length(unique()) equivalencies too", {
  # non-matches
  ## different variable
  expect_lint("length(unique(x)) == length(y)", NULL, any_duplicated_linter())
  ## different table
  expect_lint("length(unique(DF$x)) == nrow(DT)", NULL, any_duplicated_linter())
  expect_lint("length(unique(l1$DF$x)) == nrow(l2$DF)", NULL, any_duplicated_linter())

  # lintable usage
  expect_lint(
    "length(unique(x)) == length(x)",
    rex::rex("anyDuplicated(x) == 0L is better than length(unique(x)) == length(x)"),
    any_duplicated_linter()
  )
  # argument order doesn't matter
  expect_lint(
    "length(x) == length(unique(x))",
    rex::rex("anyDuplicated(x) == 0L is better than length(unique(x)) == length(x)"),
    any_duplicated_linter()
  )
  # nrow-style equivalency
  expect_lint(
    "nrow(DF) == length(unique(DF$col))",
    rex::rex("anyDuplicated(DF$col) == 0L is better than length(unique(DF$col)) == nrow(DF)"),
    any_duplicated_linter()
  )
  expect_lint(
    "nrow(DF) == length(unique(DF[['col']]))",
    rex::rex("anyDuplicated(DF$col) == 0L is better than length(unique(DF$col)) == nrow(DF)"),
    any_duplicated_linter()
  )
  # match with nesting too
  expect_lint(
    "nrow(l$DF) == length(unique(l$DF[['col']]))",
    rex::rex("anyDuplicated(DF$col) == 0L is better than length(unique(DF$col)) == nrow(DF)"),
    any_duplicated_linter()
  )

  # !=, <, and > usages are all alternative ways of writing a test for dupes
  #   technically, the direction of > / < matter, but writing
  #   length(unique(x)) > length(x) doesn't seem like it would ever happen.
  expect_lint(
    "length(unique(x)) != length(x)",
    rex::rex("anyDuplicated(x) == 0L is better than length(unique(x)) == length(x)"),
    any_duplicated_linter()
  )
  expect_lint(
    "length(unique(x)) < length(x)",
    rex::rex("anyDuplicated(x) == 0L is better than length(unique(x)) == length(x)"),
    any_duplicated_linter()
  )
  expect_lint(
    "length(x) > length(unique(x))",
    rex::rex("anyDuplicated(x) == 0L is better than length(unique(x)) == length(x)"),
    any_duplicated_linter()
  )

  # TODO(michaelchirico): try and match data.table- and dplyr-specific versions of
  #   this, e.g. DT[, length(unique(col)) == .N] or
  #   > DT %>% filter(length(unique(col)) == n())
})

test_that("any_duplicated_linter catches expression with two types of lint", {
  expect_lint(
    "table(any(duplicated(x)), length(unique(DF$col)) == nrow(DF))",
    list(
      rex::rex("anyDuplicated(x, ...) > 0 is better"),
      rex::rex("anyDuplicated(DF$col) == 0L is better than length(unique(DF$col)) == nrow(DF)")
    ),
    any_duplicated_linter()
  )

  # ditto for different messages within the length(unique()) tests
  expect_lint(
    "table(length(unique(x)) == length(x), length(unique(DF$col)) == nrow(DF))",
    list(
      rex::rex("anyDuplicated(x) == 0L is better than length(unique(x)) == length(x)"),
      rex::rex("anyDuplicated(DF$col) == 0L is better than length(unique(DF$col)) == nrow(DF)")
    ),
    any_duplicated_linter()
  )
})
