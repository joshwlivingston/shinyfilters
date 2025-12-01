# Generic: args_filter_input ####
#' Derive Arguments for \pkg{shiny} Inputs
#'
#' Internal. Provides the appropriate function arguments for the Shiny input
#' selected by [filterInput()].
#'
#' @param x The object being passed to [filterInput()].
#' @param ... Additional arguments passed to the method. See details.
#'
#' @details
#' The following aruguments are supported in `...`:
#' \tabular{ll}{
#'   `textbox` \tab
#'    *(character)*. Logical. If `FALSE` (the default), `args_filter_input()`
#'      will provide the arguments for select inputs.
#' }
#'
#'
#' @examples
#' args_filter_input(letters, as.factor = TRUE)
#'
#' @export
args_filter_input <- new_generic(
	name = "args_filter_input",
	dispatch_args = "x"
)

## Method: character ####
method(args_filter_input, class_character) <- function(
	x,
	textbox = FALSE,
	choices_asis = FALSE,
	...
) {
	if (isTRUE(textbox)) {
		return(NULL)
	}
	._discrete_choice_inputs(x = x, asis = choices_asis, ...)
}

## Method: Date ####
method(args_filter_input, class_Date) <- function(x, ...) {
	args <- list(...)
	max_x <- max(x, na.rm = TRUE)
	min_x <- min(x, na.rm = TRUE)
	out <- list(min = min_x, max = max_x)
	if (isTRUE(args$range)) {
		out <- c(out, list(start = min_x, end = max_x))
	} else {
		out <- c(out, list(value = max_x))
	}
	return(out)
}

## Method: factor | logical ####
method(args_filter_input, class_factor) <- function(
	x,
	choices_asis = FALSE,
	...
) {
	._discrete_choice_inputs(x = x, asis = choices_asis, ...)
}

## Method: list ####
method(args_filter_input, class_list) <- function(x, choices_asis = TRUE, ...) {
	s7_check_is_valid_list_dispatch(x, function_name = "args_filter_input")
	._discrete_choice_inputs(x = x, asis = TRUE, ...)
}

## Method: numeric ####
method(args_filter_input, class_numeric) <- function(x, ...) {
	max_x <- max(x, na.rm = TRUE)
	list(
		min = min(x, na.rm = TRUE),
		max = max_x,
		value = max_x
	)
}

## Method POSIXt ####
method(args_filter_input, class_POSIXt) <- function(x, ...) {
	args_filter_input(as.Date(x), ...)
}

# Function: ._discrete_choice_inputs ####
._discrete_choice_inputs <- function(x, asis, ...) {
	args <- list(...)
	if (isTRUE(args$server)) {
		return(list(choices = "loading..."))
	}
	if (!isTRUE(asis)) {
		x <- sort(unique(x))
	}
	list(choices = x)
}

# Function: args_update_filter_input ####
#' @rdname args_filter_input
#' @export
args_update_filter_input <- function(x, ...) {
	args_provided <- list(...)
	if (!is.null(args_provided$server)) {
		args_provided$server <- FALSE
	}
	args <- do.call(args_filter_input, c(list(x = x), args_provided))
	args[[arg_name_input_id(x)]] <- NULL
	args[[arg_name_input_value(x)]] <- NULL
	return(args)
}
