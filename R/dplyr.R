# R/dplyr.R
#
# dplyr verbs and coercion methods for shinyfilters objects

#' Choose Inputs with dplyr Verbs
#'
#' [dplyr::mutate()] sets the input [filterInput()] creates for a column of a
#' configuration made by [shinyfilters()], like [with_filters()] does, and
#' adds or replaces columns computed from the others.
#' [dplyr::select()] keeps only the selected columns, and [dplyr::pull()]
#' returns one column's input.
#'
#' @param .data A configuration created by [shinyfilters()].
#' @param ... For `mutate()`, named arguments, `cols ~ input` formulas, calls
#'   to [dplyr::across()], or a call to [with_ns()]:
#'
#'   * `mutate(filters, col = input)`: each name is a column.
#'   * `mutate(filters, col = expression)`: adds or replaces a column, like
#'     [dplyr::mutate()] does for a data frame. A replaced column keeps its
#'     input.
#'   * `mutate(filters, across(cols, input))` or
#'     `mutate(filters, cols ~ input)`: `cols` selects columns with
#'     <[`tidy-select`][tidyselect::language]>.
#'
#'   `mutate(filters, with_ns(ns))` changes the namespace, like [with_ns()]
#'   does, and can be mixed with the other forms.
#'
#'   Each input is a keyword or a shiny input function, as described in
#'   [with_filters()]. Either is always read as an input; any other value is
#'   the column's data.
#'
#'   `arg := value` sets an input's arguments, as in [with_filters()]:
#'   `mutate(filters, cols ~ arg := value)` or
#'   `mutate(filters, col = sliderInput(arg := value))`. `col := value` is
#'   `col = value` when `col` is a column.
#'
#'   For `select()`, the columns to keep, using
#'   <[`tidy-select`][tidyselect::language]>.
#'
#' @returns The updated configuration.
#'
#' @seealso [with_filters()]
#'
#' @name shinyfilters-dplyr
#' @examplesIf rlang::is_installed("dplyr")
#' library(dplyr)
#'
#' filters <- shinyfilters(nyc_flights)
#'
#' # Name each column
#' mutate(filters, origin = "radio", carrier = "selectize")
#'
#' # Or choose one input for several columns
#' mutate(filters, across(where(is.numeric), "slider"))
#'
#' # Add a column computed from the others
#' mutate(filters, distance_km = distance * 1.609)
#'
#' # Keep only some columns
#' select(filters, origin, carrier)
NULL

`select.shinyfilters::shinyfilters` <- function(.data, ...) {
	call <- sys.call()
	call[[1]] <- as.name("select")
	quos <- enquos(...)
	if (length(quos) == 0) {
		cli_abort(
			c(
				"{.fn select} must select at least one column.",
				i = "Select columns: {.code select(filters, a, b)}."
			),
			call = call
		)
	}
	exprs <- lapply(quos, quo_get_expr)
	selection <- quo(c(!!!quos))
	label <- paste(vapply(exprs, as_label, ""), collapse = ", ")
	._select_columns(.data, selection, label, call)
}

`pull.shinyfilters::shinyfilters` <- function(
	.data,
	var = -1,
	name = NULL,
	...
) {
	if (!is.null(name)) {
		cli_abort(
			"{.arg name} is not supported for {.cls shinyfilters} objects."
		)
	}
	var <- vars_pull(names(.data), !!enquo(var))
	# `all_of()`: `[[` would read a bare `var` as the column of that name.
	.data[[all_of(var)]]
}

