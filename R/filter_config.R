# R/filter_config.R
#
# Configure which input filterInput() creates for each column of a data.frame

# Function: shinyfilters() ####
#' Configure the Filters for a Data Frame
#'
#' `shinyfilters()` stores a data frame with the arguments used to create its
#' filters. Pass the result to [with_filter()] to choose the input for
#' individual columns, then place it in a shiny UI to create the inputs.
#'
#' The inputs are created when the page is rendered. Call [filterInput()] on
#' the result to create them right away. Apps that use bookmarking must do so
#' inside their UI function to restore bookmarked values; placing the result
#' in their UI directly is an error.
#'
#' @param data A data frame.
#' @param ... Named arguments passed to [filterInput()] for every column, such
#'   as `slider = TRUE` or `selectize = TRUE`.
#' @param ns An optional namespace created by [shiny::NS()].
#'
#' @returns A `shinyfilters` object:
#'
#'   * `names(filters)` lists its columns.
#'   * `filters$col` and `filters[["col"]]` return the input [filterInput()]
#'     creates for one column, including any [with_filter()] overrides.
#'   * `filters[cols]` returns a `shinyfilters` object with only the selected
#'     columns, keeping their overrides. `cols` uses
#'     <[`tidy-select`][tidyselect::language]>, like [with_filter()]; use
#'     `all_of()` to select with a variable.
#'
#' @seealso [with_filter()], [with_ns()]
#'
#' @examplesIf interactive()
#' filters <- shinyfilters(nyc_flights)
#' filters
#'
#' # Use sliders for every numeric column
#' filters <- shinyfilters(nyc_flights, slider = TRUE)
#' filterInput(filters)
#'
#' # The input for one column
#' filters$origin
#' @export
shinyfilters <- function(data, ..., ns = NULL) {
	if (!is.data.frame(data)) {
		cli_abort(
			"{.arg data} must be a data frame, not {.obj_type_friendly {data}}."
		)
	}
	if (nrow(data) == 0) {
		cli_abort("{.arg data} must have at least one row.")
	}
	if (!is.null(ns)) {
		._check_valid_shiny_ns(ns)
	}
	args <- list(...)
	if (length(args) > 0) {
		check_named_list_or_null(args, arg = "...")
	}
	class_shinyfilters(data = data, args = ._drop_flags_off(args), ns = ns)
}

# Drops input flags set to `FALSE`, their default
._drop_flags_off <- function(args) {
	is_flag <- names(args) %in% names(INPUT_KEYWORDS)
	is_off <- vapply(args, isFALSE, logical(1))
	args[!(is_flag & is_off)]
}

## Method: filterInput() ####
method(filterInput, class_shinyfilters) <- function(x, ...) {
	call <- caller_env()
	args <- ._config_args(x, ...)
	data <- x@data
	do.call(
		tagList,
		mapply(
			._config_input,
			names(data),
			get_input_ids(data),
			get_input_labels(data),
			MoreArgs = list(config = x, args = args, call = call),
			SIMPLIFY = FALSE
		)
	)
}

._config_args <- function(config, ...) {
	modifyList(c(config@args, list(ns = config@ns)), list(...))
}

# Creates the input for one column of a shinyfilters config
._config_input <- function(name, id, label, config, args, call) {
	col <- config@data[[name]]
	if (all(is.na(col))) {
		cli_abort(
			"Column {.field {name}} must have at least one non-missing value.",
			call = call
		)
	}
	col_args <- c(
		list(x = col),
		do.call(._id_label_args, c(list(col, id, label), args)),
		args
	)
	override <- config@overrides[[name]]
	if (is.null(override)) {
		return(do.call(filterInput, col_args))
	}
	# `print()`'s dry run never evaluates `as_filter()` arguments.
	if (!the$dry_run && length(override$args) > 0) {
		col_args[[INPUT_ARGS]] <- ._input_args(override$args, config, name, call)
	}
	# An `as_filter()` without an input leaves the choice to `filterInput()`.
	try_fetch(
		if (is.null(override$input)) {
			do.call(filterInput, col_args)
		} else {
			do.call(
				filter_input_override,
				c(col_args, list(override = override$input))
			)
		},
		error = function(cnd) {
			._resignal_silent(cnd)
			cli_abort(
				"Can't create an input for column {.field {name}}.",
				parent = cnd,
				call = call
			)
		}
	)
}

# shiny recognizes the errors `req()` and `validate()` signal by their class,
# so they are re-signaled as they are instead of being wrapped.
._resignal_silent <- function(cnd) {
	if (inherits(cnd, "shiny.silent.error")) {
		stop(cnd)
	}
}

