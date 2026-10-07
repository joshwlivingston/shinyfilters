# R/shiny.R
#
# Functions for using filterInput() with shiny

#' Run the backend server for filterInput
#'
#' `shinyfilters_server()` runs an observer that makes your filters
#' interdependent. `serverFilterInput()` is an alias of
#' `shinyfilters_server()`.
#'
#' @param x An object being filtered; typically the result of [shinyfilters()].
#' @param session The \pkg{shiny} session whose inputs are read and updated.
#'   Defaults to the current session. The inputs of a configuration with a
#'   namespace (see [with_ns()]) are found from any session of the app, so
#'   `shinyfilters_server()` can be called at the top level of the server or
#'   inside the module. The namespace is the full one, as in the UI: inside a
#'   module's server that is `session$ns(NULL)`, which differs from the
#'   module's `id` when modules are nested.
#' @inheritParams apply_filters
#' @param args_apply_filters A named list of additional arguments passed to
#'   [apply_filters()].
#' @param ... Additional arguments passed to [updateFilterInput()].
#' @param input Deprecated: omit it, or use `session`. A \pkg{shiny} `input`
#'   object, or a reactive that resolves to a list of named values.
#'
#' @details
#' Only the inputs that have no value are updated, and they are left without
#' one. The inputs of a configuration made by [shinyfilters()] are updated as
#' [updateFilterInput()] updates them, from the filtered data.
#'
#' An input set by a function other than the \pkg{shiny} inputs
#' [filterInput()] creates needs the function that updates it. A
#' \pkg{shinyWidgets} input, such as `shinyWidgets::pickerInput`, comes with
#' its own. A column's update sends its choices, or its minimum and maximum,
#' and that function is given the ones it has an argument for. One with an
#' argument for none of them, such as
#' `shinyWidgets::updateNumericRangeInput`, leaves its input as it is, so the
#' input doesn't follow the other filters. Any other input, such as
#' `shiny::checkboxGroupInput`, needs its update function named with
#' `.update_fn := fn` among the input's arguments, as described in
#' [with_filters()]. Without it, `shinyfilters_server()` errors.
#'
#' @returns A reactiveValues list with two elements: `filtered`, the filtered
#'   data, and `input_values`, the current filter input values as a named
#'   list.
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
#' 	 call_filter_input(x, radioButtons, ...)
#' }
#' method(updateFilterInput, must_use_radio) <- function(x, ...) {
#' 	 call_update_filter_input(x, updateRadioButtons, ...)
#' }
#'
#' use_radio <- function(x) {
#' 	 structure(x, class = unique(c("must_use_radio", class(x))))
#' }
#'
#' df_shared <- data.frame(
#'   stringsAsFactors = FALSE,
#' 	 x = letters,
#' 	 y = use_radio(sample(c("red", "green", "blue"), 26, replace = TRUE)),
#' 	 z = round(runif(26, 0, 3.5), 2),
#' 	 q = sample(Sys.Date() - 0:7, 26, replace = TRUE)
#' )
#'
#' filters_ui <- function(id) {
#' 	 ns <- NS(id)
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
#'  		# serverFilterInput() returns a reactiveValues list
#'  		serverFilterInput(df_shared, range = TRUE)
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
	session = getDefaultReactiveDomain(),
	filter_combine_method = "and",
	args_apply_filters = NULL,
	...,
	input = deprecated()
) {
	error_call <- current_call()
	# `input` was the second argument before 0.4.0
	if (inherits(session, c("reactivevalues", "reactiveExpr"))) {
		input <- session
		session <- getDefaultReactiveDomain()
	}
	out_input <- reactiveValues()
	is_config <- S7_inherits(x, class_shinyfilters)
	input_session <- session
	if (is_config) {
		# Raised here, not in the observer, which only updates the inputs that
		# happen to be empty.
		._check_update_fns(x, names(x@data), error_call)
		input_session <- ._config_session(x, session)
	}
	# An input the server updates has no value, and keeps none: without
	# `selected`, `updateRadioButtons()` selects the first choice.
	args_update <- c(list(session = session), list(...))
	if (!("selected" %in% names(args_update))) {
		args_update$selected <- character(0)
	}
	observe({
		if (!is_missing(maybe_missing(input))) {
			# Adapted from lifecycle::deprecate_warn()
			cli_warn(
				c(
					"The {.arg input} argument of {.fn shinyfilters_server} is deprecated as of shinyfilters 0.4.0.",
					"i" = "Please omit, or provide the {.arg session} argument instead."
				),
				.frequency = "once",
				.frequency_id = "shinyfilters_server_input_arg"
			)
		} else {
			input <- input_session$input
		}
		input <- ._prepare_input(input, x = x, call = error_call)
		args_apply_filters <- c(
			list(
				x = x,
				filter_list = input,
				filter_combine_method = filter_combine_method,
				expanded = FALSE,
				cols = NULL
			),
			args_apply_filters
		)
		x_filt <- do.call(apply_filters, args_apply_filters)
		out_input$filtered <- x_filt
		update_input <- function(col, id) {
			val <- input[[id]]
			if (!is.null(val) || !identical(length(val), 0L)) {
				return(invisible())
			}
			args <- list(col, id)
			names(args) <- c("x", arg_name_input_id(col))
			do.call(updateFilterInput, c(args, args_update))
		}
		if (is_config) {
			is_empty <- vapply(input[get_input_ids(x_filt)], is.null, logical(1))
			._config_update_inputs(
				._config_filtered(x, x_filt),
				names(x_filt)[is_empty],
				args_update,
				error_call
			)
		} else {
			mapply(update_input, x_filt, get_input_ids(x_filt))
		}
		out_input$input_values <- input
	})
	return(out_input)
}

