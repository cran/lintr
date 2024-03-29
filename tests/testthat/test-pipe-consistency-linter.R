test_that("pipe_consistency skips allowed usage", {
  skip_if_not_r_version("4.1.0")
  linter <- pipe_consistency_linter()

  expect_lint("1:3 %>% mean() %>% as.character()", NULL, linter)
  expect_lint("1:3 |> mean() |> as.character()", NULL, linter)
  # With no pipes
  expect_lint("x <- 1:5", NULL, linter)
  # Across multiple lines
  expect_lint(
    trim_some("
      1:3 %>%
        mean() %>%
        as.character()
    "),
    NULL,
    linter
  )
})

test_that("pipe_consistency lints inconsistent usage", {
  skip_if_not_r_version("4.1.0")
  linter <- pipe_consistency_linter()
  expected_msg <- rex("Found 1 instances of %>% and 1 instances of |>. Stick to one pipe operator.")

  expect_lint(
    "1:3 |> mean() %>% as.character()",
    list(
      list(message = expected_msg, line_number = 1L, column_number = 5L),
      list(message = expected_msg, line_number = 1L, column_number = 15L)
    ),
    linter
  )

  expect_lint(
    "1:3 %>% mean() |> as.character()",
    list(
      list(message = expected_msg, line_number = 1L, column_number = 5L),
      list(message = expected_msg, line_number = 1L, column_number = 16L)
    ),
    linter
  )

  expect_lint(
    trim_some("
      1:3 %>%
        mean() |>
        as.character()
    "),
    list(
      list(message = expected_msg, line_number = 1L, column_number = 5L),
      list(message = expected_msg, line_number = 2L, column_number = 10L)
    ),
    linter
  )

  expected_msg_multi <- rex("Found 1 instances of %>% and 2 instances of |>. Stick to one pipe operator.")
  expect_lint(
    "1:3 |> sort() |> mean() %>% as.character()",
    list(
      list(message = expected_msg_multi, line_number = 1L, column_number = 5L),
      list(message = expected_msg_multi, line_number = 1L, column_number = 15L),
      list(message = expected_msg_multi, line_number = 1L, column_number = 25L)
    ),
    linter
  )
})


test_that("pipe_consistency_linter works with |> argument", {
  skip_if_not_r_version("4.1.0")

  linter <- pipe_consistency_linter(pipe = "|>")
  expected_message <- rex("Use the |> pipe operator instead of the %>% pipe operator.")

  expect_lint(
    trim_some("
      1:3 %>%
        mean() %>%
        as.character()
    "),
    list(
      list(message = expected_message, line_number = 1L, column_number = 5L),
      list(message = expected_message, line_number = 2L, column_number = 10L)
    ),
    linter
  )

  expect_lint(
    trim_some("
      1:3 |>
        mean() %>%
        as.character()
    "),
    list(message = expected_message, line_number = 2L, column_number = 10L),
    linter
  )

  expect_lint(
    "1:3 |> mean() |> as.character()",
    NULL,
    linter
  )

  expect_lint(
    trim_some("
      1:3 |>
        mean() %>%
        as.character()
    "),
    list(message = expected_message, line_number = 2L, column_number = 10L),
    linter
  )
})

test_that("pipe_consistency_linter works with %>% argument", {
  skip_if_not_r_version("4.1.0")

  linter <- pipe_consistency_linter(pipe = "%>%")
  expected_message <- rex("Use the %>% pipe operator instead of the |> pipe operator.")

  expect_lint(
    "1:3 |> mean() |> as.character()",
    list(
      list(message = expected_message, line_number = 1L, column_number = 5L),
      list(message = expected_message, line_number = 1L, column_number = 15L)
    ),
    linter
  )

  expect_lint(
    "1:3 %>% mean() |> as.character()",
    list(message = expected_message, line_number = 1L, column_number = 16L),
    linter
  )

  expect_lint(
    "1:3 %>% mean() %>% as.character()",
    NULL,
    linter
  )

  expect_lint(
    trim_some("
      1:3 %>%
        mean() |> 
        as.character()
    "),
    list(message = expected_message, line_number = 2L, column_number = 10L),
    linter
  )
})

test_that("pipe_consistency_linter works with other magrittr pipes", {
  skip_if_not_r_version("4.1.0")
  linter <- pipe_consistency_linter()
  expected_message <- rex("Found 1 instances of %>% and 1 instances of |>. Stick to one pipe operator.")

  expect_lint("1:3 %>% mean() %T% print()", NULL, linter)
  expect_lint(
    "1:3 |> mean() %T>% print()",
    list(
      list(message = expected_message, line_number = 1L, column_number = 5L),
      list(message = expected_message, line_number = 1L, column_number = 15L)
    ),
    linter
  )
})
