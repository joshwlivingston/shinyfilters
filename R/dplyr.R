# R/dplyr.R
#
# dplyr verbs and coercion methods for shinyfilters objects

#' Choose Inputs with dplyr Verbs
#'
#' [dplyr::mutate()] sets the input [filterInput()] creates for a column of a
#' configuration made by [shinyfilters()], like [with_filter()] does.
#' [dplyr::select()] keeps only the selected columns, and [dplyr::pull()]
#' returns one column's input.
#'
#' @param .data A configuration created by [shinyfilters()].
#' @param ... For `mutate()`, either named arguments or a call to
#'   [across_filters()]:
#'
#'   * `mutate(filters, col = input)`: each name is a column.
#'   * `mutate(filters, across_filters(cols, input))`: `cols` selects columns
#'     with <[`tidy-select`][tidyselect::language]>.
#'
#'   [dplyr::across()] is accepted in place of [across_filters()] here.
#'
#'   Each input is a keyword or a shiny input function, as described in
#'   [with_filter()].
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
#' # Keep only some columns
#' select(filters, origin, carrier)
NULL

#' @exportS3Method dplyr::select shinyfilters::shinyfilters
`select.shinyfilters::shinyfilters` <- function(.data, ...) {
	.data[c(...)]
}

#' @exportS3Method dplyr::pull shinyfilters::shinyfilters
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

#' @exportS3Method dplyr::mutate shinyfilters::shinyfilters
`mutate.shinyfilters::shinyfilters` <- function(.data, ...) {
	call <- current_env()
	quos <- enquos(...)
	nms <- names2(quos)

	reserved <- intersect(nms, c(".by", ".keep", ".before", ".after"))
	if (length(reserved) > 0) {
		cli_abort(
			c(
				"{.fn mutate} doesn't support {.arg {reserved}} for a {.cls shinyfilters} object.",
				i = "It chooses each column's input; it doesn't add, drop, or move columns."
			),
			call = call
		)
	}

	for (i in seq_along(quos)) {
		is_across <- ._is_across_call(quo_get_expr(quos[[i]]))
		if (nms[[i]] == "" && !is_across) {
			cli_abort(
				c(
					"Each argument to {.fn mutate} must be named or use {.fn across}.",
					i = "Named: {.code mutate(filters, origin = \"radio\")}.",
					i = "{.fn across}: {.code mutate(filters, across(where(is.numeric), \"slider\"))}."
				),
				call = call
			)
		}
	}

	inject(.with_filter(
		.data,
		!!!quos,
		.call = call,
		.across = MUTATE_ACROSS_NAMES
	))
}

#' @exportS3Method as.character shinyfilters::shinyfilters
`as.character.shinyfilters::shinyfilters` <- function(x, ...) {
	as.character(filterInput(x))
}

#' @exportS3Method as.data.frame shinyfilters::shinyfilters
`as.data.frame.shinyfilters::shinyfilters` <- function(x, ...) {
	return(x@data)
}

#' @exportS3Method tibble::as_tibble shinyfilters::shinyfilters
`as_tibble.shinyfilters::shinyfilters` <- function(x, ...) {
	tibble::as_tibble(x@data)
}

#' @exportS3Method data.table::as.data.table shinyfilters::shinyfilters
`as.data.table.shinyfilters::shinyfilters` <- function(x, ...) {
	data.table::as.data.table(x@data)
}
