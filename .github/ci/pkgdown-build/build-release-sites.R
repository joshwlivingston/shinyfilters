# Builds each release in TAGS into releases/<version>, served at SITE_URL for
# LATEST and at SITE_URL/<version> otherwise, with this ref's templates.

url <- Sys.getenv("SITE_URL")
latest <- Sys.getenv("LATEST")
templates <- file.path(getwd(), "pkgdown", "templates")
tags <- strsplit(trimws(Sys.getenv("TAGS")), " ")[[1]]

for (tag in tags) {
  version <- sub("^v", "", tag)
  dest <- file.path(getwd(), "releases", version)
  site_url <- if (tag == latest) url else paste0(url, "/", version)
  # Reuse a cached site only if it was built for the URL it's served at.
  built <- file.path(dest, "pkgdown.yml")
  if (file.exists(built)) {
    built_url <- yaml::read_yaml(built)$urls$reference
    if (identical(built_url, paste0(site_url, "/reference"))) next
  }
  src <- file.path(tempdir(), tag)
  system2("git", c("worktree", "add", src, tag))
  unlink(file.path(src, "AGENTS.md"))
  pak::local_install_deps(src, upgrade = FALSE, dependencies = TRUE)
  pkg <- pkgdown::as_pkgdown(
    src,
    override = list(
      destination = dest,
      url = site_url,
      repo = list(branch = tag),
      template = list(path = templates)
    )
  )
  pkgdown::build_site_github_pages(
    pkg,
    dest_dir = dest,
    install = TRUE,
    new_process = TRUE
  )
}
