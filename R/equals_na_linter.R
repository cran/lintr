#' Equality check with NA linter
#'
#' Check for `x == NA`, `x != NA` and `x %in% NA`. Such usage is almost surely incorrect --
#' checks for missing values should be done with [is.na()].
#'
#' @examples
#' # will produce lints
#' lint(
#'   text = "x == NA",
#'   linters = equals_na_linter()
#' )
#'
#' lint(
#'   text = "x != NA",
#'   linters = equals_na_linter()
#' )
#'
#' lint(
#'   text = "x %in% NA",
#'   linters = equals_na_linter()
#' )
#'
#' # okay
#' lint(
#'   text = "is.na(x)",
#'   linters = equals_na_linter()
#' )
#'
#' lint(
#'   text = "!is.na(x)",
#'   linters = equals_na_linter()
#' )
#'
#' @evalRd rd_tags("equals_na_linter")
#' @seealso [linters] for a complete list of linters available in lintr.
#' @export
equals_na_linter <- function() {
  na_table <- xp_text_in_table(c("NA", "NA_integer_", "NA_real_", "NA_complex_", "NA_character_"))

  xpath <- glue("
  //NUM_CONST[ {na_table} ]
    /parent::expr
    /parent::expr[EQ or NE]
  |
  //SPECIAL[text() = '%in%' and following-sibling::expr/NUM_CONST[ {na_table} ]]
    /parent::expr
  ")

  Linter(function(source_expression) {
    if (!is_lint_level(source_expression, "expression")) {
      return(list())
    }

    xml <- source_expression$xml_parsed_content

    bad_expr <- xml_find_all(xml, xpath)

    xml_nodes_to_lints(
      bad_expr,
      source_expression,
      lint_message = "Use is.na for comparisons to NA (not == or != or %in%)",
      type = "warning"
    )
  })
}