## Methods: $, [[, [, names(), .DollarNames() ####
`$.shinyfilters::shinyfilters` <- function(x, name) {
	._config_column(x, name, call = call("$", substitute(x), as.name(name)))
}

`[[.shinyfilters::shinyfilters` <- function(x, i, ...) {
	._config_column(x, i, call = call("[[", substitute(x), substitute(i)))
}

`.DollarNames.shinyfilters::shinyfilters` <- function(x, pattern = "") {
	grep(pattern, names(x), value = TRUE)
}

`names.shinyfilters::shinyfilters` <- function(x) {
	names(x@data)
}

`[.shinyfilters::shinyfilters` <- function(x, i, ...) {
	call <- sys.call()
	call[[1]] <- as.name("[")
	if (nargs() > 2) {
		cli_abort(
			c(
				"Can't subset a {.cls shinyfilters} object by rows and columns.",
				i = "Select columns with {.code x[cols]}."
			),
			call = call
		)
	}
	if (missing(i)) {
		return(x)
	}
	selection <- new_quosure(substitute(i), parent.frame())
	._select_columns(x, selection, as_label(selection), call)
}

# Shared by `[` and dplyr's `select()`. Each passes the user's selection and
# its own call and label, so errors name the code the user wrote.
._select_columns <- function(x, selection, label, call) {
	cols <- try_fetch(
		names(eval_select(
			selection,
			x@data,
			allow_rename = FALSE,
			error_call = call
		)),
		vctrs_error_subscript = function(cnd) {
			cnd$call <- call
			stop(cnd)
		}
	)
	if (length(cols) == 0) {
		cli_abort("{.code {label}} doesn't select any columns.", call = call)
	}
	added <- x@added[intersect(names(x@added), cols)]
	replaced <- x@replaced[intersect(names(x@replaced), cols)]
	set_props(
		x,
		data = x@data[cols],
		overrides = x@overrides[intersect(names(x@overrides), cols)],
		added = if (length(added) > 0) added else character(),
		replaced = if (length(replaced) > 0) replaced else character()
	)
}

# Creates the input for one column, selected by name or position
._config_column <- function(config, col, call) {
	nms <- names(config@data)
	if (length(col) != 1) {
		cli_abort(
			"Select a single column, not {length(col)} value{?s}.",
			call = call
		)
	}
	if (is.numeric(col) && col %in% seq_along(nms)) {
		col <- nms[[col]]
	}
	if (!is.character(col) || !(col %in% nms)) {
		cli_abort("Can't find column {.field {col}}.", call = call)
	}
	i <- match(col, nms)
	._config_input(
		col,
		get_input_ids(config@data)[[i]],
		get_input_labels(config@data)[[i]],
		config,
		._config_args(config),
		call
	)
}

