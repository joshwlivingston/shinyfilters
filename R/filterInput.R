# R/filterInput.R
#
# Generic to create shiny inputs from objects

# Generic: filterInput ####
#' Create a \pkg{shiny} Input
#'
#' Selects and creates a \pkg{shiny} input based the type of object `x` and
#' other arguments.
#'
#' @param x The object used to create the input.
#' @param ... Arguments used for input selection or passed to the selected
#'   input. See details.
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
#'    *(character)*. Logical. Controls whether to use  [textAreaInput]
#'    (`TRUE`) or [textInput] (`FALSE`, default). Only applies when
#'    `textbox` is `TRUE`.}
#'
#'   \item{radio}{
#'     *(character, factor, list, logical)*. Logical. Controls whether to use
#'     [radioButtons] (`TRUE`) or a dropdown input (`FALSE`, default).
#'     For character vectors, `radio` only applies if `textbox` is `FALSE`,
#'     the default.}
#'
#'   \item{range}{
#'   *(Date, POSIXt)*. Logical. Controls whether to use [dateRangeInput]
#'   (`TRUE`) or [dateInput] (`FALSE`, default).}
#'
#'   \item{selectize}{
#'   *(character, factor, list, logical)*. Logical. Controls whether to use
#'   [selectizeInput] (`TRUE`) or [selectInput]
#'   (`FALSE`, default). For character vectors, `selectize` only applies if
#'   `textbox` is `FALSE`, the default.}
#'
#'   \item{slider}{
#'   *(numeric)*. Logical. Controls whether to use [sliderInput]
#'   (`TRUE`) or [numericInput] (`FALSE`, default).}
#'
#'   \item{textbox}{
#'   *(character)*. Logical. Controls whether to use a text input
#'   (`TRUE`) or a dropdown input (`FALSE`, default).}
#'
#'   \item{ns}{
#'   An optional namespace created by [NS()]. Useful when using
#'   `filterInput()` on a data.frame inside a \pkg{shiny} module.}
#'
#' }
#'
#' Remaining arguments passed to `...` are passed to the [args_filter_input()]
#' or the selected input function.
#'
#' @returns One of the following \pkg{shiny} inputs is returned, based on the
#' type of object passed to `x`, and other specified arguments. See
#' `vignette("filter-input-catalog")` for the full list of examples.
#'
#' \tabular{lll}{
#'   \strong{Value}          \tab \strong{`x`}                     \tab \strong{Arguments}              \cr
#'
#'   [dateInput]      \tab Date, POSIXt                     \tab *default*                       \cr
#'   [dateRangeInput] \tab Date, POSIXt                     \tab `range = TRUE`                  \cr
#'   [numericInput]   \tab numeric                          \tab *default*                       \cr
#'   [radioButtons]   \tab character, factor, list, logical \tab `radio = TRUE`                  \cr
#'   [selectInput]    \tab character, factor, list, logical \tab *default*                       \cr
#'   [selectizeInput] \tab character, factor, list, logical \tab `selectize = TRUE`              \cr
#'   [sliderInput]    \tab numeric                          \tab `slider = TRUE`                 \cr
#'   [textAreaInput]  \tab character                        \tab `textbox = TRUE`, `area = TRUE` \cr
#'   [textInput]      \tab character                        \tab `textbox = TRUE`                \cr
#' }
#'
#' @examplesIf interactive()
#' library(shiny)
#'
#' ui <- fluidPage(
#' 	 sidebarLayout(
#' 		 sidebarPanel(
#' 			 # Create a filterInput() inside a shiny app:
#' 			 filterInput(
#' 				x = letters,
#' 				inputId = "letter",
#' 				label = "Pick a letter:"
#' 			 )
#' 		 ),
#' 		 mainPanel(
#' 			 textOutput("selected_letter")
#' 		 )
#' 	 )
#' )
#'
#' server <- function(input, output, session) {
#' 	 output$selected_letter <- renderText({
#' 		 paste("You selected:", input$letter)
#' 	 })
#' }
#'
#' shinyApp(ui, server)
#' @export
filterInput <- new_generic(
	name = "filterInput",
	dispatch_args = c("x"),
	fun = function(x, ...) {
		if (all(is.na(x))) {
			cli_abort("{.arg x} must have at least one non-missing element.")
		}
		args <- list(...)
		if (!is.data.frame(x) && !is.null(args$ns)) {
			args <- c(list(x = x), args)
			args <- do.call(._apply_ns, args)
			return(do.call(filterInput, args))
		}
		S7_dispatch()
	}
)

## Method: character ####
method(filterInput, class_character) <- function(x, ...) {
	args <- list(...)
	if (isTRUE(args$textbox)) {
		if (isTRUE(args$area)) {
			# `textbox = TRUE, area = TRUE`
			input <- textAreaInput
		} else {
			# `textbox = TRUE`
			input <- textInput
		}
		return(do.call(call_filter_input, c(list(x = x, .f = input), args)))
	}
	# Default: select / radio input
	do.call(._input_discrete_choice, c(list(x = x), args))
}

