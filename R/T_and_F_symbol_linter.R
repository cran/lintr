#' `T` and `F` symbol linter
#'
#' Avoid the symbols `T` and `F`, and use `TRUE` and `FALSE` instead.
#'
#' @examples
#' # will produce lints
#' lint(
#'   text = "x <- T; y <- F",
#'   linters = T_and_F_symbol_linter()
#' )
#'
#' lint(
#'   text = "T = 1.2; F = 2.4",
#'   linters = T_and_F_symbol_linter()
#' )
#'
#' # okay
#' lint(
#'   text = "x <- c(TRUE, FALSE)",
#'   linters = T_and_F_symbol_linter()
#' )
#'
#' lint(
#'   text = "t = 1.2; f = 2.4",
#'   linters = T_and_F_symbol_linter()
#' )
#'
#' @evalRd rd_tags("T_and_F_symbol_linter")
#' @seealso
#' - [linters] for a complete list of linters available in lintr.
#' - <https://style.tidyverse.org/syntax.html#logical-vectors>
#' @export
T_and_F_symbol_linter <- function() { # nolint: object_name.
  symbol_xpath <- "//SYMBOL[
    (text() = 'T' or text() = 'F')
    and not(parent::expr[OP-DOLLAR or OP-AT])
  ]"
  assignment_xpath <-
    "parent::expr[following-sibling::LEFT_ASSIGN or preceding-sibling::RIGHT_ASSIGN or following-sibling::EQ_ASSIGN]"

  usage_xpath <- sprintf("%s[not(%s)]", symbol_xpath, assignment_xpath)
  assignment_xpath <- sprintf("%s[%s]", symbol_xpath, assignment_xpath)

  replacement_map <- c(T = "TRUE", F = "FALSE")

  Linter(function(source_expression) {
    if (!is_lint_level(source_expression, "expression")) {
      return(list())
    }

    bad_usage <- xml_find_all(source_expression$xml_parsed_content, usage_xpath)
    bad_assignment <- xml_find_all(source_expression$xml_parsed_content, assignment_xpath)

    make_lints <- function(expr, fmt) {
      symbol <- xml_text(expr)
      lint_message <- sprintf(fmt, replacement_map[symbol], symbol)
      xml_nodes_to_lints(
        xml = expr,
        source_expression = source_expression,
        lint_message = lint_message,
        type = "style",
        column_number_xpath = "number(./@col2 + 1)", # mark at end
        range_end_xpath = "number(./@col2 + 1)" # end after T/F for easy fixing
      )
    }

    c(
      make_lints(bad_usage, "Use %s instead of the symbol %s."),
      make_lints(bad_assignment, "Don't use %2$s as a variable name, as it can break code relying on %2$s being %1$s.")
    )
  })
}