## Method: print() ####
`print.shinyfilters::shinyfilters` <- function(x, ...) {
	data <- x@data
	nms <- names(data)
	# `as_filter()` arguments alone don't choose the input, or mark the row.
	overridden <- vapply(
		nms,
		function(nm) !is.null(x@overrides[[nm]]$input),
		logical(1)
	)
	added <- nms %in% names(x@added)
	replaced <- nms %in% names(x@replaced)

	n_filters <- ncol(data)
	header <- format_inline("{n_filters} filter{?s}")
	if (!is.null(x@ns)) {
		ns <- ._resolve_ns(x@ns)
		header <- paste(
			col_br_white(header),
			col_grey(symbol$bullet),
			col_grey("namespace"),
			paste0(
				col_blue("\""),
				ansi_strtrim(
					col_blue(format_inline("{ns(character())}")),
					22
				),
				col_blue("\"")
			)
		)
	}
	cat_line(paste(
		col_magenta("<shinyfilters>"),
		col_grey(symbol$bullet),
		header
	))

	cat_line()
	cat_line(col_grey("Filters"))
	inputs <- ._dry_run_inputs(x)
	is_error <- startsWith(inputs, symbol$cross)
	width <- max(0L, ansi_nchar(inputs[!is_error], type = "width"))
	styled_inputs <- ifelse(
		is_error,
		col_red(inputs),
		col_cyan(ansi_align(inputs, width))
	)
	dot <- if (is_utf8_output()) "\u25cf" else "*"
	dot_input <- col_blue(dot)
	# ASCII in every locale: wider glyphs break the marker column.
	dot_added <- col_green("+")
	dot_replaced <- col_yellow("~")
	circle <- if (is_utf8_output()) "\u25cb" else "#"
	dot_default <- col_grey(circle)

	# One marker per row: where the column came from wins over whatever decided
	# the input.
	overridden <- overridden & !added & !replaced
	defaulted <- !overridden &
		!added &
		!replaced &
		!is_error &
		._set_by_default(x, inputs)
	marked <- overridden | defaulted | added | replaced
	# Unmarked rows keep the marker column's width, so the columns line up. A
	# print with no marked row has no marker column.
	marker <- if (any(marked)) {
		paste0(
			"  ",
			ifelse(overridden, dot_input, ""),
			ifelse(defaulted, dot_default, ""),
			ifelse(added, dot_added, ""),
			ifelse(replaced, dot_replaced, ""),
			ifelse(marked, "", " ")
		)
	} else {
		""
	}
	types <- vapply(data, ._type_abbr, character(1))
	lines <- paste0(
		marker,
		"  ",
		._pad(ansi_strtrim(nms, 25)),
		"  ",
		col_grey(._pad(types)),
		"  ",
		styled_inputs
	)
	# `as_filter()` arguments follow their filter's row, under its input.
	indent <- strrep(
		" ",
		ansi_nchar(marker[[1]], type = "width") +
			min(25, max(ansi_nchar(nms, type = "width"))) +
			min(25, max(ansi_nchar(types, type = "width"))) +
			8
	)
	arg_lines <- lapply(nms, function(nm) {
		args <- ._format_input_args(x@overrides[[nm]]$args)
		if (length(args) == 0) {
			return(character())
		}
		paste0(
			indent,
			._pad(ansi_strtrim(
				names(args),
				max(36, console_width() - nchar(indent))
			)),
			col_grey(" = "),
			ansi_strtrim(col_blue(args), max(36, console_width() - nchar(indent)))
		)
	})
	lines <- Map(c, sub("\\s+$", "", lines), arg_lines)
	cat_line(unlist(lines, use.names = FALSE))

	cat_line()
	if (length(x@args) > 0) {
		values <- vapply(x@args, ._format_arg, character(1))
		cat_line(col_grey("Default Overrides"))
		cat_line(paste0(
			"  ",
			._pad(ansi_strtrim(names(values), 25)),
			col_grey(" = "),
			ansi_strtrim(col_blue(values), 25)
		))
	}

	if (any(marked)) {
		cat_line()
	}
	if (any(defaulted)) {
		cat_line(dot_default, col_grey(" Filter set by default argument"))
	}
	if (any(overridden)) {
		fns <- vapply(x@overrides[nms[overridden]], function(o) o$fn, "")
		fns <- sort(unique(fns))
		cat_line(
			dot_input,
			col_grey(format_inline(" Filter set by {.or {.fn {fns}}}"))
		)
	}
	if (any(added)) {
		fns <- sort(unique(unname(x@added[nms[added]])))
		cat_line(
			dot_added,
			col_grey(format_inline(" Filter added by {.or {.fn {fns}}}"))
		)
	}
	if (any(replaced)) {
		fns <- sort(unique(unname(x@replaced[nms[replaced]])))
		cat_line(
			dot_replaced,
			col_grey(format_inline(" Filter replaced by {.or {.fn {fns}}}"))
		)
	}
	invisible(x)
}

# Columns whose input differs from the one they get without the default
# overrides
._set_by_default <- function(config, inputs) {
	if (length(config@args) == 0) {
		return(rep(FALSE, length(inputs)))
	}
	inputs != ._dry_run_inputs(set_props(config, args = list()))
}

._pad <- function(x) {
	ansi_align(x, max(ansi_nchar(x, type = "width")))
}

._format_arg <- function(value) {
	out <- paste(deparse(value, width.cutoff = 500L), collapse = " ")
	if (nchar(out) > 30) {
		out <- paste0(substr(out, 1, 29), symbol$ellipsis)
	}
	out
}

._type_abbr <- function(x) {
	type <- if (is.factor(x)) {
		"fct"
	} else if (inherits(x, "Date")) {
		"date"
	} else if (inherits(x, "POSIXt")) {
		"dttm"
	} else {
		switch(
			typeof(x),
			integer = "int",
			double = "dbl",
			character = "chr",
			logical = "lgl",
			list = "list",
			class(x)[[1]]
		)
	}
	paste0("<", type, ">")
}

# Dry run of dispatch -------------------------------------------------------
#
# While `the$dry_run` is TRUE, the input callers return the input function
# instead of calling it, so print() can show which input each column uses.
the <- new.env(parent = emptyenv())
the$dry_run <- FALSE

