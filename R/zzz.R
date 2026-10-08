# nocov start
.onLoad <- function(libname, pkgname) {
	methods_register()

	cls <- "shinyfilters::shinyfilters"
	._s3_register("base::$", cls, `$.shinyfilters::shinyfilters`)
	._s3_register("base::[[", cls, `[[.shinyfilters::shinyfilters`)
	._s3_register("base::[", cls, `[.shinyfilters::shinyfilters`)
	._s3_register("base::names", cls, `names.shinyfilters::shinyfilters`)
	._s3_register("base::dim", cls, `dim.shinyfilters::shinyfilters`)
	._s3_register("base::print", cls, `print.shinyfilters::shinyfilters`)
	._s3_register(
		"htmltools::as.tags",
		cls,
		`as.tags.shinyfilters::shinyfilters`
	)
	._s3_register("utils::str", cls, `str.shinyfilters::shinyfilters`)
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
# nocov end

the <- new.env(parent = emptyenv())

# While `the$dry_run` is TRUE, the input callers return the input function
# instead of calling it, so print() can show which input each column uses.
the$dry_run <- FALSE
