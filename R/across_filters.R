# R/across_filters.R
#
# across_filters(): choose one input for the columns a tidyselect expression
# selects. The call is captured, never evaluated, so dplyr is not involved.

# Function: across_filters() ####
#' Choose One Input for Several Columns
#'
#' `across_filters()` selects columns with
#' <[`tidy-select`][tidyselect::language]> and names one input for all of
#' them. Use it inside [with_filter()], where it can be mixed with named
#' columns, or inside [dplyr::mutate()]. It is never called on its own: both
#' verbs capture the call.
#'
#' Inside [dplyr::mutate()], [dplyr::across()] does the same thing and is
#' accepted in its place.
#'
#' @param .cols Columns to set, using
#'   <[`tidy-select`][tidyselect::language]>, such as `origin`,
#'   `c(origin, carrier)`, or `where(is.numeric)`. Defaults to every column.
#' @param .fns The input for the selected columns: a keyword, a \pkg{shiny}
#'   input function, or an [as_filter()] object, as described in
#'   [with_filter()]. A one-sided formula naming an input, such as
#'   `~ "slider"`, also works.
#' @param ... Not supported.
#' @param .names Not supported. `across_filters()` chooses an input for the
#'   selected columns; it doesn't rename them.
#'
#' @returns Nothing. Calling `across_filters()` outside [with_filter()] or
#'   [dplyr::mutate()] is an error.
#'
#' @seealso [with_filter()]
#'
#' @examples
#' filters <- shinyfilters(nyc_flights)
#' with_filter(filters, across_filters(where(is.numeric), "slider"))
#'
#' # Mix with named columns. Later arguments win.
#' with_filter(
#'   filters,
#'   across_filters(everything(), "selectize"),
#'   origin = "radio"
#' )
#' @export
across_filters <- function(
	.cols = everything(),
	.fns = NULL,
	...,
	.names = NULL
) {
	cli_abort(c(
		"{.fn across_filters} must be used inside {.fn with_filter} or {.fn mutate}.",
		i = "It selects columns and names one input for all of them."
	))
}

._is_across_call <- function(expr, names = MUTATE_ACROSS_NAMES) {
	is_call(expr, names)
}

# `across_filters()` is its own reference signature: `call_match()` uses it to
# name the arguments, fill in the defaults, and collect anything it doesn't
# take into `...`, so every unsupported form gets its own error. Errors name
# the function the user wrote, which inside `mutate()` may be `across()`.
._across_spec <- function(quo, call) {
	expr <- quo_get_expr(quo)
	fn <- call_name(expr)
	args <- call_args(call_match(
		expr,
		across_filters,
		defaults = TRUE,
		dots_expand = FALSE
	))

	extra <- args[["..."]]
	if (!is.null(extra)) {
		cli_abort(
			c(
				"{.fn {fn}} takes only {.arg .cols} and {.arg .fns} here.",
				x = "Got {length(extra)} extra argument{?s}."
			),
			call = call
		)
	}
	if (!is.null(args[[".names"]])) {
		cli_abort(
			c(
				"{.fn {fn}} doesn't support {.arg .names} here.",
				i = "It chooses an input for the selected columns; it doesn't rename them."
			),
			call = call
		)
	}
	if (is.null(args[[".fns"]])) {
		cli_abort(
			c(
				"{.fn {fn}} needs an input as its second argument.",
				i = "Keywords are strings, e.g. {.code \"slider\"}.",
				i = "Functions are shiny inputs, e.g. {.fn shiny::radioButtons}."
			),
			call = call
		)
	}

	env <- quo_get_env(quo)
	list(
		cols = new_quosure(args[[".cols"]], env),
		input = new_quosure(
			._across_input(args[[".fns"]], fn = fn, call = call),
			env
		)
	)
}

._abort_across_named <- function(quo, name, call) {
	fn <- call_name(quo_get_expr(quo))
	cli_abort(
		c(
			"{.fn {fn}} can't be named.",
			i = "{.fn {fn}} already selects the columns it sets.",
			i = "To set one column, use {.code {name} = input}."
		),
		call = call
	)
}

# `across_filters(cols, ~ "slider")` reads naturally to a dplyr user, so unwrap
# a one-sided formula that names an input. A purrr-style lambda means something
# else entirely here: `.fns` names an input, it doesn't transform values.
._across_input <- function(input, fn, call) {
	if (!is_formula(input)) {
		return(input)
	}
	rhs <- f_rhs(input)
	if (is_formula(input, lhs = TRUE) || !._is_input_name(rhs)) {
		cli_abort(
			c(
				"Can't use {.code {as_label(input)}} as an input.",
				i = "{.fn {fn}} takes a keyword or a shiny input function, not a lambda."
			),
			call = call
		)
	}
	rhs
}

._is_input_name <- function(expr) {
	is_string(expr) || is_symbol(expr) || is_call(expr, c("::", ":::"))
}