._dry_run_result <- function(.f) {
	the$dry_run_fn <- .f
	structure(list(fn = .f), class = "shinyfilters_dry_run")
}

._dry_run_inputs <- function(config) {
	vapply(._dry_run(config), ._dry_run_label, character(1))
}

# One result per column: the input `._call_input()` was asked to call, or the
# error that kept `filterInput()` from getting that far.
._dry_run <- function(config, cols = names(config@data)) {
	the$dry_run <- TRUE
	on.exit({
		assign("dry_run", FALSE, envir = the)
		assign("dry_run_fn", NULL, envir = the)
	})

	data <- config@data
	args <- ._config_args(config)
	i <- match(cols, names(data))
	mapply(
		function(name, id, label) {
			the$dry_run_fn <- NULL
			res <- tryCatch(
				._config_input(name, id, label, config, args, call = NULL),
				error = identity
			)
			# A method that post-processes the dry-run result errors after the
			# input is known; report the input rather than that error. Trade-off:
			# a genuine error raised after the input is chosen is hidden here and
			# only surfaces from filterInput().
			if (inherits(res, "error") && !is.null(the$dry_run_fn)) {
				res <- ._dry_run_result(the$dry_run_fn)
			}
			res
		},
		cols,
		get_input_ids(data)[i],
		get_input_labels(data)[i],
		SIMPLIFY = FALSE,
		USE.NAMES = FALSE
	)
}

._dry_run_label <- function(res) {
	if (inherits(res, "error")) {
		while (inherits(res$parent, "error")) {
			res <- res$parent
		}
		message <- strsplit(conditionMessage(res), "\n", fixed = TRUE)[[1]][[1]]
		return(paste(symbol$cross, ansi_strip(message)))
	}
	if (!inherits(res, "shinyfilters_dry_run")) {
		return("<custom>")
	}
	._input_name(res$fn)
}

# The name of a shiny input function, or `<custom>` for any other function
._input_name <- function(fn) {
	for (name in names(SHINY_INPUTS)) {
		if (identical(fn, SHINY_INPUTS[[name]])) {
			return(name)
		}
	}
	"<custom>"
}

._is_shiny_input <- function(fn) {
	any(vapply(SHINY_INPUTS, identical, logical(1), fn))
}

SHINY_INPUTS <- list(
	dateInput = dateInput,
	dateRangeInput = dateRangeInput,
	numericInput = numericInput,
	radioButtons = radioButtons,
	selectInput = selectInput,
	selectizeInput = selectizeInput,
	sliderInput = sliderInput,
	textAreaInput = textAreaInput,
	textInput = textInput
)

# Function: with_filter() ####
#' Choose the Input for Columns
#'
#' `with_filter()` sets the input that [filterInput()] creates for one or more
#' columns of a configuration made by [shinyfilters()], and adds or replaces
#' columns computed from the others. When a column's input is chosen more than
#' once, the last one wins; its [as_filter()] arguments stay with the column.
#'
#' @param .config A configuration created by [shinyfilters()].
#' @param ... Either two unnamed arguments, or any number of named arguments,
#'   formulas, and [across_filters()] calls:
#'
#'   * `with_filter(.config, cols, input)`: `cols` selects columns with
#'     <[`tidy-select`][tidyselect::language]>, such as `cyl`,
#'     `c(mpg, disp)`, or `where(is.numeric)`.
#'   * `with_filter(.config, col = input, ...)`: each name is a column.
#'   * `with_filter(.config, col = expression, ...)`: adds or replaces a
#'     column, computed from the other columns. A replaced column keeps its
#'     input. A function, a single string, or an [as_filter()] object is
#'     always read as an input; any other value is the column's data. A column
#'     takes precedence over a variable of the same name.
#'   * `with_filter(.config, cols ~ input, ...)`: a two-sided formula selects
#'     columns on its left, like `cols` above, and names one input for all of
#'     them on its right. It can be mixed with named columns.
#'   * `with_filter(.config, across_filters(cols, input), ...)`:
#'     [across_filters()] does the same as a formula.
#'
#'   Each input is either a keyword (`"area"`, `"radio"`, `"range"`,
#'   `"selectize"`, `"slider"`, `"textbox"`) or a \pkg{shiny} input function,
#'   such as [shiny::radioButtons()]. `"radio"` and `"selectize"` also work
#'   with numeric columns, using the sorted unique values as choices.
#'
#'   Other functions are called like [call_filter_input()]: they receive the
#'   arguments [args_filter_input()] returns for the column's type, plus any
#'   other arguments they accept.
#'
#'   Wrap an input in [as_filter()] to set its arguments, or use [as_filter()]
#'   without an input to set arguments for the input a column already has.
#'   Arguments stay with the column: an input chosen later keeps the ones it
#'   has an argument for.
#'
#' @returns The updated configuration.
#'
#' @seealso [shinyfilters()], [across_filters()], [as_filter()]
#'
#' @examples
#' filters <- shinyfilters(nyc_flights)
#' filters <- with_filter(filters, origin = "radio", carrier = "selectize")
#' filters
#'
#' # Choose one input for several columns with tidyselect
#' filters <- with_filter(filters, where(is.numeric), "slider")
#' filterInput(filters)
#'
#' # Or select columns and name others in one call
#' with_filter(
#'   filters,
#'   where(is.character) ~ "selectize",
#'   origin = "radio"
#' )
#'
#' # Add a column computed from the others
#' with_filter(filters, delay_sq = dep_delay^2)
#' @export
with_filter <- function(.config, ...) {
	if (!S7_inherits(.config, class_shinyfilters)) {
		cli_abort(
			"{.arg .config} must be created by {.fn shinyfilters}, not {.obj_type_friendly {(.config)}}."
		)
	}
	if (...length() == 0) {
		._abort_with_filter_form(list(), call = current_env())
	}
	.with_filter(.config, ..., .call = current_env())
}

