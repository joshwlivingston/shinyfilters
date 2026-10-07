# R/with_args.R
#
# with_args(): set the arguments of the inputs columns have. `arg := value` is
# read as written and never evaluated: shinyfilters has no `:=` of its own.

# Function: with_args() ####
#' Set the Arguments of Inputs
#'
#' `with_args()` sets arguments for the inputs [filterInput()] creates for one
#' or more columns of a configuration made by [shinyfilters()], such as a
#' slider's `value`, `step`, or `width`. Each column keeps its input.
#'
#' Arguments stay with their column. Setting one again replaces it, and an
#' input chosen later with [with_filters()] keeps the ones it has an argument
#' for.
#'
#' @param .filters A configuration created by [shinyfilters()].
#' @param ... Any number of formulas and `across()` calls. Each selects columns
#'   with <[`tidy-select`][tidyselect::language]> and sets arguments for their
#'   inputs:
#'
#'   * `cols ~ arg := value`: one argument.
#'   * `cols ~ list(arg := value, ...)`: several. Inside `list()`, `=` works
#'     as well as `:=`.
#'   * `across(cols, arg := value)` or `across(cols, list(...))`: the same,
#'     written like [dplyr::across()].
#'
#'   `:=` and `across()` are read as written and never run, so no package
#'   that defines them is needed.
#'
#'   Arguments replace the ones shinyfilters passes for the column, such as
#'   `label`, `choices`, `min`, `max`, and `value`. `inputId` can't be set: an
#'   input's id is always its column's name.
#'
#'   A value can use `.x`, the column the input is created for. It is
#'   evaluated when the input is created, and a call in it that takes `na.rm`,
#'   such as `range(.x)`, gets `na.rm = TRUE` unless it sets `na.rm` itself.
#'   Other values are evaluated right away, and can use the columns too, as
#'   they are at that point.
#'
#' @returns The updated configuration.
#'
#' @seealso [with_filters()] to choose inputs, [with_defaults()] to set
#'   arguments for every column.
#'
#' @examples
#' filters <- shinyfilters(nyc_flights)
#'
#' # A range slider: `.x` is the column the input is created for
#' filters <- with_args(filters, dep_delay ~ value := range(.x))
#' filters$dep_delay
#'
#' # Several arguments
#' with_args(filters, dep_delay ~ list(value := range(.x), step = 5))
#'
#' # The same arguments for several columns
#' with_args(filters, across(c(dep_delay, distance), value := range(.x)))
#'
#' # Different arguments for different columns
#' with_args(filters, dep_delay ~ step := 5, origin ~ label := "Airport")
#' @export
with_args <- function(.filters, ...) {
	check_shinyfilters(.filters)
	call <- current_env()
	quos <- enquos(..., .unquote_names = FALSE)
	if (length(quos) == 0) {
		._abort_with_args_form(call = call)
	}
	config <- .filters
	nms <- names2(quos)
	# One argument at a time, so a later one wins.
	for (i in seq_along(quos)) {
		spec <- ._args_spec(quos[[i]], nms[[i]], call = call)
		cols <- ._eval_cols(config, spec$cols, call = call)
		args <- ._capture_args(
			spec$args,
			spec$env,
			config@data,
			call = call,
			fn = "with_args"
		)
		override <- list(input = NULL, args = args, fn = "with_args")
		config <- ._set_overrides(
			config,
			set_names(rep(list(override), length(cols)), cols)
		)
	}
	config
}

# One `with_args()` argument: the columns it selects and the arguments it sets,
# as they were written. `cols ~ arg := value` parses as `(cols ~ arg) := value`,
# so its columns are on the left of the `:=`.
._args_spec <- function(quo, name, call) {
	expr <- quo_get_expr(quo)
	cols <- NULL
	args <- NULL
	if (name != "") {
		# A named argument is none of the forms.
	} else if (is_call(expr, ":=") && is_formula(expr[[2]], lhs = TRUE)) {
		cols <- f_lhs(expr[[2]])
		args <- call2(":=", f_rhs(expr[[2]]), expr[[3]])
	} else if (is_formula(expr, lhs = TRUE)) {
		cols <- f_lhs(expr)
		args <- f_rhs(expr)
	} else if (._is_across_call(quo)) {
		across <- ._across_args(
			quo,
			call = call,
			hint = "Put several arguments in {.code list()}."
		)
		cols <- across$cols
		args <- across$fns
	}
	arg_exprs <- ._arg_exprs(args)
	if (is.null(arg_exprs)) {
		._abort_with_args_form(call = call, quo = quo, name = name, rhs = args)
	}
	env <- quo_get_env(quo)
	list(cols = new_quosure(cols, env), args = arg_exprs, env = env)
}

