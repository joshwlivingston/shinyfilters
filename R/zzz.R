.onLoad <- function(libname, pkgname) {
	methods_register()

	cls <- "shinyfilters::shinyfilters"
	._s3_register("dplyr::mutate", cls, `mutate.shinyfilters::shinyfilters`)
	._s3_register("dplyr::select", cls, `select.shinyfilters::shinyfilters`)
	._s3_register("dplyr::pull", cls, `pull.shinyfilters::shinyfilters`)
	._s3_register(
		"tibble::as_tibble",
		cls,
		`as_tibble.shinyfilters::shinyfilters`
	)
	._s3_register(
		"data.table::as.data.table",
		cls,
		`as.data.table.shinyfilters::shinyfilters`
	)
}
