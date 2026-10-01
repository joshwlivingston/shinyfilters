.onLoad <- function(libname, pkgname) {
	methods_register()

	cls <- "shinyfilters::shinyfilters"
	._s3_register("base::$", cls, `$.shinyfilters::shinyfilters`)
	._s3_register("base::[[", cls, `[[.shinyfilters::shinyfilters`)
	._s3_register("base::[", cls, `[.shinyfilters::shinyfilters`)
	._s3_register("base::names", cls, `names.shinyfilters::shinyfilters`)
	._s3_register("base::print", cls, `print.shinyfilters::shinyfilters`)
	._s3_register(
		"base::as.character",
		cls,
		`as.character.shinyfilters::shinyfilters`
	)
	._s3_register(
		"base::as.data.frame",
		cls,
		`as.data.frame.shinyfilters::shinyfilters`
	)
	._s3_register(
		"utils::.DollarNames",
		cls,
		`.DollarNames.shinyfilters::shinyfilters`
	)
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
