# R/dataframe.R
#
# Functions for using filterINput() with data.frames

#' Run the backend server for filterInput
#'
#' @param x An object being filtered; typically a data.frame.
#' @param input A \pkg{shiny} `input` object, or a reactive that resolves to a
#'   list of named values.
#' @inheritParams apply_filters
#' @param ... Additional arguments passed to [updateFilterInput()].
#'
#' @return A list with a single element, `get_input_values`, which is a reactive
#'   function that returns the current filter input values as a named list.
#'
#' @examplesIf interactive()
#' library(bslib)
#' library(DT)
#' library(S7)
#' library(shiny)
#'
#' must_use_radio <- new_S3_class(
#' 	 class = "must_use_radio",
#' 	 constructor = function(.data) .data
#' )
#' method(filterInput, must_use_radio) <- function(x, ...) {
#' 	 call_filter_input(x, shiny::radioButtons, ...)
#' }
#' method(updateFilterInput, must_use_radio) <- function(x, ...) {
#' 	 call_update_filter_input(x, shiny::updateRadioButtons, ...)
#' }
#'
#' use_radio <- function(x) {
#' 	 structure(x, class = unique(c("must_use_radio", class(x))))
#' }
#'
#' df_shared <- data.frame(
#' 	 x = letters,
#' 	 y = use_radio(sample(c("red", "green", "blue"), 26, replace = TRUE)),
#' 	 z = round(runif(26, 0, 3.5), 2),
#' 	 q = sample(Sys.Date() - 0:7, 26, replace = TRUE)
#' )
#'
#' filters_ui <- function(id) {
#' 	 ns <- shiny::NS(id)
#' 	 filterInput(
#' 		 x = df_shared,
#' 		 range = TRUE,
#' 		 selectize = TRUE,
#' 		 slider = TRUE,
#' 		 multiple = TRUE,
#' 		 ns = ns
#' 	 )
#' }
#'
#' filters_server <- function(id) {
#' 	 moduleServer(id, function(input, output, session) {
#'  		# serverFilterInput() returns a shiny::observe() expressionc
#'  		serverFilterInput(df_shared, input = input, range = TRUE)
#'  	})
#' }
#'
#' ui <- page_sidebar(
#'  	sidebar = sidebar(filters_ui("demo")),
#'  	DTOutput("df_full"),
#'  	verbatimTextOutput("input_values"),
#'  	DTOutput("df_filt")
#' )
#'
#' server <- function(input, output, session) {
#' 	 res <- filters_server("demo")
#' 	 output$df_full <- renderDT(datatable(df_shared))
#' 	 output$input_values <- renderPrint(res$get_input_values())
#' 	 output$df_filt <- renderDT(datatable(apply_filters(
#'  		df_shared,
#'  		res$get_input_values()
#'  	)))
#' }
#'
#' shinyApp(ui, server)
#' @export
serverFilterInput <- function(x, filter_combine_method, input, ...) {
	out_input <- shiny::reactiveVal(NULL)
	shiny::observe({
		input <- ._prepare_input(input, x = x)
		input_dfs <- apply_filters(
			x,
			input,
			filter_combine_method = filter_combine_method,
			expanded = TRUE
		)
		update_df_input <- function(df) {
			updateFilterInput(x = df, input = input, ...)
		}
		lapply(input_dfs, update_df_input)
		out_input(input)
	})
	return(list(get_input_values = out_input))
}

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
#'   each containg one column, its own, filtered according to the values of
#'   all *other* filters.
#' @param cols Optional character vector of column names to retain in the
#'   output when `x` is a data.frame. If `NULL` (the default), all columns are
#'   retained.
#' @param ... Additional arguments passed to [get_filter_logical()].
#'
#' @return A filtered object, or a named list of filtered objects if
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
#' filtered_df_and <- apply_filters(df, filters, filter_combine_method = "and")
#' print(filtered_df_and)
#'
#' # Apply filters with logical OR
#' filtered_df_or <- apply_filters(df, filters, filter_combine_method = "or")
#' print(filtered_df_or)
#'
#' # Get expanded filters
#' expanded_filters <- apply_filters(df, filters, expanded = TRUE)
#' print(expanded_filters)
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
			lapply(stats::setNames(nm = names(filter_list)), function(nm) {
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

	if (is.character(filter_combine_method)) {
		filter_combine_method <- switch(
			filter_combine_method,
			"&" = `&`,
			"and" = `&`,
			"|" = `|`,
			"or" = `|`,
			stop(sprintf(
				"Unknown `filter_combine_method` value: %s",
				filter_combine_method
			))
		)
	}

	filter_logical <-
		Reduce(
			filter_combine_method,
			lapply(names(filter_list), function(column_name) {
				get_filter_logical(
					x,
					filter_list[[column_name]],
					column_name,
					...
				)
			})
		)

	class_orig_x <- class(x)
	x_bare <- unclass(x)

	if (is.list(x_bare)) {
		x_filt <- lapply(x_bare, function(obj) obj[filter_logical])
	}

	if (is.data.frame(x)) {
		if (!is.null(cols)) {
			return(x[filter_logical, cols, drop = FALSE])
		}
		return(x[filter_logical, , drop = FALSE])
	}

	attrs_orig <- attributes(x)
	x_filt <- x[filter_logical]
	attributes(x_filt) <- attrs_orig

	return(x_filt)
}

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
#' When `x` is a `data.frame`:
#' \tabular{ll}{
#'   `nm` \tab The name of the column in `x` to filter on. \cr
#' }
#'
#' When `x` is a `data.frame` and `val` is numeric or Date:
#' \tabular{ll}{
#'   `.f` \tab When `val` is length-one, `.f` is the function used to compare
#'     `x` with `val`. The default is `<=`. \cr
#'   `gte` \tab When `val` is length-two and `gte` is `TRUE`
#'     (the default), the *lower* bound, determined by `val`, is inclusive. \cr
#'   `lte` \tab When `val` is length-two and `lte` is `TRUE`
#'     (the default), the *upper* bound, determined by `val`, is inclusive. \cr
#' }
#'
#' @export
get_filter_logical <- new_generic(
	name = "get_filter_logical",
	dispatch_args = c("x", "val"),
	fun = function(x, val, ...) {
		if (length(val) == 0L) {
			return(all_trues(x))
		}
		S7_dispatch()
	}
)

method(
	get_filter_logical,
	list(
		x = class_data.frame,
		val = class_character | class_factor
	)
) <- function(x, val, nm) {
	check_is_nonempty_string(nm)

	na_bool <- NULL
	if (any(is.na(val))) {
		na_bool <- is.na(x[[nm]])
		val <- val[!is.na(val)]
		if (length(val) == 0L) {
			return(na_bool)
		}
	}

	if (length(val) == 1L) {
		._filter <- `==`
	} else {
		._filter <- `%in%`
	}

	logical_out <- ._filter(x[[nm]], val)
	if (!is.null(na_bool)) {
		logical_out <- na_bool | logical_out
	}
	return(logical_out)
}

method(
	get_filter_logical,
	list(
		x = class_data.frame,
		val = class_numeric | class_Date
	)
) <- function(x, val, nm, .f = `<=`, gte = TRUE, lte = TRUE, ...) {
	check_is_nonempty_string(nm)

	na_bool <- NULL
	if (any(is.na(val))) {
		na_bool <- is.na(x[[nm]])
		val <- val[!is.na(val)]
		if (length(val) == 0L) {
			return(na_bool)
		}
	}

	if (length(val) == 1L) {
		logical_out <- .f(x[[nm]], val, ...)
	} else if (length(val) != 2L) {
		logical_out <- x[[nm]] %in% val
	} else {
		lt <- if (isTRUE(lte)) `<=` else `<`
		gt <- if (isTRUE(lte)) `>=` else `>`
		logical_out <- gt(x[[nm]], val[[1]]) & lt(x[[nm]], val[[2]])
	}

	if (!is.null(na_bool)) {
		logical_out <- na_bool | logical_out
	}
	return(logical_out)
}

method(get_filter_logical, list(class_data.frame, class_POSIXt)) <- function(
	x,
	val,
	nm,
	...
) {
	get_filter_logical(x, val = as.Date(val), nm, ...)
}

method(
	get_filter_logical,
	list(
		x = class_data.frame,
		val = class_logical
	)
) <- function(x, val, nm) {
	check_is_nonempty_string(nm)

	na_bool <- NULL
	if (any(is.na(val))) {
		na_bool <- is.na(x[[nm]])
		val <- val[!is.na(val)]
		if (length(val) == 0L) {
			return(na_bool)
		}
	}

	val <- unique(val)
	if (length(val) > 1L) {
		return(all_trues(x))
	}

	logical_out <- x[[nm]]
	if (!is.null(na_bool)) {
		logical_out <- na_bool | logical_out
	}
	return(logical_out)
}

get_input_values <- new_generic(
	name = "get_input_values",
	dispatch_args = c("input", "x")
)

method(
	get_input_values,
	list(class_reactivevalues, class_data.frame)
) <- function(input, x) {
	get_input_values(input, names(x))
}

method(
	get_input_values,
	list(class_reactivevalues, class_character)
) <- function(input, x) {
	lapply(stats::setNames(nm = x), function(nm) input[[nm]])
}

all_trues <- function(x) {
	all_something(x, TRUE)
}

all_falses <- function(x) {
	all_something(x, FALSE)
}

all_something <- function(x, something) {
	len <- dim(x)[[1]]
	if (is.null(len)) {
		len <- length(x)
	}
	rep(something, len)
}

._prepare_input <- new_generic("._prepare_input", "input")

method(._prepare_input, class_reactiveExpr) <- function(input, ...) {
	._prepare_input_list(input())
}

method(._prepare_input, class_reactivevalues) <- function(input, x) {
	._prepare_input_list(get_input_values(input, x))
}

._prepare_input_list <- new_generic("._prepare_input_list", "input")

method(._prepare_input_list, class_list) <- function(input) {
	return(input)
}

check_is_nonempty_string <- function(x) {
	if (
		length(x) != 1L || is.null(x) || is.na(x) || !is.character(x) || x == ""
	) {
		stop(sprintf("`%s` must be a non-empty string", deparse(substitute(x))))
	}
}