#' @rdname serverFilterInput
#' @export
shinyfilters_server <- serverFilterInput

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
#' @returns A named list of input values corresponding to the names in `x`.
#' @examplesIf interactive()
#' library(shiny)
#' df <- data.frame(
#' 	 stringsAsFactors = FALSE,
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
#'   output$output_all <- renderPrint({
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
	list(class_reactivevalues, class_shinyfilters)
) <- function(input, x) {
	get_input_values(input, x@data)
}

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
#' @returns A character vector of input ids.
#' @examples
#' df <- data.frame(
#'   stringsAsFactors = FALSE,
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
#' @returns A character vector of input labels
#' @examples
#' df <- data.frame(
#'   stringsAsFactors = FALSE,
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

method(._prepare_input, class_reactiveExpr) <- function(
	input,
	x,
	call = caller_env()
) {
	res <- ._prepare_input_list(input())
	names_res <- names(res)
	names_x <- names(x)
	input_not_in_res <- !(names_x %in% names_res)
	if (any(input_not_in_res)) {
		missing <- names_x[input_not_in_res]
		cli_abort(
			"Missing required input value{?s}: {.val {missing}}.",
			call = call
		)
	}
	input_not_in_x <- !(names_res %in% names_x)
	if (any(input_not_in_x)) {
		ignored <- names_res[input_not_in_x]
		cli_warn(
			"Ignoring unsupported input value{?s}: {.val {ignored}}.",
			call = call
		)
	}
	return(res[!input_not_in_x])
}

method(._prepare_input, class_reactivevalues) <- function(input, x, ...) {
	._prepare_input_list(get_input_values(input, x))
}

._prepare_input_list <- new_generic("._prepare_input_list", "input")

method(._prepare_input_list, class_list) <- function(input) {
	return(input)
}

#' @importFrom shiny dateInput
#' @export
shiny::dateInput

#' @importFrom shiny dateRangeInput
#' @export
shiny::dateRangeInput

#' @importFrom shiny numericInput
#' @export
shiny::numericInput

#' @importFrom shiny radioButtons
#' @export
shiny::radioButtons

#' @importFrom shiny selectInput
#' @export
shiny::selectInput

#' @importFrom shiny selectizeInput
#' @export
shiny::selectizeInput

#' @importFrom shiny sliderInput
#' @export
shiny::sliderInput

#' @importFrom shiny textAreaInput
#' @export
shiny::textAreaInput

#' @importFrom shiny textInput
#' @export
shiny::textInput

#' @importFrom shiny updateDateInput
#' @export
shiny::updateDateInput

#' @importFrom shiny updateDateRangeInput
#' @export
shiny::updateDateRangeInput

#' @importFrom shiny updateNumericInput
#' @export
shiny::updateNumericInput

#' @importFrom shiny updateRadioButtons
#' @export
shiny::updateRadioButtons

#' @importFrom shiny updateSelectInput
#' @export
shiny::updateSelectInput

#' @importFrom shiny updateSelectizeInput
#' @export
shiny::updateSelectizeInput

#' @importFrom shiny updateSliderInput
#' @export
shiny::updateSliderInput

#' @importFrom shiny updateTextAreaInput
#' @export
shiny::updateTextAreaInput

#' @importFrom shiny updateTextInput
#' @export
shiny::updateTextInput
