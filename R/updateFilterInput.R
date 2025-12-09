# R/filterInput.R
#
# Generic to create shiny inputs from objects

# Generic: filterInput ####
#' Create a \pkg{shiny} Input
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
#' \tabular{ll}{
#'   `area` \tab
#'    *(character)*. Logical. Controls whether to use  [shiny::updateTextAreaInput]
#'    (`TRUE`) or [shiny::updateTextInput] (`FALSE`, default). Only applies when
#'    `textbox` is `TRUE`. \cr
#'
#'   `range` \tab
#'   *(Date, POSIXt)*. Logical. Controls whether to use [shiny::updateDateRangeInput]
#'   (`TRUE`) or [shiny::updateDateInput] (`FALSE`, default). \cr
#'
#'   `selectize` \tab
#'   *(character, factor, list, logical)*. Logical. Controls whether to use
#'   [shiny::updateSelectizeInput] (`TRUE`) or [shiny::updateSelectInput]
#'   (`FALSE`, default). For character vectors, `selectize` only applies if
#'   `textbox` is `FALSE`, the default. \cr
#'
#'   `slider` \tab
#'   *(numeric)*. Logical. Controls whether to use [shiny::updateSliderInput]
#'   (`TRUE`) or [shiny::updateNumericInput] (`FALSE`, default)  . \cr
#'
#'   `textbox` \tab
#'   *(character)*. Logical. Controls whether to update a text input
#'   (`TRUE`) or a dropdown input (`FALSE`, default). \cr
#'
#' }
#'
#' Remaining arguments passed to `...` are passed to
#' [args_update_filter_input()] or the selected input update function.
#'
#' @return The result of the following \pkg{shiny} input updates is returned,
#' based on the type of object passed to `x`, and other specified arguments.
#'
#' \tabular{lll}{
#'   \strong{Value}          \tab \strong{`x`}                     \tab \strong{Arguments}              \cr
#'
#'   [shiny::updateDateInput]      \tab Date, POSIXt                     \tab *default*                       \cr
#'   [shiny::updateDateRangeInput] \tab Date, POSIXt                     \tab `range = TRUE`                  \cr
#'   [shiny::updateNumericInput]   \tab numeric                          \tab *default*                       \cr
#'   [shiny::updateRadioButtons]   \tab character, factor, list, logical \tab `radio = TRUE`                  \cr
#'   [shiny::updateSelectInput]    \tab character, factor, list, logical \tab *default*                       \cr
#'   [shiny::updateSelectizeInput] \tab character, factor, list, logical \tab `selectize = TRUE`              \cr
#'   [shiny::updateSliderInput]    \tab numeric                          \tab `slider = TRUE`                 \cr
#'   [shiny::updateTextAreaInput]  \tab character                        \tab `textbox = TRUE`, `area = TRUE` \cr
#'   [shiny::updateTextInput]      \tab character                        \tab `textbox = TRUE`                \cr
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
#' 	shiny::observe({
#' 		fruits_filtered <- fruits
#' 		if (!is.null(input$letter) && length(input$letter) != 0L) {
#' 			fruits_filtered <- fruits[input$letter]
#' 		}
#' 		#########################################################
#' 		# 2. Call updateFilterInput() inside the shiny server:
#' 		updateFilterInput(x = fruits_filtered, inputId = "fruits")
#' 		#########################################################
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
			call_update_filter_input(x, shiny::updateTextAreaInput, ...)
		} else {
			# `textbox = TRUE`
			call_update_filter_input(x, shiny::updateTextInput, ...)
		}
	} else {
		# Default: select / radio input
		do.call(._update_input_discrete_choice, c(list(x = x), args))
	}
}

## Method: data.frame ####
method(updateFilterInput, class_data.frame) <- function(x, input, ...) {
	mapply(
		function(col, nm) {
			val <- input[[nm]]
			if (!is.null(val) || !identical(length(val), 0L)) {
				return(invisible())
			}

			do.call(
				updateFilterInput,
				c(
					list(x = col, inputId = nm),
					list(...),
					set_names(as_list_(val), arg_name_input_value(col, ...))
				)
			)
		},
		x,
		names(x),
		SIMPLIFY = FALSE
	)
}

## Method: Date ####
method(updateFilterInput, class_Date) <- function(x, ...) {
	args <- list(...)
	if (isTRUE(args$range)) {
		# `range = TRUE`
		call_update_filter_input(x, shiny::updateDateRangeInput, ...)
	} else {
		# default
		call_update_filter_input(x, shiny::updateDateInput, ...)
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
		call_update_filter_input(x, shiny::updateSliderInput, ...)
	} else {
		# default
		call_update_filter_input(x, shiny::updateNumericInput, ...)
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
		call_update_filter_input(x, shiny::updateSelectizeInput, ...)
	} else if (isTRUE(args$radio)) {
		# `radio = TRUE`
		call_update_filter_input(x, shiny::updateRadioButtons, ...)
	} else {
		# default
		call_update_filter_input(x, shiny::updateSelectInput, ...)
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
