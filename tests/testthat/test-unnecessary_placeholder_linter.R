linter <- unnecessary_placeholder_linter()
pipes <- pipes(exclude = "|>")

patrick::with_parameters_test_that(
  "unnecessary_placeholder_linter skips allowed usages",
  {
    # . used in position other than first --> ok
    expect_lint(sprintf("x %s foo(y, .)", pipe), NULL, linter)
    # ditto for nested usage
    expect_lint(sprintf("x %s foo(y, bar(.))", pipe), NULL, linter)
    # . used twice --> ok
    expect_lint(sprintf("x %s foo(., .)", pipe), NULL, linter)
    # . used as a keyword argument --> ok
    expect_lint(sprintf("x %s foo(arg = .)", pipe), NULL, linter)
    # . used inside a scope --> ok
    expect_lint(sprintf("x %s { foo(arg = .) }", pipe), NULL, linter)
  },
  .test_name = names(pipes),
  pipe = pipes
)

patrick::with_parameters_test_that(
  "unnecessary_placeholder_linter blocks simple disallowed usages",
  {
    expect_lint(
      sprintf("x %s sum(.)", pipe),
      rex::rex("Don't use the placeholder (`.`) when it's not needed"),
      unnecessary_placeholder_linter()
    )

    expect_lint(
      sprintf("x %s y(.) %s sum()", pipe, pipe),
      rex::rex("Don't use the placeholder (`.`) when it's not needed"),
      unnecessary_placeholder_linter()
    )
  },
  .test_name = names(pipes),
  pipe = pipes
)
