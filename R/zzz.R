.onLoad <- function(libname, pkgname) {
	methods_register()

	cls <- "shinyfilters::shinyfilters"
	._s3_register("base::$", cls, `$.shinyfilters::shinyfilters`)
	._s3_register("base::[[", cls, `[[.shinyfilters::shinyfilters`)
	._s3_register("base::[", cls, `[.shinyfilters::shinyfilters`)
	._s3_register("base::names", cls, `names.shinyfilters::shinyfilters`)
	._s3_register("base::print", cls, `print.shinyfilters::shinyfilters`)
	._s3_register(
		"base::print",
		"shinyfilters_filter",
		print.shinyfilters_filter
	)
	._s3_register(
		"htmltools::as.tags",
		cls,
		`as.tags.shinyfilters::shinyfilters`
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
	._s3_register("dplyr::transmute", cls, `transmute.shinyfilters::shinyfilters`)
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

the <- new.env(parent = emptyenv())

the$allowed <- FALSE

# While `the$dry_run` is TRUE, the input callers return the input function
# instead of calling it, so print() can show which input each column uses.
the$dry_run <- FALSE
