# R/with_args.R
#
# with_args(): set the arguments of the inputs columns have, and the reader of
# `arg := value` that `with_filters()` and `mutate()` share with it. `:=` is
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
#'   input's id is always its column's name. `.update_fn := fn` names the
#'   function that updates the input instead, as described in
#'   [with_filters()].
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
		quo <- quos[[i]]
		target <- ._args_target(quo, nms[[i]], call = call)
		args <- ._arg_exprs(quo_get_expr(target$input))
		if (is.null(args)) {
			._abort_with_args_form(call, quo, nms[[i]], quo_get_expr(target$input))
		}
		cols <- ._eval_cols(config, target$cols, call = call)
		override <- ._args_override(
			args,
			quo_get_env(quo),
			config,
			call = call,
			fn = "with_args"
		)
		config <- ._set_overrides(
			config,
			set_names(rep(list(override), length(cols)), cols)
		)
	}
	config
}

# The columns one `with_args()` argument selects, and what it gives them
._args_target <- function(quo, name, call) {
	if (name == "" && ._is_cols_formula(quo)) {
		return(._formula_spec(quo))
	}
	if (name == "" && ._is_across_call(quo)) {
		args <- ._across_args(
			quo,
			call = call,
			hint = "Put several arguments in {.code list()}."
		)
		env <- quo_get_env(quo)
		return(list(
			cols = new_quosure(args$cols, env),
			input = new_quosure(args$fns, env)
		))
	}
	._abort_with_args_form(call, quo, name)
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
	is_input <- ._is_input_name(rhs) ||
		is_formula(rhs, lhs = TRUE) ||
		._is_formula_walrus(rhs) ||
		._is_input_call(rhs)
	cli_abort(
		c(
			"{.fn with_args} takes {.code cols ~ arg := value} formulas and {.fn across} calls.",
			x = if (!is.null(label)) "{.code {label}} isn't one of these.",
			x = if (!is.null(quo)) ._other_across_hint(list(quo)),
			i = if (is_input) "To choose an input, use {.fn with_filters}.",
			i = "One argument: {.code with_args(filters, x ~ value := range(.x))}.",
			i = "Several: {.code with_args(filters, x ~ list(value := range(.x), step = 5))}.",
			i = "Several columns: {.code with_args(filters, across(c(x, y), value := range(.x)))}."
		),
		call = call
	)
}

# Reading `:=` -------------------------------------------------------------

# `cols ~ <spec>`. R reads `left ~ arg := value` as `(left ~ arg) := value`, so
# a formula that ends in a `:=` argument arrives as a `:=` call.
._is_cols_formula <- function(quo) {
	expr <- quo_get_expr(quo)
	is_formula(expr, lhs = TRUE) || ._is_formula_walrus(expr)
}

._is_formula_walrus <- function(expr) {
	is_call(expr, ":=", n = 2) && is_formula(expr[[2]], lhs = TRUE)
}

# The columns a formula selects on its left, and what it gives them on its
# right, each as it was written. `cols ~ input ~ <args>` puts the input back
# in front of its arguments.
._formula_spec <- function(quo) {
	expr <- quo_get_expr(quo)
	env <- quo_get_env(quo)
	if (._is_formula_walrus(expr)) {
		left <- f_lhs(expr[[2]])
		right <- call2(":=", f_rhs(expr[[2]]), expr[[3]])
	} else {
		left <- f_lhs(expr)
		right <- f_rhs(expr)
	}
	if (is_formula(left, lhs = TRUE)) {
		right <- call2("~", f_rhs(left), right)
		left <- f_lhs(left)
	}
	list(cols = new_quosure(left, env), input = new_quosure(right, env))
}

# Reads a `:=` spec as it was written: the arguments it sets and, when it has
# one, the input they are for. `NULL` for any other code, which is evaluated
# instead. `list_is_args`: outside a formula or `across()`, `list()` is a
# column's data unless a `:=` marks it.
._read_spec <- function(expr, call, list_is_args = TRUE) {
	input <- NULL
	if (._is_formula_walrus(expr)) {
		# `input ~ arg := value`
		input <- list(f_lhs(expr[[2]]))
		args <- call2(":=", f_rhs(expr[[2]]), expr[[3]])
	} else if (is_formula(expr, lhs = TRUE)) {
		# `input ~ list(...)`
		input <- list(f_lhs(expr))
		args <- f_rhs(expr)
	} else if (._is_arg_walrus(expr)) {
		args <- expr
	} else if (is_call(expr, "list")) {
		if (!list_is_args && !._has_walrus(expr)) {
			return(NULL)
		}
		args <- expr
	} else if (._is_input_call(expr)) {
		# `fn(arg := value, ...)`
		input <- list(expr[[1]])
		args <- expr
		args[[1]] <- quote(list)
	} else {
		return(NULL)
	}
	arg_exprs <- ._arg_exprs(args)
	if (is.null(arg_exprs)) {
		label <- ._label(expr)
		cli_abort(
			c(
				"Can't read {.code {label}}.",
				i = if (!is.null(input)) {
					"An input is followed by its arguments: {.code input ~ arg := value}."
				},
				i = "Arguments are written {.code arg := value}, or {.code list(arg := value, ...)} for several."
			),
			call = call
		)
	}
	# `input` is in a list so an input written as `NULL` is still one.
	list(input = input, args = arg_exprs)
}

