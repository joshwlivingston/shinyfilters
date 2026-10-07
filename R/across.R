# R/across.R
#
# across(): choose one input for the columns a tidyselect expression selects.
# shinyfilters has no `across()` of its own: `with_filters()` and `mutate()`
# capture the call and never evaluate it, so dplyr is not involved.

._is_across_call <- function(expr) {
	is_call(expr, "across")
}

# The arguments of `dplyr::across()`. `call_match()` uses them to name the
# arguments of a captured call, fill in the defaults, and collect anything else
# into `...`, so every unsupported form gets its own error.
._across_signature <- function(
	.cols = everything(),
	.fns = NULL,
	...,
	.names = NULL
) {
	NULL
}

._across_spec <- function(quo, call) {
	args <- call_args(call_match(
		quo_get_expr(quo),
		._across_signature,
		defaults = TRUE,
		dots_expand = FALSE
	))

	extra <- args[["..."]]
	if (!is.null(extra)) {
		cli_abort(
			c(
				"{.fn across} takes only {.arg .cols} and {.arg .fns} here.",
				x = "Got {length(extra)} extra argument{?s}."
			),
			call = call
		)
	}
	if (!is.null(args[[".names"]])) {
		cli_abort(
			c(
				"{.fn across} doesn't support {.arg .names} here.",
				i = "It chooses an input for the selected columns; it doesn't rename them."
			),
			call = call
		)
	}
	if (is.null(args[[".fns"]])) {
		cli_abort(
			c(
				"{.fn across} needs an input as its second argument.",
				i = "Keywords are strings, e.g. {.code \"slider\"}.",
				i = "Functions are shiny inputs, e.g. {.fn shiny::radioButtons}."
			),
			call = call
		)
	}

	env <- quo_get_env(quo)
	list(
		cols = new_quosure(args[[".cols"]], env),
		input = new_quosure(._across_input(args[[".fns"]], call = call), env)
	)
}

._abort_across_named <- function(name, call) {
	cli_abort(
		c(
			"{.fn across} can't be named.",
			i = "{.fn across} already selects the columns it sets.",
			i = "To set one column, use {.code {name} = input}."
		),
		call = call
	)
}

# `across(cols, ~ "slider")` reads naturally to a dplyr user, so unwrap a
# one-sided formula that names an input, or wraps one in `as_filter()`, whose
# arguments use the lambda pronoun `.x`. A purrr-style lambda means something
# else entirely here: `.fns` names an input, it doesn't transform values.
._across_input <- function(input, call) {
	if (!is_formula(input)) {
		return(input)
	}
	rhs <- f_rhs(input)
	if (is_formula(input, lhs = TRUE) || !._is_input_name(rhs)) {
		cli_abort(
			c(
				"Can't use {.code {as_label(input)}} as an input.",
				i = "{.fn across} takes a keyword or a shiny input function, not a lambda."
			),
			call = call
		)
	}
	rhs
}

._is_input_name <- function(expr) {
	is_string(expr) ||
		is_symbol(expr) ||
		is_call(expr, c("::", ":::", "as_filter"))
}
