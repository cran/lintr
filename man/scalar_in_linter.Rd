% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/scalar_in_linter.R
\name{scalar_in_linter}
\alias{scalar_in_linter}
\title{Block usage like x \%in\% "a"}
\usage{
scalar_in_linter()
}
\description{
\code{vector \%in\% set} is appropriate for matching a vector to a set, but if
that set has size 1, \code{==} is more appropriate. \verb{\%chin\%} from \code{{data.table}}
is matched as well.
}
\details{
\code{scalar \%in\% vector} is OK, because the alternative (\code{any(vector == scalar)})
is more circuitous & potentially less clear.
}
\seealso{
\link{linters} for a complete list of linters available in lintr.
}
\section{Tags}{
\link[=best_practices_linters]{best_practices}, \link[=consistency_linters]{consistency}, \link[=efficiency_linters]{efficiency}, \link[=readability_linters]{readability}
}
