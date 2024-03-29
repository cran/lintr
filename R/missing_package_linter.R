#' Missing package linter
#'
#' Check for missing packages in `library()`, `require()`, `loadNamespace()`, and `requireNamespace()` calls.
#'
#' @examples
#' # will produce lints
#' lint(
#'   text = "library(xyzxyz)",
#'   linters = missing_package_linter()
#' )
#'
#' # okay
#' lint(
#'   text = "library(stats)",
#'   linters = missing_package_linter()
#' )
#'
#' @evalRd rd_tags("missing_package_linter")
#' @seealso [linters] for a complete list of linters available in lintr.
#' @export
missing_package_linter <- function() {
  library_require_xpath <- "
  //SYMBOL_FUNCTION_CALL[text() = 'library' or text() = 'require']
    /parent::expr
    /parent::expr[
      expr[2][STR_CONST]
      or (
        expr[2][SYMBOL]
        and not(
          SYMBOL_SUB[text() = 'character.only']
          /following-sibling::expr[1]
          /NUM_CONST[text() = 'TRUE' or text() = 'T']
        )
      )
    ]
  "
  load_require_namespace_xpath <- "
  //SYMBOL_FUNCTION_CALL[text() = 'loadNamespace' or text() = 'requireNamespace']
    /parent::expr
    /following-sibling::expr[1][STR_CONST]
    /parent::expr
  "
  call_xpath <- paste(library_require_xpath, "|", load_require_namespace_xpath)

  Linter(function(source_expression) {
    if (!is_lint_level(source_expression, "file")) {
      return(list())
    }

    xml <- source_expression$full_xml_parsed_content

    pkg_calls <- xml_find_all(xml, call_xpath)
    pkg_names <- get_r_string(xml_find_all(
      pkg_calls,
      "OP-LEFT-PAREN[1]/following-sibling::expr[1][SYMBOL | STR_CONST]"
    ))

    # run here, not in the factory, to allow for run- vs. "compile"-time differences in available packages
    installed_packges <- .packages(all.available = TRUE)
    missing_pkgs <- !(pkg_names %in% installed_packges)

    xml_nodes_to_lints(
      pkg_calls[missing_pkgs],
      source_expression = source_expression,
      lint_message = sprintf("Package '%s' is not installed.", pkg_names[missing_pkgs]),
      type = "warning"
    )
  })
}
