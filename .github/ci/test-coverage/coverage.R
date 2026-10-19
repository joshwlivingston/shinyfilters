# Measures test coverage and writes it to cobertura.xml for Codecov. The
# installed package is kept in $RUNNER_TEMP/package for the testthat output.

cov <- covr::package_coverage(
	quiet = FALSE,
	clean = FALSE,
	install_path = file.path(
		normalizePath(Sys.getenv("RUNNER_TEMP"), winslash = "/"),
		"package"
	)
)
print(cov)
covr::to_cobertura(cov)
