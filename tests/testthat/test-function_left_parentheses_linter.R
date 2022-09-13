test_that("returns the correct linting", {
  linter <- function_left_parentheses_linter()
  msg <- rex("Remove spaces before the left parenthesis in a function call.")

  expect_lint("blah", NULL, linter)
  expect_lint("print(blah)", NULL, linter)
  expect_lint("base::print(blah)", NULL, linter)
  expect_lint("base::print(blah, fun(1))", NULL, linter)
  expect_lint("blah <- function(blah) { }", NULL, linter)
  expect_lint("(1 + 1)", NULL, linter)
  expect_lint("( (1 + 1) )", NULL, linter)
  expect_lint("if (blah) { }", NULL, linter)
  expect_lint("for (i in j) { }", NULL, linter)
  expect_lint("1 * (1 + 1)", NULL, linter)
  expect_lint("!(1 == 1)", NULL, linter)
  expect_lint("(2 - 1):(3 - 1)", NULL, linter)
  expect_lint("c(1, 2, 3)[(2 - 1)]", NULL, linter)
  expect_lint("list(1, 2, 3)[[(2 - 1)]]", NULL, linter)
  expect_lint("range(10)[(2 - 1):(10 - 1)]", NULL, linter)
  expect_lint("function(){function(){}}()()", NULL, linter)
  expect_lint("c(function(){})[1]()", NULL, linter)
  expect_lint("function(x) (mean(x) + 3)", NULL, linter)
  expect_lint("\"blah (1)\"", NULL, linter)

  expect_lint("blah (1)", msg, linter)
  expect_lint("base::print (blah)", msg, linter)
  expect_lint("base::print(blah, f (1))", msg, linter)
  expect_lint("`+` (1, 1)", msg, linter)
  expect_lint("test <- function (x) { }", msg, linter)

  expect_lint(
    "blah  (1)",
    list(message = msg, column_number = 5L, ranges = list(c(5L, 6L))),
    linter
  )
  expect_lint(
    "test <- function  (x) { }",
    list(message = msg, column_number = 17L, ranges = list(c(17L, 18L))),
    linter
  )
})