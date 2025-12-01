# R/dataframe.R
#
# Functions for using filterINput() with data.frames

#' Return A data.frame's filterInput() Values
#'
#' Returns a list of the input values corresponding to the data.frame passed to
#' [filterInput()].
#'
#' @param input An `input` object from a \pkg{shiny} server.
#' @param x Either a `data.frame` or a character vector. If `x` is a
#'   `data.frame`, `get_input_values()` is called on the column names of `x`.
#'
#' @return A `reactivevalues` list of input values.
#'
#' @examplesIf interactive()
#' df_shared <- data.frame(
#'   x = letters,
#'   y = sample(c("red", "green", "blue"), 26, replace = TRUE)
#' )
#'
#' ui <- bslib::page_sidebar(
#' 	 sidebar = bslib::sidebar(
#' 	   filterInput(df_shared, selectize = TRUE, slider = TRUE, multiple = TRUE)
#' 	 ),
#'   DT::DTOutput("df_full"),
#'   shiny::verbatimTextOutput("inputs"),
#'   DT::DTOutput("df_filt")
#' )
#' server <- function(input, output, session) {
#'   output$df_full <- DT::renderDT(DT::datatable(df_shared))
#'
#'   input_values <-
#'     shiny::reactive(get_input_values(input, df_shared)) |>
#'     shiny::throttle(2000)
#'   output$inputs <- shiny::renderPrint(input_values())
#'
#'   df_filt <- shiny::reactiveVal(df_shared)
#'   output$df_filt <- DT::renderDT(DT::datatable(df_filt()))
#'
#'   shiny::observe({
#'     df_now <- df_shared
#'     mapply(function(input_value, nm) {
#'       df_now <<- apply_filter(df_now, input_value, nm)
#'     }, input_values(), names(input_values()))
#'     df_filt(df_now)
#'   })
#'
#'   shiny::observe({
#'     updateFilterInput(df_filt())
#'   })
#' }
#' shiny::shinyApp(ui, server)
#'
#' @export
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
	lapply(setNames(nm = x), function(nm) input[[nm]])
}

apply_filters <- new_generic(
	name = "apply_filters",
	dispatch_args = c("df", "vals")
)

method(apply_filters, list(class_data.frame, NULL)) <- function(df, vals) {
	return(df)
}

method(
	apply_filters,
	list(class_data.frame, class_list)
) <- function(df, vals, expanded = FALSE) {
	if (isTRUE(expanded)) {
		return(setNames(
			lapply(names(vals), function(nm) {
				apply_filters(df, vals[names(vals) != nm])[nm]
			}),
			names(vals)
		))
	}
	df_filt <- df
	for (i in seq_along(vals)) {
		filter_value <- vals[[i]]
		column_name <- names(vals)[[i]]
		df_filt <- apply_filter(df_filt, filter_value, column_name)
	}
	return(df_filt)
}

apply_filter <- new_generic(
	name = "apply_filter",
	dispatch_args = c("x", "val"),
	fun = function(x, val, ...) {
		if (
			is.null(val) || length(val) == 0L || (length(val) == 1L && is.na(val))
		) {
			return(x)
		}
		S7_dispatch()
	}
)

method(
	apply_filter,
	list(
		x = class_data.frame,
		val = class_character | class_factor
	)
) <- function(x, val, nm) {
	check_is_nonempty_string(nm)
	if (length(val) == 1L) {
		._filter <- `==`
	} else {
		._filter <- `%in%`
	}
	x[._filter(x[[nm]], val), ]
}

method(
	apply_filter,
	list(
		x = class_data.frame,
		val = class_numeric | class_Date
	)
) <- function(x, val, nm, .f = `<=`, gte = TRUE, lte = TRUE, ...) {
	check_is_nonempty_string(nm)
	if (length(val) == 1L) {
		return(x[.f(x[[nm]], val, ...), ])
	}
	if (length(val) != 2L) {
		return(x[x[[nm]] %in% val, ])
	}
	lt <- if (isTRUE(lte)) `<=` else `<`
	gt <- if (isTRUE(lte)) `>=` else `>`
	x[gt(x[[nm]], val[[1]]) & lt(x[[nm]], val[[2]]), ]
}

method(apply_filter, list(class_any, class_POSIXt)) <- function(x, val, ...) {
	apply_filter(x, val = as.Date(val), ...)
}

method(
	apply_filter,
	list(
		x = class_data.frame,
		val = class_logical
	)
) <- function(x, val, nm) {
	check_is_nonempty_string(nm)
	val <- unique(val)
	if (length(val) > 1L) {
		return(x)
	}
	x[x[[nm]], ]
}

#' Run the backend server for filterInput
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
#' df_shared <- tibble::tibble(
#' 	 x = letters,
#' 	 y = sample(c("red", "green", "blue"), 26, replace = TRUE) |> use_radio(),
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
serverFilterInput <- new_generic(
	name = "serverFilterInput",
	dispatch_args = c("x")
)

method(serverFilterInput, class_data.frame) <- function(x, input, ...) {
	out_input <- shiny::reactiveVal(NULL)
	shiny::observe({
		input <- ._prepare_input(input, x = x)
		input_dfs <- apply_filters(x, input, expand = TRUE)
		update_df_input <- function(df) {
			updateFilterInput(x = df, input = input, ...)
		}
		lapply(input_dfs, update_df_input)
		out_input(input)
	})
	return(list(get_input_values = out_input))
}

._prepare_input <- new_generic("._prepare_input", "input")

method(._prepare_input, class_reactiveExpr) <- function(input, ...) {
	input()
}

method(._prepare_input, class_reactivevalues) <- function(input, x) {
	get_input_values(input, x)
}

method(._prepare_input, class_list) <- function(input, ...) {
	return(input)
}

check_is_nonempty_string <- function(x) {
	if (
		length(x) != 1L || is.null(x) || is.na(x) || !is.character(x) || x == ""
	) {
		stop(sprintf("`%s` must be a non-empty string", deparse(substitute(x))))
	}
}
