# R/dplyr.R
#
# dplyr verbs and coercion methods for shinyfilters objects

#' Choose Inputs with dplyr Verbs
#'
#' [dplyr::mutate()] sets the input [filterInput()] creates for a column of a
#' configuration made by [shinyfilters()], like [with_filter()] does, and
#' adds or replaces columns computed from the others.
#' [dplyr::select()] keeps only the selected columns, and [dplyr::pull()]
#' returns one column's input.
#'
#' @param .data A configuration created by [shinyfilters()].
#' @param ... For `mutate()`, either named arguments or a call to
#'   [across_filters()]:
#'
#'   * `mutate(filters, col = input)`: each name is a column.
#'   * `mutate(filters, col = expression)`: adds or replaces a column, like
#'     [dplyr::mutate()] does for a data frame. A replaced column keeps its
#'     input.
#'   * `mutate(filters, across_filters(cols, input))`: `cols` selects columns
#'     with <[`tidy-select`][tidyselect::language]>.
#'
#'   [dplyr::across()] is accepted in place of [across_filters()] here.
#'
#'   Each input is a keyword or a shiny input function, as described in
#'   [with_filter()]. A function or a single string is always read as an
#'   input; any other value is the column's data.
#'
#'   For `select()`, the columns to keep, using
#'   <[`tidy-select`][tidyselect::language]>.
#'
#' @returns The updated configuration.
#'
#' @seealso [with_filter()], [across_filters()]
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
#' mutate(filters, air_time_hours = air_time / 60)
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
	.data[[var]]
}

# `across()` is accepted alongside `across_filters()` here, and only here:
# inside `mutate()`, dplyr is attached by definition, so no name is masked.
SHINYFILTERS_ACROSS <- "across_filters"
DPLYR_ACROSS <- "across"
MUTATE_ACROSS_NAMES <- c(SHINYFILTERS_ACROSS, DPLYR_ACROSS)

`mutate.shinyfilters::shinyfilters` <- function(.data, ...) {
	call <- current_env()
	quos <- enquos(...)
	nms <- names2(quos)

	reserved <- intersect(nms, c(".by", ".keep", ".before", ".after"))
	if (length(reserved) > 0) {
		cli_abort(
			c(
				"{.fn mutate} doesn't support {.arg {reserved}} for a {.cls shinyfilters} object.",
				i = "It chooses inputs and computes columns; it doesn't drop or move them."
			),
			call = call
		)
	}

	is_across <- vapply(
		quos,
		function(quo) ._is_across_call(quo_get_expr(quo)),
		logical(1)
	)
	if (any(nms == "" & !is_across)) {
		cli_abort(
			c(
				"Each argument to {.fn mutate} must be named or use {.fn across}.",
				i = "Named: {.code mutate(filters, origin = \"radio\")}.",
				i = "{.fn across}: {.code mutate(filters, across(where(is.numeric), \"slider\"))}."
			),
			call = call
		)
	}

	# One argument at a time, so each sees the columns the earlier ones computed.
	for (i in seq_along(quos)) {
		if (is_across[[i]]) {
			.data <- inject(.with_filter(
				.data,
				!!!quos[i],
				.call = call,
				.across = MUTATE_ACROSS_NAMES
			))
		} else {
			.data <- ._mutate_column(.data, nms[[i]], quos[[i]], call = call)
		}
	}
	.data
}

# A function or a single string chooses the column's input; any other value is
# the column's data, computed from the other columns.
._mutate_column <- function(config, name, quo, call) {
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

	if (is.function(value) || is_string(value)) {
		if (!(name %in% names(data))) {
			cli_abort(
				c(
					"Can't find column {.field {name}}.",
					x = "{.code {label}} chooses the input for an existing column.",
					i = "To add a column, compute it from the others: {.code mutate(filters, {name} = <expression>)}."
				),
				call = call
			)
		}
		override <- list(
			input = resolve_filter_override(value, call = call),
			label = label
		)
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
	data[[name]] <- if (length(value) == 1) rep(value, n) else value
	set_props(config, data = data)
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
				"Can't place a {.cls shinyfilters} object in the UI of an app that uses bookmarking.",
				i = "Call {.code filterInput(filters)} inside the UI function instead, so the inputs restore their bookmarked values."
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
