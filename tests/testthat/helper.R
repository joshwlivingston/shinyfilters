# Snapshot variant for CI jobs whose snapshot output differs, such as old
# testthat on old R. Set only in CI; everywhere else snapshots use the default.
snapshot_variant <- function() {
	variant <- Sys.getenv("SHINYFILTERS_SNAPSHOT_VARIANT")
	if (identical(variant, "")) {
		return(NULL)
	}
	variant
}
