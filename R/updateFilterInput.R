# R/filterInput.R
#
# Generic to create shiny inputs from objects

# Generic: filterInput ####
#' Update a \pkg{shiny} Input
#'
#' Updates a \pkg{shiny} input based the type of object `x` and other arguments.
#'
#' @param x The object used to create the input.
#' @param ... Arguments used for input selection or passed to the selected
#'   input update function. See details.
#'
#' @details
#' The following arguments passed to `...` are supported:
#  ---------
#  Dev note:
#
#  The tabular formatting below is used to match the output of a @param tag.
#  @param tags cannot be used for these arguments without a CRAN error, since
#  they are not named formals of the generic.
#  ---------
#' \describe{
#'   \item{area}{
#'    *(character)*. Logical. Controls whether to use  [updateTextAreaInput]
#'    (`TRUE`) or [updateTextInput] (`FALSE`, default). Only applies when
#'    `textbox` is `TRUE`.}
#'
#'   \item{radio}{
#'     *(character, factor, list, logical)*. Logical. Controls whether to use
#'     [updateRadioButtons] (`TRUE`) or a dropdown input update function
#'     (`FALSE`, default). For character vectors, `radio` only applies if
#'     `textbox` is `FALSE`, the default.}
#'
#'   \item{range}{
#'   *(Date, POSIXt)*. Logical. Controls whether to use [updateDateRangeInput]
#'   (`TRUE`) or [updateDateInput] (`FALSE`, default).}
#'
#'   \item{selectize}{
#'   *(character, factor, list, logical)*. Logical. Controls whether to use
#'   [updateSelectizeInput] (`TRUE`) or [updateSelectInput]
#'   (`FALSE`, default). For character vectors, `selectize` only applies if
#'   `textbox` is `FALSE`, the default.}
#'
#'   \item{slider}{
#'   *(numeric)*. Logical. Controls whether to use [updateSliderInput]
#'   (`TRUE`) or [updateNumericInput] (`FALSE`, default).}
#'
#'   \item{textbox}{
#'   *(character)*. Logical. Controls whether to update a text input
#'   (`TRUE`) or a dropdown input (`FALSE`, default).}
#'
#' }
#'
#' Remaining arguments passed to `...` are passed to
#' [args_update_filter_input()] or the selected input update function.
#'
#' @returns The result of the following \pkg{shiny} input updates is returned,
#' based on the type of object passed to `x`, and other specified arguments.
#'
#' \tabular{lll}{
#'   \strong{Value}          \tab \strong{`x`}                     \tab \strong{Arguments}              \cr
#'
#'   [updateDateInput]      \tab Date, POSIXt                     \tab *default*                       \cr
#'   [updateDateRangeInput] \tab Date, POSIXt                     \tab `range = TRUE`                  \cr
#'   [updateNumericInput]   \tab numeric                          \tab *default*                       \cr
#'   [updateRadioButtons]   \tab character, factor, list, logical \tab `radio = TRUE`                  \cr
#'   [updateSelectInput]    \tab character, factor, list, logical \tab *default*                       \cr
#'   [updateSelectizeInput] \tab character, factor, list, logical \tab `selectize = TRUE`              \cr
#'   [updateSliderInput]    \tab numeric                          \tab `slider = TRUE`                 \cr
#'   [updateTextAreaInput]  \tab character                        \tab `textbox = TRUE`, `area = TRUE` \cr
#'   [updateTextInput]      \tab character                        \tab `textbox = TRUE`                \cr
#' }
#'
#' @examplesIf interactive()
#' library(shiny)
#'
#' fruits <- list(
#' 	"a" = c("apples", "avocados"),
#' 	"b" = c("bananas", "blueberries"),
#' 	"c" = c("cherries", "cantaloupe")
#' )
#'
#' ui <- fluidPage(
#' 	sidebarLayout(
#' 		sidebarPanel(
#' 			filterInput(
#' 				x = letters[1:3],
#' 				inputId = "letter",
#' 				label = "Pick a letter:",
#'        multiple = TRUE
#' 			),
#' 			filterInput(
#' 				x = fruits,
#' 				inputId = "fruits",
#' 				label = "Pick a fruit:"
#' 			)
#' 		),
#'    mainPanel()
#' 	)
#' )
#'
#' server <- function(input, output, session) {
#' 	observe({
#' 		fruits_filtered <- fruits
#' 		if (!is.null(input$letter) && length(input$letter) != 0L) {
#' 			fruits_filtered <- fruits[input$letter]
#' 		}
#' 		# Call updateFilterInput() inside the shiny server:
#' 		updateFilterInput(x = fruits_filtered, inputId = "fruits")
#' 	})
#' }
#' shinyApp(ui, server)
#' @export
updateFilterInput <- new_generic(
	name = "updateFilterInput",
	dispatch_args = c("x")
)

