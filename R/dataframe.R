# R/dataframe.R
#
# Functions for using filterINput() with data.frames

#' Run the backend server for filterInput
#'
#' @param x An object being filtered; typically a data.frame.
#' @param input A \pkg{shiny} `input` object, or a reactive that resolves to a
#'   list of named values.
#' @inheritParams apply_filters
#' @param args_apply_filters A named list of additional arguments passed to
#'   [apply_filters()].
#' @param ... Additional arguments passed to [updateFilterInput()].
#'
#' @return A reactiveValues list with a single element, `input_values`, which
#'   contains the current filter input values as a named list.
#'
#' @examplesIf interactive() && requireNamespace("bslib") && requireNamespace("DT")
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
#' 	 output$input_values <- renderPrint(res$input_values)
#' 	 output$df_filt <- renderDT(datatable(apply_filters(
#'  		df_shared,
#'  		res$input_values
#'  	)))
#' }
#'
#' shinyApp(ui, server)
#' @export
serverFilterInput <- function(
	x,
	input,
	filter_combine_method = "and",
	args_apply_filters = NULL,
	...
) {
	out_input <- shiny::reactiveValues()
	shiny::observe({
		input <- ._prepare_input(input, x = x)
		args_apply_filters <- c(
			list(
				x = x,
				filter_list = input,
				filter_combine_method = filter_combine_method,
				expanded = TRUE,
				cols = NULL
			),
			args_apply_filters
		)
		x_filt_list <- do.call(apply_filters, args_apply_filters)
		update_input <- function(x_filt) {
			updateFilterInput(x = x_filt, input = input, ...)
		}
		lapply(x_filt_list, update_input)
		out_input$input_values <- input
	})
	return(out_input)
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
#'   each containing one column, its own, filtered according to the values of
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

	if (is.character(filter_combine_method)) {
		filter_combine_method <-
			switch(
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

	filter_logical <- ._prepare_filter_logical(
		x = x,
		filter_list = filter_list,
		filter_combine_method = filter_combine_method,
		...
	)

	if (is.data.frame(x)) {
		if (!is.null(cols)) {
			return(x[filter_logical, cols, drop = FALSE])
		}
		return(x[filter_logical, , drop = FALSE])
	}
	return(x[filter_logical])
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
#' \tabular{ll}{
#'   `column` \tab When `x` is a data.frame, `column` is the name of the
#'     column intended to be filtered. \cr
#'   `comparison` \tab When `x` is a numeric or Date and `val` is a
#'     length-**one** numeric or Date, `comparison` is the function used to
#'     compare `x` with `val`. The default is `<=`. \cr
#'   `gte` \tab When `x` is a numeric or Date and `val` is a length-**two**
#'      numeric or Date, `gte` controls whether to use `>=` (`TRUE`, default)
#'      or `>` (`FALSE`) on `val[[1]]`. \cr
#'   `lte` \tab When `x` is a numeric or Date and `val` is a length-**two**
#'      numeric or Date, `lte` controls whether to use `<=` (`TRUE`, default)
#'      or `<` (`FALSE`) on `val[[2]]` \cr
#' }
#'
#' @return A logical vector indicating which elements of `x` match the filter
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
) <- function(x, val) {
	na_bool <- NULL
	if (any(is.na(val))) {
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
	if (any(is.na(val))) {
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

._prepare_filter_logical <- function(
	x,
	filter_list,
	filter_combine_method,
	...
) {
	if (!is.function(filter_combine_method)) {
		stop("Argument `filter_combine_method` must be a function.")
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
					._check_filter_logical(res, x_length, column_name)
					return(res)
				}
			)
		)
	._check_filter_logical(filt_out, x_length)
	return(filt_out)
}

._check_filter_logical <- function(filter_res, x_length, column_name = NULL) {
	if (!is.null(column_name)) {
		column_str <- sprintf("on column `%s` ", column_name)
	} else {
		column_str <- ""
	}

	if (!identical(class(filter_res), "logical")) {
		stop(sprintf("Filter %sdid not return a logical vector.", column_str))
	}

	if (!identical(length(filter_res), x_length)) {
		stop(
			sprintf(
				"Filter %sreturned a logical vector of length %d, but expected length %d.",
				column_str,
				length(filter_res),
				x_length
			)
		)
	}
}

all_trues <- function(x) {
	all_something(x, TRUE)
}

all_falses <- function(x) {
	all_something(x, FALSE)
}

all_something <- function(x, something) {
	rep(something, len(x))
}

len <- function(x) {
	len <- dim(x)[[1]]
	if (is.null(len)) {
		len <- length(x)
	}
	return(len)
}

#' Get Multiple Values from a \pkg{shiny} Input Object
#'
#' Retrieves multiple input values from a \pkg{shiny} `input` object based on
#' the names provided in `x`.
#' @param input A \pkg{shiny} `input` object, i.e., the `input` argument to the
#'   shiny server.
#' @param x A character vector of input names, or a data.frame whose column
#'   names are converted to input names via [get_input_ids()].
#' @param ... Passed onto methods.
#'
#' @return A named list of input values corresponding to the names in `x`.
#' @examplesIf interactive()
#' library(shiny)
#' df <- data.frame(
#'   name = c("Alice", "Bob"),
#'   age = c(25, 30),
#'   completed = c(TRUE, FALSE)
#' )
#' ui <- fluidPage(
#'   sidebarLayout(
#'     sidebarPanel(
#'       filterInput(df)
#'     ),
#'     mainPanel(
#'       verbatimTextOutput("output_all"),
#'       verbatimTextOutput("output_subset")
#'     )
#'   )
#' )
#' server <- function(input, output, session) {
#'   output$output <- renderPrint({
#'     get_input_values(input, df)
#'   })
#'   output$output_subset <- renderPrint({
#'     get_input_values(input, c("name", "completed"))
#'   })
#' }
#' shinyApp(ui, server)
#' @export
get_input_values <- new_generic(
	name = "get_input_values",
	dispatch_args = c("input", "x")
)

method(
	get_input_values,
	list(class_reactivevalues, class_data.frame)
) <- function(input, x) {
	get_input_values(input, get_input_ids(x))
}

method(
	get_input_values,
	list(class_reactivevalues, class_character)
) <- function(input, x) {
	lapply(set_names(nm = x), function(nm) input[[nm]])
}

#' Retrieve the Ids of Input Objects
#'
#' Returns the (unnamespaced) ids of the inputs for the provided object.
#'
#' @param x An object for which to retrieve input ids; typically a data.frame.
#' @param ... Passed onto methods.
#'
#' @return A character vector of input ids.
#' @examples
#' df <- data.frame(
#'   name = c("Alice", "Bob"),
#'   age = c(25, 30),
#'   completed = c(TRUE, FALSE)
#' )
#'
#' get_input_ids(df)
#' @export
get_input_ids <- new_generic("get_input_ids", "x")

method(get_input_ids, class_data.frame) <- function(x) {
	return(names(x))
}

#' Retrieve the Labels of Input Objects
#'
#' Returns the labels of the \pkg{shiny} inputs for the provided object.
#'
#' @param x An object for which to retrieve input labels; typically a data.frame.
#' @param ... Passed onto methods.
#'
#' @return A character vector of input labels
#' @examples
#' df <- data.frame(
#'   name = c("Alice", "Bob"),
#'   age = c(25, 30),
#'   completed = c(TRUE, FALSE)
#' )
#'
#' get_input_labels(df)
#' @export
get_input_labels <- new_generic("get_input_labels", "x")

method(get_input_labels, class_data.frame) <- function(x) {
	return(names(x))
}

._prepare_input <- new_generic("._prepare_input", "input")

method(._prepare_input, class_reactiveExpr) <- function(input, x) {
	res <- ._prepare_input_list(input())
	names_res <- names(res)
	names_x <- names(x)
	input_not_in_res <- !(names_x %in% names_res)
	if (any(input_not_in_res)) {
		stop(
			sprintf(
				"Missing required input values: `%s`",
				paste0(
					names_x[input_not_in_res],
					collapse = "`, `"
				)
			)
		)
	}
	input_not_in_x <- !(names_res %in% names_x)
	if (any(input_not_in_x)) {
		warning(
			sprintf(
				"Ignoring unsupported input values: `%s`",
				paste0(
					names_res[input_not_in_x],
					collapse = "`, `"
				)
			)
		)
	}
	return(res[!input_not_in_x])
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
		!identical(length(x), 1L) ||
			is.null(x) ||
			is.na(x) ||
			!is.character(x) ||
			identical(x, "")
	) {
		stop(sprintf("`%s` must be a non-empty string", deparse(substitute(x))))
	}
}
