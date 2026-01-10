# R/shiny.R
#
# Functions for using filterInput() with shiny

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
#' @returns A reactiveValues list with a single element, `input_values`, which
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
				expanded = FALSE,
				cols = NULL
			),
			args_apply_filters
		)
		x_filt <- do.call(apply_filters, args_apply_filters)
		update_input <- function(col, id) {
			val <- input[[id]]
			if (!is.null(val) || !identical(length(val), 0L)) {
				return(invisible())
			}
			args <- list(col, id)
			names(args) <- c("x", arg_name_input_id(col))
			do.call(updateFilterInput, args)
		}
		mapply(update_input, x_filt, get_input_ids(x_filt))
		out_input$input_values <- input
	})
	return(out_input)
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
#' @returns A named list of input values corresponding to the names in `x`.
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
