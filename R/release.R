# Extra items for the checklist from usethis::use_release_issue()
release_bullets <- function() {
	c(
		"Run the R-CMD-check-R35.yaml workflow; if it changes `_snaps/r-3.5/`, review and commit the snapshots with `testthat::snapshot_download_gh()`"
	)
}
