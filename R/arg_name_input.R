# Shared Docs ####
#' Determine Filter Input Argument Names
#'
#' @description
#' Generics that determine the appropriate argument names for filter input
#' functions based on the type of object being filtered. These generics
#' dispatch on `x` and return the \pkg{shiny} input argument name(s) used
#' internally by \pkg{shinyfilters}.
#
#' @param x The object called by [filterInput()].
#' @param ... Additional arguments passed to methods.
#'
#' @returns
#' * `arg_name_input_id()`: Always returns `"inputId"`
#' * `arg_name_input_label()`: Always returns `"label"`
#' * `arg_name_input_value()`: Returns the appropriate argument name(s):
#'   * character: `"selected"` (default), or `"value"` ()`textbox = TRUE`)
#'   * Date: `"value"` (default), or `c("start", "end")` (`range = TRUE`)
#'   * factor/list/logical: `"selected"`
#'   * numeric: `"value"`
#'   * POSIXt: dispatches to Date method
#'   * data.frame: list of values for each column
#'
#' @keywords internal
#'
#' @name arg_name_input_generics
NULL

# Generic: arg_name_input_id ####
#' @rdname arg_name_input_generics
#' @export
arg_name_input_id <- new_generic(
	name = "arg_name_input_id",
	dispatch_args = c("x")
)

## Method: any ####
method(arg_name_input_id, class_any) <- function(x, ...) {
	"inputId"
}

# Generic: arg_name_input_label ####
#' @rdname arg_name_input_generics
#' @export
arg_name_input_label <- new_generic(
	name = "arg_name_input_label",
	dispatch_args = c("x")
)

## Method: any ####
method(arg_name_input_label, class_any) <- function(x, ...) {
	"label"
}

# Generic: arg_name_input_value ####
#' @rdname arg_name_input_generics
#' @export
arg_name_input_value <- new_generic(
	name = "arg_name_input_value",
	dispatch_args = c("x")
)

## Method: character ####
method(arg_name_input_value, class_character) <- function(x, ...) {
	args <- list(...)
	if (isTRUE(args$textbox)) {
		return("value")
	}
	"selected"
}

## Method: data.frame ####
method(arg_name_input_value, class_data.frame) <- function(x, ...) {
	lapply(x, arg_name_input_value, ...)
}

## Method: Date  ####
method(arg_name_input_value, class_Date) <- function(x, ...) {
	args <- list(...)
	if (isTRUE(args$range)) {
		# `range = TRUE`
		return(c("start", "end"))
	}
	"value"
}

## Method: factor | logical ####
method(arg_name_input_value, class_factor | class_logical) <- function(x, ...) {
	"selected"
}

## Method: list ####
method(arg_name_input_value, class_list) <- function(x, ...) {
	s7_check_is_valid_list_dispatch(x, function_name = "arg_name_input_value")
	"selected"
}

## Method: numeric ####
method(arg_name_input_value, class_numeric) <- function(x, ...) {
	"value"
}

## Method: POSIXt ####
method(arg_name_input_value, class_POSIXt) <- function(x, ...) {
	arg_name_input_value(x = as.Date(x), ...)
}
