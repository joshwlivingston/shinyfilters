# Fails if DEV_IMPORTS, the development versions installed on R-devel,
# doesn't name exactly the non-base Imports in DESCRIPTION.

split <- function(x) trimws(strsplit(x, ",")[[1]])

imports <- split(read.dcf("DESCRIPTION", "Imports"))
imports <- sub("[ (].*", "", imports)
imports <- setdiff(imports, rownames(installed.packages(priority = "base")))
dev <- sub(".*/", "", split(Sys.getenv("DEV_IMPORTS")))

if (!setequal(imports, dev)) {
	stop(
		"dev-imports doesn't match Imports: ",
		paste(
			sort(union(setdiff(imports, dev), setdiff(dev, imports))),
			collapse = ", "
		)
	)
}