# `.keep_used` is `transmute()`: only the columns the arguments name or select
# are kept, in the order they first appear.
._mutate_impl <- function(.data, ..., .fn, .call, .keep_used = FALSE) {
	fn <- .fn
	# `:=` is read here, not by rlang: it sets an argument.
	quos <- enquos(..., .unquote_names = FALSE)
	quos <- ._name_walrus(quos, .data, call = .call, fn = fn)
	nms <- names2(quos)

	reserved <- intersect(nms, c(".by", ".keep", ".before", ".after"))
	if (length(reserved) > 0) {
		cli_abort(
			c(
				"{.fn {fn}} doesn't support {.arg {reserved}} for a {.cls shinyfilters} object.",
				i = "It chooses inputs and computes columns; it doesn't drop or move them."
			),
			call = .call
		)
	}

	is_across <- vapply(quos, ._is_across_call, logical(1))
	is_ns <- vapply(
		quos,
		function(quo) is_call(quo_get_expr(quo), "with_ns"),
		logical(1)
	)
	is_ns <- is_ns & nms == ""
	is_formula <- nms == "" & vapply(quos, ._is_cols_formula, logical(1))
	loose <- nms == "" & !is_across & !is_ns & !is_formula
	if (any(loose)) {
		cli_abort(
			c(
				"Each argument to {.fn {fn}} must be named, a {.code cols ~ input} formula, or use {.fn across} or {.fn with_ns}.",
				x = ._other_across_hint(quos[loose]),
				i = "Formula: {.code {fn}(filters, where(is.numeric) ~ \"slider\")}.",
				i = "Named: {.code {fn}(filters, origin = \"radio\")}.",
				i = "{.fn across}: {.code {fn}(filters, across(where(is.numeric), \"slider\"))}.",
				i = "{.fn with_ns}: {.code {fn}(filters, with_ns(\"id\"))}."
			),
			call = .call
		)
	}

	used <- character()
	# One argument at a time, so each sees the columns the earlier ones computed.
	for (i in seq_along(quos)) {
		if (is_across[[i]] || is_formula[[i]]) {
			.data <- inject(.with_filters(
				.data,
				!!!quos[i],
				.call = .call,
				.fn = fn
			))
			cols <- if (is_formula[[i]]) {
				._formula_spec(quos[[i]])$cols
			} else {
				._across_spec(quos[[i]], call = .call)$cols
			}
			used <- c(used, names(eval_select(cols, .data@data)))
		} else if (is_ns[[i]]) {
			.data <- ._mutate_ns(.data, quos[[i]], call = .call, fn = fn)
		} else {
			used <- c(used, nms[[i]])
			.data <- ._set_column(
				.data,
				nms[[i]],
				quos[[i]],
				call = .call,
				fn = fn
			)
		}
	}
	if (!.keep_used) {
		return(.data)
	}
	used <- unique(used)
	if (length(used) == 0) {
		cli_abort(
			c(
				"{.fn {fn}} must keep at least one column.",
				i = "Name columns: {.code {fn}(filters, origin = \"radio\")}."
			),
			call = .call
		)
	}
	._select_columns(.data, new_quosure(used), "", .call)
}

`mutate.shinyfilters::shinyfilters` <- function(.data, ...) {
	._mutate_impl(.data, ..., .fn = "mutate", .call = current_env())
}

`transmute.shinyfilters::shinyfilters` <- function(.data, ...) {
	._mutate_impl(
		.data,
		...,
		.fn = "transmute",
		.call = current_env(),
		.keep_used = TRUE
	)
}

# `with_ns()` takes the configuration from `mutate()`, so the call is captured
# and only its `ns` is evaluated.
._mutate_ns <- function(config, quo, call, fn) {
	args <- call_args(quo_get_expr(quo))
	if (length(args) != 1 || !(names2(args) %in% c("", "ns"))) {
		cli_abort(
			c(
				"{.fn with_ns} takes only {.arg ns} inside {.fn {fn}}.",
				i = "Set a namespace: {.code {fn}(filters, with_ns(\"id\"))}.",
				i = "Remove it: {.code {fn}(filters, with_ns(NULL))}."
			),
			call = call
		)
	}
	ns <- eval_tidy(args[[1]], env = quo_get_env(quo))
	with_ns(config, ns)
}

# shiny renders the page after its restore context has closed, so inputs
# created here would silently ignore bookmarked values. Inside a session
# (`renderUI()`, `insertUI()`), the session's restore context still applies.
`as.tags.shinyfilters::shinyfilters` <- function(x, ...) {
	bookmarking <- !identical(
		getShinyOption("bookmarkStore", "disable"),
		"disable"
	)
	if (bookmarking && is.null(getDefaultReactiveDomain())) {
		cli_abort(
			c(
				"{.cls shinyfilters} objects cannot be placed in the UI of apps with bookmarking enabled.",
				i = "Use {.code [[}, {.code $}, {.fn filterInput}, or {.code dplyr::pull()} inside the UI function to render the filters directly, so they restore their bookmarked values."
			),
			call = NULL
		)
	}
	filterInput(x)
}

`as.data.frame.shinyfilters::shinyfilters` <- function(x, ...) {
	return(x@data)
}

`as_tibble.shinyfilters::shinyfilters` <- function(x, ...) {
	tibble::as_tibble(x@data)
}

`as.data.table.shinyfilters::shinyfilters` <- function(x, ...) {
	data.table::as.data.table(x@data)
}