# `.config`, not `config`: a column named `c` or `con` in `...` would
# partial-match it.
.with_filter <- new_generic(".with_filter", ".config")

# `.across` names the calls that select columns and name one input for all of
# them. `with_filter()` takes `across_filters()`; `mutate()` also takes
# `across()`, which is unambiguous there.
method(.with_filter, class_shinyfilters) <- function(
	.config,
	...,
	.call = caller_env(),
	.across = SHINYFILTERS_ACROSS,
	.fn = "with_filter"
) {
	config <- .config
	quos <- enquos(...)
	nms <- names2(quos)
	named <- nms != ""
	is_across <- vapply(
		quos,
		function(quo) {
			._is_across_call(quo_get_expr(quo), .across)
		},
		logical(1)
	)
	is_formula <- !named & vapply(quos, ._is_cols_formula, logical(1))

	if (any(is_across & named)) {
		i <- which(is_across & named)[[1]]
		._abort_across_named(quos[[i]], nms[[i]], call = .call)
	}

	if (!any(is_across | is_formula) && length(quos) == 2 && !any(named)) {
		return(._override_cols(
			config,
			quos[[1]],
			quos[[2]],
			call = .call,
			fn = .fn
		))
	}

	loose <- !named & !is_across & !is_formula
	if (any(loose)) {
		._abort_with_filter_form(quos[loose], call = .call)
	}

	# One argument at a time, so each sees the columns the earlier ones computed.
	for (i in seq_along(quos)) {
		if (is_across[[i]] || is_formula[[i]]) {
			spec <- if (is_formula[[i]]) {
				._formula_spec(quos[[i]])
			} else {
				._across_spec(quos[[i]], call = .call)
			}
			config <- ._override_cols(
				config,
				spec$cols,
				spec$input,
				call = .call,
				fn = .fn
			)
		} else {
			config <- ._set_column(
				config,
				nms[[i]],
				quos[[i]],
				call = .call,
				fn = .fn
			)
		}
	}

	config
}

# `cols ~ input`: the left side selects columns, the right side is their input.
._is_cols_formula <- function(quo) {
	is_formula(quo_get_expr(quo), lhs = TRUE)
}

._formula_spec <- function(quo) {
	expr <- quo_get_expr(quo)
	env <- quo_get_env(quo)
	list(
		cols = new_quosure(f_lhs(expr), env),
		input = new_quosure(f_rhs(expr), env)
	)
}

# Reached only from `with_filter()`: `mutate()` checks its own argument shapes
# before forwarding, so its wording never has to appear here.
._abort_with_filter_form <- function(quos, call) {
	msg <- c(
		"{.fn with_filter} takes two unnamed arguments, or named arguments, {.code cols ~ input} formulas, and {.fn across_filters} calls.",
		i = "Select columns: {.code with_filter(filters, c(a, b), \"radio\")}.",
		i = "Name columns: {.code with_filter(filters, a = \"radio\", b = \"slider\")}.",
		i = "Mix the two: {.code with_filter(filters, c(a, b) ~ \"radio\", x = \"slider\")}."
	)
	used_across <- vapply(
		quos,
		function(quo) is_call(quo_get_expr(quo), "across"),
		logical(1)
	)
	if (any(used_across)) {
		msg <- c(
			msg,
			i = "{.fn across} works only inside {.fn mutate}; use {.fn across_filters} here."
		)
	}
	cli_abort(msg, call = call)
}

