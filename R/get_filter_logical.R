#' Compute a Filter Predicate
#'
#' Computes a logical vector indicating which elements of `x` match the filter
#' criteria specified by `val`.
#'
#' @param x An object to filter; typically a data.frame.
#' @param val The filter criteria.
#' @param ... Arguments passed to methods. See details.
#'
#' @details
#' The following arguments are supported in `...`:
#'
#' \describe{
#'   \item{column}{When `x` is a data.frame, `column` is the name of the
#'     column intended to be filtered.}
#'   \item{comparison}{When `x` is a numeric or Date and `val` is a
#'     length-**one** numeric or Date, `comparison` is the function used to
#'     compare `x` with `val`. The default is `<=`.}
#'   \item{gte}{When `x` is a numeric or Date and `val` is a length-**two**
#'      numeric or Date, `gte` controls whether to use `>=` (`TRUE`, default)
#'      or `>` (`FALSE`) on `val[[1]]`.}
#'   \item{lte}{When `x` is a numeric or Date and `val` is a length-**two**
#'      numeric or Date, `lte` controls whether to use `<=` (`TRUE`, default)
#'      or `<` (`FALSE`) on `val[[2]]`.}
#' }
#'
#' @returns A logical vector indicating which elements of `x` match the filter
#'   criteria specified by `val`.
#'
#' @examples
#' df <- data.frame(
#'   category = rep(letters[1:3], each = 4),
#'   value = 1:12,
#'   date = Sys.Date() + 0:11
#' )
#'
#' # Filter character column
#' get_filter_logical(df, c("a", "b"), column = "category")
#'
#' # Filter numeric column with single value
#' get_filter_logical(df, 5, column = "value", comparison = `<=`)
#'
#' # Filter numeric column with range
#' get_filter_logical(df, c(3, 8), column = "value", gte = TRUE, lte = FALSE)
#'
#' @export
get_filter_logical <- new_generic(
	name = "get_filter_logical",
	dispatch_args = c("x", "val"),
	fun = function(x, val, ...) {
		if (identical(length(val), 0L)) {
			return(all_trues(x))
		}
		S7_dispatch()
	}
)

method(get_filter_logical, list(x = NULL, val = class_any)) <- function(
	x,
	val,
	...
) {
	return(NULL)
}

method(get_filter_logical, list(x = class_any, val = class_any)) <- function(
	x,
	val,
	...
) {
	warning("Fallback method called for mismatched types. Returning TRUE")
	return(rep(TRUE, length(x)))
}

method(
	get_filter_logical,
	list(x = class_data.frame, val = class_any)
) <- function(
	x,
	val,
	column,
	...
) {
	check_is_nonempty_string(column)
	col <- x[[column]]
	if (is.null(col)) {
		stop(sprintf("Column `%s` not found in `x`.", column))
	}
	get_filter_logical(col, val, ...)
}

method(
	get_filter_logical,
	list(
		x = class_character | class_factor | class_logical,
		val = class_character | class_factor | class_logical
	)
) <- function(x, val, ...) {
	na_bool <- NULL
	if (anyNA(val)) {
		na_bool <- is.na(x)
		val <- val[!is.na(val)]
		if (identical(length(val), 0L)) {
			return(na_bool)
		}
	}

	if (identical(length(val), 1L)) {
		._filter <- `==`
	} else {
		._filter <- `%in%`
	}

	logical_out <- ._filter(x, val)
	if (!is.null(na_bool)) {
		logical_out <- na_bool | logical_out
	}
	return(logical_out)
}

method(
	get_filter_logical,
	list(
		x = class_numeric | class_Date,
		val = class_numeric | class_Date
	)
) <- function(x, val, comparison = `<=`, gte = TRUE, lte = TRUE, ...) {
	na_bool <- NULL
	if (anyNA(val)) {
		na_bool <- is.na(x)
		val <- val[!is.na(val)]
		if (identical(length(val), 0L)) {
			return(na_bool)
		}
	}

	if (identical(length(val), 1L)) {
		logical_out <- comparison(x, val, ...)
	} else if (!identical(length(val), 2L)) {
		logical_out <- x %in% val
	} else {
		lt <- if (isTRUE(lte)) `<=` else `<`
		gt <- if (isTRUE(gte)) `>=` else `>`
		logical_out <- gt(x, val[[1]]) & lt(x, val[[2]])
	}

	if (!is.null(na_bool)) {
		logical_out <- na_bool | logical_out
	}
	return(logical_out)
}

method(get_filter_logical, list(class_POSIXt, class_POSIXt)) <- function(
	x,
	val,
	...
) {
	get_filter_logical(x = as.Date(x), val = as.Date(val), ...)
}
