in_ci <- function() {
  in_travis() || in_wercker() || in_jenkins()
}

ci_type <- function() {
  if (in_travis()) {
    return("travis")
  }
  if (in_wercker()) {
    return("wercker")
  }
  if (in_jenkins()) {
    return("jenkins")
  }
  ""
}

in_jenkins <- function() {
  nzchar(Sys.getenv("JENKINS_URL")) && !is.null(jenkins_build_info())
}

jenkins_build_info <- function() {
  git_url <- Sys.getenv("GIT_URL", Sys.getenv("GIT_URL_1", NA))
  if (is.na(git_url)) {
    return(NULL)
  }

  pattern <- "(https?:\\/\\/|git@)github\\.com[:\\/](.+\\/.+)\\.git"
  if (!length(grep(pattern, git_url))) {
    return(NULL)
  }
  slug <- gsub(pattern, "\\2", git_url)

  slug_info <- strsplit(slug, "/", fixed = TRUE)[[1L]]

  list(
    user = slug_info[1L],
    repo = slug_info[2L],
    pull = Sys.getenv("CHANGE_ID", NA) %||% NULL,
    commit = Sys.getenv("GIT_COMMIT", NA) %||% NULL
  )
}

in_travis <- function() {
  return(nzchar(Sys.getenv("TRAVIS_REPO_SLUG")))
}

travis_build_info <- function() {
  slug <- Sys.getenv("TRAVIS_REPO_SLUG")
  slug_info <- strsplit(slug, "/", fixed = TRUE)[[1L]]

  list(
    user = slug_info[1L] %||% "",
    repo = slug_info[2L] %||% "",
    pull = Sys.getenv("TRAVIS_PULL_REQUEST"),
    branch = Sys.getenv("TRAVIS_BRANCH"),
    commit = Sys.getenv("TRAVIS_COMMIT")
  )
}

in_wercker <- function() {
  return(nzchar(Sys.getenv("WERCKER_GIT_BRANCH")))
}

ci_build_info <- function() {
  type <- ci_type()
  switch(
    type,
    travis = travis_build_info(),
    wercker = wercker_build_info(),
    jenkins = jenkins_build_info()
  )
}

wercker_build_info <- function() {
  list(
    user = Sys.getenv("WERCKER_GIT_OWNER"),
    repo = Sys.getenv("WERCKER_GIT_REPOSITORY"),
    branch = Sys.getenv("WERCKER_GIT_BRANCH"),
    commit = Sys.getenv("WERCKER_GIT_COMMIT")
  )
}

# nocov start
github_comment <- function(text, info = NULL, token = settings$comment_token) {
  if (!requireNamespace("httr", quietly = TRUE)) {
    stop("Package 'httr' is required to post comments with github_comment().")
  }
  if (!requireNamespace("jsonlite", quietly = TRUE)) {
    stop("Package 'jsonlite' is required to post comments with github_comment().")
  }

  if (is.null(info)) {
    info <- ci_build_info()
  }

  if (!is.null(info$pull) && info$pull != "false") {
    api_subdir <- file.path("issues", info$pull)
  } else if (!is.null(info$commit)) {
    api_subdir <- file.path("commits", info$commit)
  } else {
    stop("Expected a pull or a commit, but received ci_build_info() = ", format(info))
  }
  response <- httr::POST(
    "https://api.github.com",
    path = file.path("repos", info$user, info$repo, api_subdir, "comments"),
    body = list(body = jsonlite::unbox(text)),
    query = list(access_token = token),
    encode = "json"
  )

  if (httr::status_code(response) >= 300L) {
    message(httr::http_condition(response, "error", task = httr::content(response, as = "text")))
  }
}
# nocov end