# A function called with `:=` arguments, such as `sliderInput(value := 1)`: an
# input and its arguments. The function is named by a symbol or `pkg::fn`, so a
# call such as `x[, y := 1]` stays the ordinary code it is. `list()` holds
# arguments; it isn't an input.
._is_input_call <- function(expr) {
	if (!is.call(expr) || is_call(expr, "list") || !._has_walrus(expr)) {
		return(FALSE)
	}
	head <- expr[[1]]
	if (is_call(head, c("::", ":::"))) {
		return(TRUE)
	}
	is_symbol(head) && make.names(as.character(head)) == as.character(head)
}

._has_walrus <- function(expr) {
	any(vapply(
		as.list(expr)[-1],
		function(arg) is_call(arg, ":="),
		logical(1)
	))
}

# The value expressions of `arg := value` or `list(...)`, named by argument, or
# `NULL` for anything else. In `list()`, `arg = value` works too; an element
# that is neither keeps an empty name.
._arg_exprs <- function(expr) {
	if (._is_arg_walrus(expr)) {
		els <- list(expr)
	} else if (is_call(expr, "list")) {
		els <- call_args(expr)
		# A trailing comma leaves an empty argument.
		els <- els[!vapply(els, is_missing, logical(1))]
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

# `col := value` is `col = value`, as rlang reads it, when the configuration
# has the column. Anything else needs its columns named first.
._name_walrus <- function(quos, config, call, fn) {
	nms <- names2(quos)
	for (i in which(nms == "")) {
		expr <- quo_get_expr(quos[[i]])
		if (!._is_arg_walrus(expr)) {
			next
		}
		name <- as.character(expr[[2]])
		if (!(name %in% names(config@data))) {
			label <- ._label(expr)
			cli_abort(
				c(
					"Can't find column {.field {name}}.",
					x = "{.code {label}} needs an existing column on its left.",
					i = "To set an argument, select columns: {.code {fn}(filters, cols ~ {label})}.",
					i = "To add a column, name it with {.code =}: {.code {fn}(filters, {name} = <expression>)}."
				),
				call = call
			)
		}
		quos[[i]] <- new_quosure(expr[[3]], quo_get_env(quos[[i]]))
		nms[[i]] <- name
	}
	names(quos) <- nms
	quos
}

# Overrides ------------------------------------------------------------------

# The override a `:=` spec gives a column: its arguments and, when it has one,
# its input.
._spec_override <- function(spec, env, config, call, fn) {
	override <- ._args_override(spec$args, env, config, call = call, fn = fn)
	if (!is.null(spec$input)) {
		input <- ._new_override(
			new_quosure(spec$input[[1]], env),
			call = call,
			fn = fn
		)
		override$input <- input$input
		override$label <- input$label
	}
	override
}

# An override that sets arguments and leaves the column's input as it is.
# `.update_fn` isn't an argument of the input: it names the function that
# updates it.
._args_override <- function(exprs, env, config, call, fn) {
	args <- ._capture_args(exprs, env, config@data, call = call, fn = fn)
	override <- list(input = NULL, args = args, fn = fn)
	if (".update_fn" %in% names(args)) {
		update <- args[[".update_fn"]]
		if (!is.function(update)) {
			cli_abort(
				"{.arg .update_fn} must be a function, not {.obj_type_friendly {update}}.",
				call = call
			)
		}
		override$update <- list(
			fn = update,
			label = ._fn_label(new_quosure(exprs[[".update_fn"]], env))
		)
		override$args <- args[names(args) != ".update_fn"]
	}
	override
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

# The name a function was written with: `fn` or `pkg::fn`. Anything else, such
# as an inline function, is `<custom>`.
._fn_label <- function(quo) {
	expr <- quo_get_expr(quo)
	if (is_symbol(expr) || is_call(expr, "::")) {
		return(as_label(expr))
	}
	"<custom>"
}

# Arguments when an input is created ------------------------------------------

# The name a column's arguments travel under in `...`, from `._config_input()`
# to `._call_input()`. No formal or `$` lookup on the way partial-matches it.
INPUT_ARGS <- ".shinyfilters_args"

# Returns the arguments set for one column. The data mask holds the
# configuration's columns, like `with_filters()`'s, plus `.x`.
._input_args <- function(args, config, name, call) {
	.data <- config@data
	.data$.x <- .data[[name]]
	lapply(set_names(nm = names(args)), function(arg) {
		value <- args[[arg]]
		if (!is_quosure(value)) {
			return(value)
		}
		try_fetch(
			eval_tidy(value, data = .data),
			error = function(cnd) {
				._resignal_silent(cnd)
				cli_abort(
					"Can't evaluate {.code {arg} = {as_label(value)}} for column {.field {name}}.",
					parent = cnd,
					call = call
				)
			}
		)
	})
}

# One string per argument, for `print()`: an argument that uses `.x` as it was
# written, the others as their value. Nothing is evaluated.
._format_input_args <- function(args) {
	vapply(
		args,
		function(arg) {
			if (is_quosure(arg)) as_label(arg) else ._format_arg(arg)
		},
		character(1)
	)
}

# The lines `print()` shows under a filter: its arguments, then the name of its
# update function.
._format_override_args <- function(override) {
	args <- ._format_input_args(override$args)
	if (!is.null(override$update)) {
		args[[".update_fn"]] <- override$update$label
	}
	args
}