._override_cols <- function(config, cols, input, call, fn) {
	selected <- names(eval_select(
		cols,
		config@data,
		allow_rename = FALSE,
		error_call = call
	))
	if (length(selected) == 0) {
		cli_abort(
			"{.code {as_label(cols)}} doesn't select any columns.",
			call = call
		)
	}
	override <- ._new_override(input, call = call, fn = fn)
	overrides <- rep(list(override), length(selected))
	names(overrides) <- selected
	._set_overrides(config, overrides)
}

# A function, a single string, or an `as_filter()` object chooses the column's
# input; any other value is the column's data, computed from the other columns.
._set_column <- function(config, name, quo, call, fn) {
	label <- as_label(quo)
	data <- config@data
	value <- try_fetch(
		eval_tidy(quo, data = data),
		error = function(cnd) {
			cli_abort(
				c(
					"Can't evaluate {.code {name} = {label}}.",
					i = if (is_symbol(quo_get_expr(quo))) {
						"Keywords are strings, e.g. {.code \"radio\"}."
					}
				),
				parent = cnd,
				call = call
			)
		}
	)

	if (is.function(value) || is_string(value) || ._is_filter(value)) {
		if (!(name %in% names(data))) {
			cli_abort(
				c(
					"Can't find column {.field {name}}.",
					x = if (._is_filter(value) && is.null(value$input)) {
						"{.code {label}} sets arguments for an existing column's input."
					} else {
						"{.code {label}} chooses the input for an existing column."
					},
					i = "To add a column, compute it from the others: {.code {fn}(filters, {name} = <expression>)}."
				),
				call = call
			)
		}
		override <- ._override(value, call = call, fn = fn)
		return(._set_overrides(config, set_names(list(override), name)))
	}

	n <- nrow(data)
	if (!is_vector(value) || is.data.frame(value)) {
		cli_abort(
			"Column {.field {name}} must be a vector, not {.obj_type_friendly {value}}.",
			call = call
		)
	}
	if (!(length(value) %in% c(1L, n))) {
		cli_abort(
			"Column {.field {name}} must have 1 or {n} value{?s}, not {length(value)}.",
			call = call
		)
	}
	added <- config@added
	replaced <- config@replaced
	value <- if (length(value) == 1) rep(value, n) else value
	if (!(name %in% names(data))) {
		added[[name]] <- fn
	} else if (!(name %in% names(added)) && !identical(value, data[[name]])) {
		# An unchanged column, e.g. `x = x`, isn't a replacement.
		replaced[[name]] <- fn
	}
	data[[name]] <- value
	set_props(config, data = data, added = added, replaced = replaced)
}

._set_overrides <- function(config, overrides) {
	overrides_all <- config@overrides
	for (name in names(overrides)) {
		overrides_all[[name]] <- ._merge_override(config, name, overrides[[name]])
	}
	set_props(config, overrides = overrides_all)
}

# `as_filter()` arguments stay with their column: a new input keeps the ones it
# names, and the override's own arguments are added to them. An override
# without an input, from `as_filter()`, keeps the column's input.
._merge_override <- function(config, name, override) {
	old <- config@overrides[[name]]
	input <- override$input
	fn <- override$fn
	args <- old$args
	if (is.null(input) && !is.null(old)) {
		input <- old$input
		fn <- old$fn
	} else if (length(args) > 0) {
		named <- ._override_arg_names(config, name, override)
		if (!is.null(named)) {
			args <- args[names(args) %in% named]
		}
	}
	args[names(override$args)] <- override$args
	out <- list(input = input, args = args, fn = fn)
	if (length(args) == 0) {
		out$args <- NULL
	}
	out
}

# The arguments named by the input an override gives a column, or `NULL` when
# it may take any: a dry run can't tell which input it is, or it is a function
# with `...`. shiny's inputs don't count: they check their `...`, or pass them
# to an input whose arguments `._input_arg_names()` already includes.
._override_arg_names <- function(config, name, override) {
	overrides <- config@overrides
	overrides[[name]] <- override[c("input", "fn")]
	res <- ._dry_run(set_props(config, overrides = overrides), name)[[1]]
	if (!inherits(res, "shinyfilters_dry_run")) {
		return(NULL)
	}
	named <- ._input_arg_names(res$fn)
	if ("..." %in% named && !._is_shiny_input(res$fn)) {
		return(NULL)
	}
	named
}

