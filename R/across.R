# R/across.R
#
# across(): choose one input for the columns a tidyselect expression selects.
# shinyfilters has no `across()` of its own: `with_filters()` and `mutate()`
# capture the call and never evaluate it, so dplyr is not involved.

# A captured `across()` call: `dplyr::across()`, or `across()` where that name
# is dplyr's function or no function at all. shinyfilters never intercepts
# another `across()`, the user's own or an attached package's: that call is
# ordinary code.
._is_across_call <- function(quo) {
	expr <- quo_get_expr(quo)
	is_call(expr, "across", ns = "dplyr") ||
		(is_call(expr, "across", ns = "") && !._is_other_across(quo))
}

# Whether `across`, where the user wrote it, is a function other than dplyr's
._is_other_across <- function(quo) {
	fn <- get0("across", envir = quo_get_env(quo), mode = "function")
	!is.null(fn) && !._is_dplyr_across(fn)
}

# For the error an unnamed call to another `across()` gets: it isn't one of the
# forms a verb takes, and the reason isn't obvious.
._other_across_hint <- function(quos) {
	is_other <- vapply(
		quos,
		function(quo) {
			is_call(quo_get_expr(quo), "across") && !._is_across_call(quo)
		},
		logical(1)
	)
	if (any(is_other)) {
		"{.fn across} is another function here. To select columns, use {.fn dplyr::across} or a formula."
	}
}

._is_dplyr_across <- function(fn) {
	isNamespaceLoaded("dplyr") &&
		identical(fn, get("across", envir = asNamespace("dplyr")))
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

# The columns and the second argument of a captured `across()` call, as they
# were written. `hint` says where the verb wants extra arguments to go.
._across_args <- function(quo, call, hint = NULL) {
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
				x = "Got {length(extra)} extra argument{?s}.",
				i = hint
			),
			call = call
		)
	}
	if (!is.null(args[[".names"]])) {
		cli_abort(
			c(
				"{.fn across} doesn't support {.arg .names} here.",
				i = "It selects columns; it doesn't rename them."
			),
			call = call
		)
	}
	list(cols = args[[".cols"]], fns = args[[".fns"]])
}

._across_spec <- function(quo, call) {
	args <- ._across_args(quo, call = call)
	if (is.null(args$fns)) {
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
		cols = new_quosure(args$cols, env),
		input = new_quosure(._across_input(args$fns, call = call), env)
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
# one-sided formula that names an input. A purrr-style lambda means something
# else entirely here: `.fns` names an input, it doesn't transform values. A
# two-sided formula is an input with its arguments, read later.
._across_input <- function(input, call) {
	if (!is_formula(input) || is_formula(input, lhs = TRUE)) {
		return(input)
	}
	rhs <- f_rhs(input)
	if (!._is_input_name(rhs)) {
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
		is_call(expr, c("::", ":::"))
}
