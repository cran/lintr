#' Block obvious "yoda tests"
#'
#' Yoda tests use `(expected, actual)` instead of the more common `(actual, expected)`.
#' This is not always possible to detect statically; this linter focuses on
#'   the simple case of testing an expression against a literal value, e.g.
#'   `(1L, foo(x))` should be `(foo(x), 1L)`.
#'
#' @examples
#' # will produce lints
#' lint(
#'   text = "expect_equal(2, x)",
#'   linters = yoda_test_linter()
#' )
#'
#' lint(
#'   text = 'expect_identical("a", x)',
#'   linters = yoda_test_linter()
#' )
#'
#' # okay
#' lint(
#'   text = "expect_equal(x, 2)",
#'   linters = yoda_test_linter()
#' )
#'
#' lint(
#'   text = 'expect_identical(x, "a")',
#'   linters = yoda_test_linter()
#' )
#'
#' @evalRd rd_tags("yoda_test_linter")
#' @seealso
#'   [linters] for a complete list of linters available in lintr.
#'   <https://en.wikipedia.org/wiki/Yoda_conditions>
#' @export
yoda_test_linter <- function() {
  # catch the following types of literal in the first argument:
  #   (1) numeric literal (e.g. TRUE, 1L, 1.0, NA) [NUM_CONST]
  #   (2) string literal (e.g. 'str' or "str")     [STR_CONST]
  #       (but _not_ x$"key", #1067)
  #   (3) arithmetic literal (e.g. 1+1 or 0+1i)    [OP-PLUS or OP-MINUS...]
  # TODO(#963): fully generalize this & re-use elsewhere
  const_condition <- "
    NUM_CONST
    or (STR_CONST and not(OP-DOLLAR or OP-AT))
    or ((OP-PLUS or OP-MINUS) and count(expr[NUM_CONST]) = 2)
  "
  pipes <- setdiff(magrittr_pipes, c("%$%", "%<>%"))
  xpath <- glue("
  //SYMBOL_FUNCTION_CALL[text() = 'expect_equal' or text() = 'expect_identical' or text() = 'expect_setequal']
    /parent::expr
    /following-sibling::expr[1][ {const_condition} ]
    /parent::expr[not(preceding-sibling::*[self::PIPE or self::SPECIAL[{ xp_text_in_table(pipes) }]])]
  ")

  second_const_xpath <- glue("expr[position() = 3 and ({const_condition})]")

  Linter(function(source_expression) {
    if (!is_lint_level(source_expression, "expression")) {
      return(list())
    }

    xml <- source_expression$xml_parsed_content

    bad_expr <- xml_find_all(xml, xpath)

    matched_call <- xp_call_name(bad_expr)
    second_const <- xml_find_first(bad_expr, second_const_xpath)
    lint_message <- ifelse(
      is.na(second_const),
      paste(
        "Tests should compare objects in the order 'actual', 'expected', not the reverse.",
        sprintf("For example, do %1$s(foo(x), 2L) instead of %1$s(2L, foo(x)).", matched_call)
      ),
      sprintf("Avoid storing placeholder tests like %s(1, 1)", matched_call)
    )

    xml_nodes_to_lints(bad_expr, source_expression, lint_message, type = "warning")
  })
}
