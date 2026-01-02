# Generic: args_filter_input ####
#' Derive Arguments for \pkg{shiny} Inputs
#'
#' Provides the appropriate function arguments for the input function selected
#' by [filterInput()] or [updateFilterInput()].
#'
#' @param x The object being passed to [filterInput()] or [updateFilterInput()].
#' @param ... Additional arguments passed to the method. See details.
#'
#' @details
#' The following arguments are supported in `...`:
#' \describe{
#'   \item{range}{
#'   *(Date, POSIXt)*. Logical. If `TRUE`, `args_filter_input()` will provide
#'   the arguments for range date inputs. Only applies when `x` is of class
#'   `Date` or `POSIXt`.}
#'
#'   \item{textbox}{
#'   *(character)*. Logical. If `FALSE` (the default), `args_filter_input()`
#'   will provide the arguments for select inputs.}
#'
#'   \item{choices_asis}{
#'   *(character, factor, logical)*. Logical. If `TRUE`, the choices
#'   provided to select inputs will not be modified. If `FALSE` (the default),
#'   duplicate values will be removed and the choices will be sorted. Only
#'   applies when `x` is of class `character`, `factor`, or `logical`.}
#'
#'   \item{server}{
#'   If `TRUE`, indicates that the choices will be provided server-side. In
#'   this case, arguments are not computed for `args_filter_input()`. Ignored
#'   in `args_update_filter_input()`.}
#'
#'   \item{args_unique}{
#'   An optional named list of arguments passed to [unique()], called when `x`
#'   is a *character*, *factor*, or *logical*, `textbox = FALSE`, and
#'   `choices_asis = FALSE`.}
#'
#'   \item{args_sort}{
#'   An optional named list of arguments passed to [sort()], which is called
#'   after [unique()].}
#' }
#'
#' @returns A named list of arguments for a \pkg{shiny} input function
#'
#' @examples
#' args_filter_input(iris$Petal.Length)
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
	._discrete_choice_inputs(x = x, choices_asis = choices_asis, ...)
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
method(args_filter_input, class_factor | class_logical) <- function(
	x,
	choices_asis = FALSE,
	...
) {
	._discrete_choice_inputs(x = x, choices_asis = choices_asis, ...)
}

## Method: list ####
method(args_filter_input, class_list) <- function(x, choices_asis = TRUE, ...) {
	s7_check_is_valid_list_dispatch(x, function_name = "args_filter_input")
	if (isFALSE(choices_asis)) {
		stop("Argument `choices_asis` must be TRUE when `x` is a list.")
	}
	._discrete_choice_inputs(x = x, choices_asis = TRUE, ...)
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
._discrete_choice_inputs <- function(
	x,
	choices_asis,
	args_unique = NULL,
	args_sort = NULL,
	...
) {
	check_supplied_arguments(args_unique)
	check_supplied_arguments(args_sort)
	args <- list(...)
	if (isTRUE(args$server)) {
		return(list(choices = ""))
	}
	if (!isTRUE(choices_asis)) {
		x <- do.call(unique, c(list(x = x), args_unique))
		x <- do.call(sort, c(list(x = x), args_sort))
	}
	list(choices = x)
}

check_supplied_arguments <- function(args) {
	if (is.null(args) || identical(args, list())) {
		return(invisible())
	}
	if (!is.list(args)) {
		stop("Supplied arguments must be a list.")
	}
	if (any(names(args) == "")) {
		stop("All supplied arguments must be named.")
	}
	if (!identical(names(args), unique(names(args)))) {
		stop("All argument names must be unique.")
	}
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
	if (all(arg_name_input_value(x) %in% names(args))) {
		args <- args[names(args) != arg_name_input_value(x)]
		if (identical(length(args), 0L)) {
			return(NULL)
		}
	}
	return(args)
}
