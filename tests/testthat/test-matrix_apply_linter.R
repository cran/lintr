test_that("matrix_apply_linter skips allowed usages", {
  linter <- matrix_apply_linter()

  expect_lint("apply(x, 1, prod)", NULL, linter)

  expect_lint("apply(x, 1, function(i) sum(i[i > 0]))", NULL, linter)

  # sum as FUN argument
  expect_lint("apply(x, 1, f, sum)", NULL, linter)

  # mean() with named arguments other than na.rm is skipped because they are not
  # implemented in colMeans() or rowMeans()
  expect_lint("apply(x, 1, mean, trim = 0.2)", NULL, linter)
})

test_that("matrix_apply_linter is not implemented for complex MARGIN values", {
  linter <- matrix_apply_linter()

  # Could be implemented at some point
  expect_lint("apply(x, seq(2, 4), sum)", NULL, linter)

  # No equivalent
  expect_lint("apply(x, c(2, 4), sum)", NULL, linter)

  # Beyond the scope of static analysis
  expect_lint("apply(x, m, sum)", NULL, linter)

  expect_lint("apply(x, 1 + 2:4, sum)", NULL, linter)

})


test_that("matrix_apply_linter simple disallowed usages", {
  linter <- matrix_apply_linter()
  lint_message <- rex::rex("rowSums(x)")

  expect_lint("apply(x, 1, sum)", lint_message, linter)

  expect_lint("apply(x, MARGIN = 1, FUN = sum)", lint_message, linter)

  expect_lint("apply(x, 1L, sum)", lint_message, linter)

  expect_lint("apply(x, 1:4, sum)", rex::rex("rowSums(x, dims = 4)"), linter)

  expect_lint("apply(x, 2, sum)", rex::rex("rowSums(colSums(x))"), linter)

  expect_lint("apply(x, 2:4, sum)", rex::rex("rowSums(colSums(x), dims = 3)"), linter)

  lint_message <- rex::rex("rowMeans")

  expect_lint("apply(x, 1, mean)", lint_message, linter)

  expect_lint("apply(x, MARGIN = 1, FUN = mean)", lint_message, linter)

  # Works with extra args in mean()
  expect_lint("apply(x, 1, mean, na.rm = TRUE)", lint_message, linter)

  lint_message <- rex::rex("colMeans")

  expect_lint("apply(x, 2, mean)", lint_message, linter)

  expect_lint("apply(x, 2:4, mean)", lint_message, linter)

})

test_that("matrix_apply_linter recommendation includes na.rm if present in original call", {
  linter <- matrix_apply_linter()
  lint_message <- rex::rex("na.rm = TRUE")

  expect_lint("apply(x, 1, sum, na.rm = TRUE)", lint_message, linter)

  expect_lint("apply(x, 2, sum, na.rm = TRUE)", lint_message, linter)

  expect_lint("apply(x, 1, mean, na.rm = TRUE)", lint_message, linter)

  expect_lint("apply(x, 2, mean, na.rm = TRUE)", lint_message, linter)

  lint_message <- rex::rex("rowSums(x)")
  expect_lint("apply(x, 1, sum)", lint_message, linter)

  lint_message <- rex::rex("na.rm = foo")
  expect_lint("apply(x, 1, sum, na.rm = foo)", lint_message, linter)

})

test_that("matrix_apply_linter works with multiple lints in a single expression", {
  linter <- matrix_apply_linter()

  expect_lint(
    "rbind(
      apply(x, 1, sum),
      apply(y, 2:4, mean, na.rm = TRUE)
    )",
    list(
      rex::rex("Use rowSums(x)"),
      rex::rex("Use rowMeans(colMeans(y, na.rm = TRUE), dims = 3) or colMeans(y, na.rm = TRUE) if y has 4 dimensions")
    ),
    linter
  )

})