._new_override <- function(quo, call, fn) {
	label <- as_label(quo)
	input <- try_fetch(
		eval_tidy(quo),
		error = function(cnd) {
			cli_abort(
				c(
					"Can't evaluate the input {.code {label}}.",
					i = if (is_symbol(quo_get_expr(quo))) {
						"Keywords are strings, e.g. {.code \"radio\"}."
					}
				),
				parent = cnd,
				call = call
			)
		}
	)
	._override(input, call = call, fn = fn)
}

# An `as_filter()` object has already resolved its input. Its arguments are
# stored only when it has some, so `as_filter("slider")` equals `"slider"`.
._override <- function(input, call, fn) {
	if (!._is_filter(input)) {
		return(list(input = resolve_filter_override(input, call = call), fn = fn))
	}
	if (length(input$args) == 0) {
		return(list(input = input$input, fn = fn))
	}
	list(input = input$input, args = input$args, fn = fn)
}

# Function: with_ns() ####
#' Change the Namespace of a Configuration
#'
#' `with_ns()` adds, replaces, or removes the namespace that a configuration
#' made by [shinyfilters()] applies to its input ids. Use it to build a
#' configuration once and reuse it in several modules.
#'
#' Inside [dplyr::mutate()], call it without the configuration:
#' `mutate(filters, with_ns("id"))`.
#'
#' @param .config A configuration created by [shinyfilters()].
#' @param ns The namespace: a string, used as the id passed to [shiny::NS()];
#'   a namespace created by [shiny::NS()]; or `NULL` to remove the namespace.
#'
#' @returns The updated configuration.
#'
#' @seealso [shinyfilters()]
#'
#' @examples
#' filters <- shinyfilters(nyc_flights)
#'
#' # Add a namespace
#' filters <- with_ns(filters, "flights")
#' filters
#'
#' # Replace it, here with a namespace created by NS()
#' with_ns(filters, shiny::NS("departures"))
#'
#' # Remove it
#' with_ns(filters, NULL)
#' @export
with_ns <- function(.config, ns) {
	if (missing(ns)) {
		cli_abort(
			"{.arg ns} must be supplied. Use {.code NULL} to remove the namespace."
		)
	}
	if (!S7_inherits(.config, class_shinyfilters)) {
		cli_abort(c(
			"{.arg .config} must be a {.cls shinyfilters} object, not {.obj_type_friendly {(.config)}}.",
			"i" = "Usage: {.code {caller_arg(.config)} |> shinyfilters() |> with_ns({caller_arg(ns)})}"
		))
	}
	if (is.function(ns)) {
		._check_valid_shiny_ns(ns)
	}
	set_props(.config, ns = ns)
}

# Function: with_defaults() ####
#' Change the Default Arguments of a Configuration
#'
#' `with_defaults()` adds, replaces, or removes the arguments that a
#' configuration made by [shinyfilters()] passes to [filterInput()] for every
#' column.
#'
#' @param .config A configuration created by [shinyfilters()].
#' @param ... Named arguments passed to [filterInput()] for every column, such
#'   as `slider = TRUE` or `selectize = TRUE`. An argument set to `NULL`, or
#'   an input flag such as `slider` set to `FALSE`, its default, is removed.
#'   Arguments not named here keep their current values.
#'
#' @returns The updated configuration.
#'
#' @seealso [shinyfilters()], [with_filter()], [with_ns()]
#'
#' @examples
#' filters <- shinyfilters(nyc_flights, slider = TRUE, width = "200px")
#'
#' # Add a default
#' filters <- with_defaults(filters, range = TRUE)
#' filters
#'
#' # Replace one
#' with_defaults(filters, width = "100%")
#'
#' # Remove one, with `NULL` or its default value
#' with_defaults(filters, slider = NULL)
#' with_defaults(filters, range = FALSE)
#' @export
with_defaults <- function(.config, ...) {
	if (!S7_inherits(.config, class_shinyfilters)) {
		cli_abort(c(
			"{.arg .config} must be a {.cls shinyfilters} object, not {.obj_type_friendly {(.config)}}.",
			"i" = "Usage: {.code {caller_arg(.config)} |> shinyfilters() |> with_defaults(...)}"
		))
	}
	args <- list(...)
	if (length(args) > 0) {
		check_named_list_or_null(args, arg = "...")
	}
	if ("ns" %in% names(args)) {
		cli_abort(c(
			"{.arg ns} isn't a default argument.",
			"i" = "Use {.fn with_ns} to change the namespace."
		))
	}
	# Not `modifyList()`: it merges list values instead of replacing them.
	defaults <- .config@args
	for (name in names(args)) {
		defaults[[name]] <- args[[name]]
	}
	defaults <- ._drop_flags_off(defaults)
	set_props(.config, args = if (length(defaults) > 0) defaults else list())
}