# The value expressions of `arg := value` or `list(...)`, named by argument, or
# `NULL` for anything else. In `list()`, `arg = value` works too; an element
# that is neither keeps an empty name.
._arg_exprs <- function(expr) {
	if (._is_arg_walrus(expr)) {
		els <- list(expr)
	} else if (is_call(expr, "list")) {
		els <- call_args(expr)
	} else {
		return(NULL)
	}
	if (length(els) == 0) {
		return(NULL)
	}
	nms <- names2(els)
	is_walrus <- nms == "" & vapply(els, ._is_arg_walrus, logical(1))
	nms[is_walrus] <- vapply(
		els[is_walrus],
		function(el) as.character(el[[2]]),
		character(1)
	)
	# `lapply()`, so a `NULL` value stays in the list.
	values <- lapply(seq_along(els), function(i) {
		if (is_walrus[[i]]) els[[i]][[3]] else els[[i]]
	})
	set_names(values, nms)
}

._is_arg_walrus <- function(expr) {
	is_call(expr, ":=", n = 2) && (is_symbol(expr[[2]]) || is_string(expr[[2]]))
}

# Checks the arguments `:=` sets and captures their values. `data` holds the
# configuration's columns, which a value evaluated now can use.
._capture_args <- function(exprs, env, data, call, fn) {
	nms <- names(exprs)
	if (any(nms == "")) {
		unnamed <- ._label(exprs[nms == ""][[1]])
		cli_abort(
			c("All arguments must be named.", x = "{.code {unnamed}} isn't."),
			call = call
		)
	}
	repeated <- unique(nms[duplicated(nms)])
	if (length(repeated) > 0) {
		cli_abort(
			"{qty(repeated)}Argument{?s} {.arg {repeated}} {?is/are} set more than once.",
			call = call
		)
	}
	if ("inputId" %in% nms) {
		cli_abort(
			c(
				"Can't set {.arg inputId} in {.fn {fn}}.",
				i = "An input's id is always its column's name."
			),
			call = call
		)
	}
	lapply(set_names(nm = nms), function(nm) {
		quo <- new_quosure(exprs[[nm]], env)
		try_fetch(
			._capture_arg(quo, data = data),
			error = function(cnd) {
				._resignal_silent(cnd)
				cli_abort(
					"Can't evaluate {.code {nm} := {as_label(quo)}}.",
					parent = cnd,
					call = call
				)
			}
		)
	})
}

# Only a value that uses `.x` waits for its column. The rest are evaluated now.
._capture_arg <- function(quo, data = NULL) {
	if (".x" %in% all.vars(quo_get_expr(quo))) {
		quo_inject_narm(quo)
	} else {
		eval_tidy(quo, data = data)
	}
}

# Code as the user wrote it. `as_label()` prints `:=` as a prefix call, so code
# that has one is deparsed instead, on one line.
._label <- function(x) {
	expr <- if (is_quosure(x)) quo_get_expr(x) else x
	if (!(":=" %in% all.names(expr))) {
		return(as_label(x))
	}
	paste(expr_deparse(expr, width = 500L), collapse = " ")
}

# `rhs` is what the argument has where its arguments belong: an input there
# belongs in `with_filters()`.
._abort_with_args_form <- function(call, quo = NULL, name = "", rhs = NULL) {
	label <- NULL
	if (!is.null(quo)) {
		label <- ._label(quo)
		if (name != "") {
			label <- paste(name, "=", label)
		}
	}
	cli_abort(
		c(
			"{.fn with_args} takes {.code cols ~ arg := value} formulas and {.fn across} calls.",
			x = if (!is.null(label)) "{.code {label}} isn't one of these.",
			x = if (!is.null(quo)) ._other_across_hint(list(quo)),
			i = if (._is_input_name(rhs)) {
				"To choose an input, use {.fn with_filters}."
			},
			i = "One argument: {.code with_args(filters, x ~ value := range(.x))}.",
			i = "Several: {.code with_args(filters, x ~ list(value := range(.x), step = 5))}.",
			i = "Several columns: {.code with_args(filters, across(c(x, y), value := range(.x)))}."
		),
		call = call
	)
}