## Method: character ####
method(updateFilterInput, class_character) <- function(x, ...) {
	args <- list(...)
	if (isTRUE(args$textbox)) {
		if (isTRUE(args$area)) {
			# `textbox = TRUE, area = TRUE`
			call_update_filter_input(x, updateTextAreaInput, ...)
		} else {
			# `textbox = TRUE`
			call_update_filter_input(x, updateTextInput, ...)
		}
	} else {
		# Default: select / radio input
		do.call(._update_input_discrete_choice, c(list(x = x), args))
	}
}

## Method: data.frame ####
method(updateFilterInput, class_data.frame) <- function(x, ...) {
	mapply(
		function(col, nm) {
			base_args <- list(col)
			args_provided <- list(...)
			inputId <- arg_name_input_id(col, ...)
			if (!(inputId %in% names(args_provided))) {
				base_args <- c(base_args, list(nm))
				names(base_args) <- c("x", inputId)
			} else {
				names(base_args) <- c("x")
			}
			do.call(updateFilterInput, c(base_args, args_provided))
		},
		x,
		get_input_ids(x),
		SIMPLIFY = FALSE
	)
}

## Method: Date ####
method(updateFilterInput, class_Date) <- function(x, ...) {
	args <- list(...)
	if (isTRUE(args$range)) {
		# `range = TRUE`
		call_update_filter_input(x, updateDateRangeInput, ...)
	} else {
		# default
		call_update_filter_input(x, updateDateInput, ...)
	}
}

## Method: factor | logical ####
method(updateFilterInput, class_factor | class_logical) <- function(x, ...) {
	._update_input_discrete_choice(x, ...)
}

## Method: list ####
method(updateFilterInput, class_list) <- function(
	x,
	input,
	...
) {
	s7_check_is_valid_list_dispatch(x, function_name = "updateFilterInput")
	._update_input_discrete_choice(x, ...)
}

## Method: numeric ####
method(updateFilterInput, class_numeric) <- function(x, ...) {
	args <- list(...)
	if (isTRUE(args$slider)) {
		# `slider = TRUE`
		call_update_filter_input(x, updateSliderInput, ...)
	} else {
		# default
		call_update_filter_input(x, updateNumericInput, ...)
	}
}

## Method: POSIXt ####
method(updateFilterInput, class_POSIXt) <- function(
	x,
	input,
	...
) {
	updateFilterInput(x = as.Date(x), ...)
}

# Function: ._update_input_discrete_choice ####
._update_input_discrete_choice <- function(x, ...) {
	args <- list(...)
	if (isTRUE(args$radio) && isTRUE(args$selectize)) {
		stop(
			"Arguments `radio` and `selectize` cannot both be TRUE."
		)
	}

	if (isTRUE(args$selectize)) {
		# `selectize = TRUE`
		call_update_filter_input(x, updateSelectizeInput, ...)
	} else if (isTRUE(args$radio)) {
		# `radio = TRUE`
		call_update_filter_input(x, updateRadioButtons, ...)
	} else {
		# default
		call_update_filter_input(x, updateSelectInput, ...)
	}
}

#' @export
#' @rdname call_input_function
call_update_filter_input <- function(x, .f, ...) {
	if (is.data.frame(x)) {
		stop("call_update_filter_input() is not implemented for data.frames.")
	}
	args_provided <- list(...)
	function_args <- formalArgs(.f)

	args_prepared <- ._prepare_update_input_args(x, ...)
	args <- c(
		args_prepared,
		args_provided[
			names(args_provided) %in%
				function_args &
				!(names(args_provided) %in% names(args_prepared))
		]
	)
	do.call(.f, args)
}