## Method: data.frame ####
method(filterInput, class_data.frame) <- function(x, ...) {
	filter_input <- function(x, id, nm) {
		arg_name_id <- arg_name_input_id(x, ...)
		arg_name_label <- arg_name_input_label(x, ...)
		args <- list(x, id, nm)
		names(args) <- c("x", arg_name_id, arg_name_label)
		args <- c(args, list(...))
		do.call(filterInput, args)
	}
	do.call(
		tagList,
		mapply(
			filter_input,
			x,
			get_input_ids(x),
			get_input_labels(x),
			SIMPLIFY = FALSE
		)
	)
}

## Method: Date ####
method(filterInput, class_Date) <- function(x, ...) {
	args <- list(...)
	if (isTRUE(args$range)) {
		# `range = TRUE`
		input <- dateRangeInput
	} else {
		# default
		input <- dateInput
	}
	do.call(call_filter_input, c(list(x = x, .f = input), args))
}

## Method: factor | logical ####
method(filterInput, class_factor | class_logical) <- function(x, ...) {
	._input_discrete_choice(x, ...)
}

## Method: list ####
method(filterInput, class_list) <- function(x, ...) {
	s7_check_is_valid_list_dispatch(x, function_name = "filterInput")
	._input_discrete_choice(x, ...)
}

## Method: numeric ####
method(filterInput, class_numeric) <- function(x, ...) {
	args <- list(...)
	if (isTRUE(args$slider)) {
		# `slider = TRUE`
		input <- sliderInput
	} else {
		# default
		input <- numericInput
	}
	do.call(call_filter_input, c(list(x = x, .f = input), args))
}

## Method: POSIXt ####
method(filterInput, class_POSIXt) <- function(x, ...) {
	filterInput(x = as.Date(x), ...)
}

# Function: call_filter_input() ####
#' Prepare and Evaluate Input Function and Arguments
#'
#' Internal function used to prepare input arguments using
#' [args_filter_input()], and gracefully pass them to provided input function.
#'
#' `call_filter_input()` and `call_update_filter_input()` are used when
#' customizing \pkg{shinyfilters}. For more, see
#' `vignette("customizing-shinyfilters")`.
#'
#' @name call_input_function
#'
#' @param x The object being passed to [filterInput()].
#' @param .f The input function to be called.
#' @param ... Arguments passed to either [args_filter_input()] or provided
#'   input function.
#'
#' @returns The result of calling the provided input function.
#'
#' @examplesIf interactive()
#' library(S7)
#' library(shiny)
#' # call_filter_input() is used inside filterInput() methods
#' method(filterInput, class_numeric) <- function(x, ...) {
#'   call_filter_input(x, sliderInput, ...)
#' }
#'
#' # call_update_filter_input() is used inside updateFilterInput() methods
#' method(updateFilterInput, class_numeric) <- function(x, ...) {
#'   call_update_filter_input(x, updateSliderInput, ...)
#' }
NULL

#' @rdname call_input_function
#' @export
call_filter_input <- function(x, .f, ...) {
	if (is.data.frame(x)) {
		cli_abort(c(
			"{.fn call_filter_input} does not work with a {.cls data.frame}.",
			i = "Instead, call {.fn filterInput} on each column."
		))
	}
	args_provided <- list(...)
	function_args <- formalArgs(.f)
	if (identical(.f, selectizeInput)) {
		function_args <- union(
			function_args,
			setdiff(formalArgs(selectInput), "selectize")
		)
	}
	args_prepared <- ._prepare_input_args(x, ...)
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

# Generic: ._apply_ns ####
._apply_ns <- function(ns, ..., call = caller_env()) {
	._check_valid_shiny_ns(ns, call = call)

	args <- list(...)

	input_id_column <- arg_name_input_id(args$x)
	if (is.null(input_id_column)) {
		cli_abort(
			"{.code arg_name_input_id(x)} must not return {.code NULL} when {.arg ns} is provided.",
			call = call
		)
	}
	if (is.null(args[[input_id_column]])) {
		cli_abort(
			"{.arg {input_id_column}} is required when {.arg ns} is provided.",
			call = call
		)
	}

	args[[input_id_column]] <- ns(args[[input_id_column]])
	return(args)
}


# Function: ._input_discrete_choice ####
._input_discrete_choice <- function(x, ...) {
	args <- list(...)
	if (isTRUE(args$radio) && isTRUE(args$selectize)) {
		cli_abort(
			"{.arg radio} and {.arg selectize} can't both be {.code TRUE}.",
			call = caller_env()
		)
	}

	if (isTRUE(args$selectize)) {
		# `selectize = TRUE`
		input <- selectizeInput
	} else if (isTRUE(args$radio)) {
		# `radio = TRUE`
		input <- radioButtons
	} else {
		# default
		input <- selectInput
	}
	do.call(call_filter_input, c(list(x = x, .f = input), args))
}
