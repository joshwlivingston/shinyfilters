# Builds the dev site into docs/dev, linking source code to SOURCE_REF.
#
# build_site_github_pages() resolves source links before it applies
# `override`, so each site's ref is set when its pkgdown object is created.
# pkgdown renders every top-level .md file, so AGENTS.md is removed first.

unlink("AGENTS.md")
pkg <- pkgdown::as_pkgdown(
	".",
	override = list(repo = list(branch = Sys.getenv("SOURCE_REF")))
)
pkgdown::build_site_github_pages(
	pkg,
	new_process = FALSE,
	install = FALSE
)
