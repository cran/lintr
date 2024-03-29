test_that("strings_as_factors_linter skips allowed usages", {
  linter <- strings_as_factors_linter()

  expect_lint("data.frame(1:3)", NULL, linter)
  expect_lint("data.frame(x = 1:3)", NULL, linter)

  expect_lint("data.frame(x = 'a', stringsAsFactors = TRUE)", NULL, linter)
  expect_lint("data.frame(x = 'a', stringsAsFactors = FALSE)", NULL, linter)
  expect_lint("data.frame(x = c('a', 'b'), stringsAsFactors = FALSE)", NULL, linter)

  # strings in argument names to c() don't get linted
  expect_lint("data.frame(x = c('a b' = 1L, 'b c' = 2L))", NULL, linter)

  # characters supplied to row.names are not affected
  expect_lint("data.frame(x = 1:3, row.names = c('a', 'b', 'c'))", NULL, linter)

  # ambiguous cases passes
  expect_lint("data.frame(x = c(xx, 'a'))", NULL, linter)
  expect_lint("data.frame(x = c(foo(y), 'a'))", NULL, linter)
})

test_that("strings_as_factors_linter blocks simple disallowed usages", {
  linter <- strings_as_factors_linter()
  lint_msg <- "This code relies on the default value of stringsAsFactors"

  expect_lint("data.frame('a')", lint_msg, linter)
  expect_lint("data.frame(c('a', 'b'))", lint_msg, linter)
  expect_lint("data.frame(x = 1:5, y = 'b')", lint_msg, linter)
  expect_lint("data.frame(x = 1:5, y, z = 'b')", lint_msg, linter)

  # catch row.names when combined with a character vector
  expect_lint("data.frame(x = c('c', 'd', 'e'), row.names = c('a', 'b', 'c'))", lint_msg, linter)
  expect_lint("data.frame(row.names = c('c', 'd', 'e'), x = c('a', 'b', 'c'))", lint_msg, linter)

  # when everything is a literal, type promotion means the column is character
  expect_lint("data.frame(x = c(TRUE, 'a'))", lint_msg, linter)
})

test_that("strings_as_factors_linters catches rep(char) usages", {
  linter <- strings_as_factors_linter()
  lint_msg <- "This code relies on the default value of stringsAsFactors"

  expect_lint("data.frame(rep('a', 10L))", lint_msg, linter)
  expect_lint("data.frame(rep(c('a', 'b'), 10L))", lint_msg, linter)

  # literal char, not mixed or non-char
  expect_lint("data.frame(rep(1L, 10L))", NULL, linter)
  expect_lint("data.frame(rep(c(x, 'a'), 10L))", NULL, linter)
  # however, type promotion of literals is caught
  expect_lint("data.frame(rep(c(TRUE, 'a'), 10L))", lint_msg, linter)
})

test_that("strings_as_factors_linter catches character(), as.character() usages", {
  linter <- strings_as_factors_linter()
  lint_msg <- "This code relies on the default value of stringsAsFactors"

  expect_lint("data.frame(a = character())", lint_msg, linter)
  expect_lint("data.frame(a = character(1L))", lint_msg, linter)
  expect_lint("data.frame(a = as.character(x))", lint_msg, linter)

  # but not for row.names
  expect_lint("data.frame(a = 1:10, row.names = as.character(1:10))", NULL, linter)
})

test_that("strings_as_factors_linter catches more functions with string output", {
  linter <- strings_as_factors_linter()
  lint_msg <- "This code relies on the default value of stringsAsFactors"

  expect_lint("data.frame(a = paste(1, 2, 3))", lint_msg, linter)
  expect_lint("data.frame(a = sprintf('%d', 1:10))", lint_msg, linter)
  expect_lint("data.frame(a = format(x, just = 'right'))", lint_msg, linter)
  expect_lint("data.frame(a = formatC(x, format = '%d'))", lint_msg, linter)
  expect_lint("data.frame(a = prettyNum(x, big.mark = ','))", lint_msg, linter)
  expect_lint("data.frame(a = toString(x))", lint_msg, linter)
  expect_lint("data.frame(a = encodeString(x))", lint_msg, linter)
  # but not for row.names
  expect_lint("data.frame(a = 1:10, row.names = paste(1:10))", NULL, linter)
})
