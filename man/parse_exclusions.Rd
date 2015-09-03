% Generated by roxygen2 (4.1.1): do not edit by hand
% Please edit documentation in R/exclude.R
\name{parse_exclusions}
\alias{parse_exclusions}
\title{read a source file and parse all the excluded lines from it}
\usage{
parse_exclusions(file, exclude = settings$exclude,
  exclude_start = settings$exclude_start,
  exclude_end = settings$exclude_end)
}
\arguments{
\item{file}{R source file}

\item{exclude}{regular expression used to mark lines to exclude}

\item{exclude_start}{regular expression used to mark the start of an excluded range}

\item{exclude_end}{regular expression used to mark the end of an excluded range}
}
\description{
read a source file and parse all the excluded lines from it
}
