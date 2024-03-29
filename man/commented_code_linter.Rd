% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/comment_linters.R
\name{commented_code_linter}
\alias{commented_code_linter}
\title{Commented code linter}
\usage{
commented_code_linter()
}
\description{
Check that there is no commented code outside roxygen blocks.
}
\examples{
# will produce lints
lint(
  text = "# x <- 1",
  linters = commented_code_linter()
)

lint(
  text = "x <- f() # g()",
  linters = commented_code_linter()
)

lint(
  text = "x + y # + z[1, 2]",
  linters = commented_code_linter()
)

# okay
lint(
  text = "x <- 1; x <- f(); x + y",
  linters = commented_code_linter()
)

lint(
  text = "#' x <- 1",
  linters = commented_code_linter()
)

}
\seealso{
\link{linters} for a complete list of linters available in lintr.
}
\section{Tags}{
\link[=best_practices_linters]{best_practices}, \link[=default_linters]{default}, \link[=readability_linters]{readability}, \link[=style_linters]{style}
}
