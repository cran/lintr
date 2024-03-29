% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/string_boundary_linter.R
\name{string_boundary_linter}
\alias{string_boundary_linter}
\title{Require usage of \code{startsWith()} and \code{endsWith()} over \code{grepl()}/\code{substr()} versions}
\usage{
string_boundary_linter(allow_grepl = FALSE)
}
\arguments{
\item{allow_grepl}{Logical, default \code{FALSE}. If \code{TRUE}, usages with \code{grepl()}
are ignored. Some authors may prefer the conciseness offered by \code{grepl()} whereby
\code{NA} input maps to \code{FALSE} output, which doesn't have a direct equivalent
with \code{startsWith()} or \code{endsWith()}.}
}
\description{
\code{\link[=startsWith]{startsWith()}} is used to detect fixed initial substrings; it is more
readable and more efficient than equivalents using \code{\link[=grepl]{grepl()}} or \code{\link[=substr]{substr()}}.
c.f. \code{startsWith(x, "abc")}, \code{grepl("^abc", x)},
\code{substr(x, 1L, 3L) == "abc"}.
}
\details{
Ditto for using \code{\link[=endsWith]{endsWith()}} to detect fixed terminal substrings.

Note that there is a difference in behavior between how \code{grepl()} and \code{startsWith()}
(and \code{endsWith()}) handle missing values. In particular, for \code{grepl()}, \code{NA} inputs
are considered \code{FALSE}, while for \code{startsWith()}, \code{NA} inputs have \code{NA} outputs.
That means the strict equivalent of \code{grepl("^abc", x)} is
\code{!is.na(x) & startsWith(x, "abc")}.

We lint \code{grepl()} usages by default because the \code{!is.na()} version is more explicit
with respect to \code{NA} handling -- though documented, the way \code{grepl()} handles
missing inputs may be surprising to some users.
}
\examples{
# will produce lints
lint(
  text = 'grepl("^a", x)',
  linters = string_boundary_linter()
)

lint(
  text = 'grepl("z$", x)',
  linters = string_boundary_linter()
)

# okay
lint(
  text = 'startsWith(x, "a")',
  linters = string_boundary_linter()
)

lint(
  text = 'endsWith(x, "z")',
  linters = string_boundary_linter()
)

# If missing values are present, the suggested alternative wouldn't be strictly
# equivalent, so this linter can also be turned off in such cases.
lint(
  text = 'grepl("z$", x)',
  linters = string_boundary_linter(allow_grepl = TRUE)
)

}
\seealso{
\link{linters} for a complete list of linters available in lintr.
}
\section{Tags}{
\link[=configurable_linters]{configurable}, \link[=efficiency_linters]{efficiency}, \link[=readability_linters]{readability}
}