# Generic: resolve_filter_override() ####
resolve_filter_override <- new_generic("resolve_filter_override", "input")

method(resolve_filter_override, class_character) <- function(
	input,
	...,
	call = caller_env()
) {
	keywords <- names(INPUT_KEYWORDS)
	if (length(input) != 1 || !(input %in% keywords)) {
		cli_abort(
			c(
				"An input must be one of {.or {.val {keywords}}}, or a function.",
				x = "Got {.val {input}}."
			),
			call = call
		)
	}
	input_keyword(input)
}

method(resolve_filter_override, class_function) <- function(input, ...) {
	for (keyword in names(INPUT_KEYWORDS)) {
		if (identical(input, INPUT_KEYWORDS[[keyword]]$fn)) {
			return(input_keyword(keyword))
		}
	}
	input
}

method(resolve_filter_override, class_any) <- function(
	input,
	...,
	call = caller_env()
) {
	cli_abort(
		"An input must be a keyword or a function, not {.obj_type_friendly {input}}.",
		call = call
	)
}

# Generic: filter_input_override() ####
filter_input_override <- new_generic(
	"filter_input_override",
	c("x", "override"),
	fun = function(x, override, ...) {
		args <- list(...)
		if (!is.null(args$ns)) {
			args <- do.call(._apply_ns, c(list(x = x), args))
			return(do.call(
				filter_input_override,
				c(args, list(override = override))
			))
		}
		S7_dispatch()
	}
)

## Keyword flags supported by filterInput() ####
._filter_input_keyword <- function(x, override, ...) {
	flags_off <- set_names(
		rep(list(FALSE), length(INPUT_KEYWORDS)),
		names(INPUT_KEYWORDS)
	)
	flags <- modifyList(flags_off, INPUT_KEYWORDS[[unclass(override)]]$args)
	args <- modifyList(list(...), flags)
	do.call(filterInput, c(list(x = x), args))
}

method(
	filter_input_override,
	list(
		class_character,
		class_input_area |
			class_input_radio |
			class_input_selectize |
			class_input_textbox
	)
) <- ._filter_input_keyword

method(
	filter_input_override,
	list(
		class_factor | class_logical | class_list,
		class_input_radio | class_input_selectize
	)
) <- ._filter_input_keyword

method(
	filter_input_override,
	list(class_numeric, class_input_slider)
) <- ._filter_input_keyword

method(
	filter_input_override,
	list(class_Date | class_POSIXt, class_input_range)
) <- ._filter_input_keyword

## Numeric discrete choices ####
method(
	filter_input_override,
	list(class_numeric, class_input_radio | class_input_selectize)
) <- function(x, override, ...) {
	args <- list(...)
	choices <- ._discrete_choice_inputs(
		x,
		choices_asis = isTRUE(args$choices_asis),
		args_unique = args$args_unique,
		args_sort = args$args_sort,
		server = args$server
	)
	._call_input(INPUT_KEYWORDS[[unclass(override)]]$fn, choices, ...)
}

## Function ####
method(
	filter_input_override,
	list(class_any, class_function)
) <- function(x, override, ...) {
	._call_filter_input(x, override, ...)
}

## Unsupported keyword ####
method(
	filter_input_override,
	list(class_any, class_input_keyword)
) <- function(x, override, ...) {
	keyword <- unclass(override)
	supported <- ._supported_keywords(x)
	cli_abort(
		c(
			"{.val {keyword}} isn't available for {.cls {class(x)[[1]]}} columns.",
			i = if (length(supported) > 0) {
				"Use {.or {.val {supported}}} instead."
			}
		),
		class = "shinyfilters_error_unsupported_input",
		call = NULL
	)
}

._supported_keywords <- function(x) {
	fallback <- method(
		filter_input_override,
		list(class_any, class_input_keyword)
	)
	keywords <- names(INPUT_KEYWORDS)
	is_supported <- vapply(
		keywords,
		function(keyword) {
			found <- method(
				filter_input_override,
				object = list(x, input_keyword(keyword))
			)
			!identical(found, fallback)
		},
		logical(1)
	)
	keywords[is_supported]
}
