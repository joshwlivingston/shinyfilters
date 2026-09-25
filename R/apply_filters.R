#' Apply Filters to an object
#'
#' Applies a list of filters to an object, returning the filtered object.
#'
#' @param x An object to filter; typically a data.frame.
#' @param filter_list A named list of filter values, used to filter the values
#'   in `x`. If `filter_list` is `NULL`, `x` is returned unmodified.
#' @param filter_combine_method A string or function indicating how to combine
#'   multiple filters. If a string, it can be "and" (or "&") for logical AND,
#'   or "or" (or "|") for logical OR. If a function, it should take two logical
#'   vectors and return a combined logical vector.
#' @param expanded Logical; if `TRUE`, returns a named list of data.frames,
#'   each containing one column, its own, filtered according to the values of
#'   all *other* filters.
#' @param cols Optional character vector of column names to retain in the
#'   output when `x` is a data.frame. If `NULL` (the default), all columns are
#'   retained.
#' @param ... Additional arguments passed to [get_filter_logical()].
#'
#' @returns A filtered object, or a named list of filtered objects if
#'   `expanded = TRUE`.
#'
#' @examples
#' library(S7)
#' df <- data.frame(
#'  category = rep(letters[1:3], each = 4),
#'  value = 1:12,
#'  date = as.Date('2024-01-01') + 0:11
#' )
#' filters <- list(
#'   category = c("a", "b"),
#'   value = c(3, 11)
#' )
#'
#' # Apply filters with logical AND
#' apply_filters(df, filters, filter_combine_method = "and")
#'
#' # Apply filters with logical OR
#' apply_filters(df, filters, filter_combine_method = "or")
#'
#' # Get expanded filters
#' apply_filters(df, filters, expanded = TRUE)
#'
#' @export
apply_filters <- function(
	x,
	filter_list,
	filter_combine_method = "and",
	expanded = FALSE,
	cols = NULL,
	...
) {
	if (isTRUE(expanded)) {
		return(
			lapply(set_names(nm = names(filter_list)), function(nm) {
				apply_filters(
					x = x,
					filter_list = filter_list[names(filter_list) != nm],
					filter_combine_method = filter_combine_method,
					expanded = FALSE,
					cols = nm
				)
			})
		)
	}

	if (is.null(filter_list)) {
		return(x)
	}

	filter_logical <- ._prepare_filter_logical(
		x = x,
		filter_list = filter_list,
		filter_combine_method = filter_combine_method,
		...,
		call = current_env()
	)

	if (is.data.frame(x)) {
		if (!is.null(cols)) {
			return(x[filter_logical, cols, drop = FALSE])
		}
		return(x[filter_logical, , drop = FALSE])
	}
	return(x[filter_logical])
}

._prepare_filter_logical <- function(
	x,
	filter_list,
	filter_combine_method,
	...,
	call = caller_env()
) {
	if (is.character(filter_combine_method)) {
		filter_combine_method <-
			switch(
				filter_combine_method,
				"&" = `&`,
				"and" = `&`,
				"|" = `|`,
				"or" = `|`,
				cli_abort(
					c(
						"Unknown {.arg filter_combine_method} value {.val {filter_combine_method}}.",
						"i" = "Must be one of {.or {.val {c('&', 'and', '|', 'or')}}}, or a function."
					),
					call = call
				)
			)
	}
	if (!is.function(filter_combine_method)) {
		cli_abort(
			"{.arg filter_combine_method} must be a string or a function, not {.obj_type_friendly {filter_combine_method}}.",
			call = call
		)
	}
	x_length <- len(x)
	filt_out <-
		Reduce(
			filter_combine_method,
			lapply(
				names(filter_list),
				function(column_name) {
					res <-
						get_filter_logical(
							x,
							filter_list[[column_name]],
							column_name,
							...
						)
					._check_filter_logical(res, x_length, column_name, call = call)
					return(res)
				}
			)
		)
	._check_filter_logical(filt_out, x_length, call = call)
	return(filt_out)
}

._check_filter_logical <- function(
	filter_res,
	x_length,
	column_name = NULL,
	call = caller_env()
) {
	if (!is.null(column_name)) {
		filter_str <- format_inline("Filter on column {.val {column_name}}")
	} else {
		filter_str <- "Filter"
	}

	if (!inherits(filter_res, "logical")) {
		cli_abort(
			"{filter_str} must return a logical vector, not {.obj_type_friendly {filter_res}}.",
			call = call
		)
	}

	if (!identical(length(filter_res), x_length)) {
		cli_abort(
			c(
				"{filter_str} must return a logical vector of length {x_length}.",
				"x" = "It returned a vector of length {length(filter_res)}."
			),
			call = call
		)
	}
}
