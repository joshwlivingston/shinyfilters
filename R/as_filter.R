# R/as_filter.R
#
# as_filter(): set the arguments of a column's input, with or without choosing
# the input. Arguments that use `.x` are captured, and evaluated for each
# column when its input is created.

# Function: as_filter() ####
#' Set the Arguments of an Input
#'
#' `as_filter()` sets arguments for a column's input, and can choose the input
#' with them. Use it wherever [with_filter()], [across_filters()], or
#' [dplyr::mutate()] take an input, to change the arguments shinyfilters passes
#' for a column, such as a slider's `value`, or to add others, such as `step`
#' or `width`.
#'
#' Arguments stay with their column. Setting the column again adds to them,
#' replacing those of the same name, and a new input keeps the ones it has an
#' argument for. They are matched by name only, so set an argument again if
#' its value doesn't suit the new input.
#'
#' @param input The input: a keyword or a \pkg{shiny} input function, as
#'   described in [with_filter()]. Leave it out to keep each column's input.
#' @param ... Named arguments for the input. They replace the ones shinyfilters
#'   passes for the column, such as `label`, `choices`, `min`, `max`, and
#'   `value`. `inputId` can't be set: an input's id is always its column's
#'   name.
#'
#'   Other arguments are evaluated right away. Written inside
#'   `with_filter(.filters, col = as_filter(...))`, they can use the columns
#'   too, as they are at that point.
#'
#' @returns A `shinyfilters_filter` object, to use as an input in
#'   [with_filter()].
#'
#' @seealso [with_filter()], [across_filters()]
#'
#' @examples
#' filters <- shinyfilters(nyc_flights)
#'
#' # A range slider: `.x` is the column the input is created for
#' filters <- with_filter(
#'   filters,
#'   dep_delay = as_filter(shiny::sliderInput, value = range(.x, na.rm = TRUE))
#' )
#' filters$dep_delay
#'
#' # Without an input, the column keeps the one it has
#' with_filter(filters, dep_delay = as_filter(step = 5))
#'
#' # Reuse an input for several columns
#' range_slider <- as_filter("slider", value = range(.x, na.rm = TRUE))
#' with_filter(filters, across_filters(where(is.numeric), range_slider))
#'
#' # Pass arguments shinyfilters doesn't compute
#' with_filter(
#'   filters,
#'   origin = as_filter("radio", label = "Airport", inline = TRUE)
#' )
#' @export
as_filter <- function(input = NULL, ...) {
	args <- enquos(...)
	if (length(args) > 0) {
		check_named_list_or_null(args, arg = "...")
	}
	if ("inputId" %in% names(args)) {
		cli_abort(c(
			"Can't set {.arg inputId} in {.fn as_filter}.",
			i = "An input's id is always its column's name."
		))
	}
	if (is.null(input) && length(args) == 0) {
		cli_abort("{.fn as_filter} needs an input or at least one argument.")
	}
	# Only an argument that uses `.x` waits for its column. The rest are
	# evaluated now, where `as_filter()` is called: they keep the values their
	# variables have at the call, and see the columns inside `with_filter()`.
	args <- lapply(args, function(arg) {
		if (".x" %in% all.vars(quo_get_expr(arg))) {
			quo_inject_narm(arg)
		} else {
			eval_tidy(arg)
		}
	})
	structure(
		list(
			input = if (!is.null(input)) {
				resolve_filter_override(input, call = current_env())
			},
			args = args
		),
		class = "shinyfilters_filter"
	)
}

._is_filter <- function(x) {
	inherits(x, "shinyfilters_filter")
}

## Method: print() ####
print.shinyfilters_filter <- function(x, ...) {
	input <- x$input
	if (is.character(input)) {
		input <- INPUT_KEYWORDS[[unclass(input)]]$fn
	}
	cat_line(paste(
		col_magenta("<shinyfilters_filter>"),
		col_grey(symbol$bullet),
		if (is.null(input)) {
			col_grey("the column's input")
		} else {
			col_cyan(._input_name(input))
		}
	))
	args <- ._format_input_args(x$args)
	if (length(args) > 0) {
		cat_line(paste0(
			"  ",
			._pad(ansi_strtrim(names(args), 25)),
			col_grey(" = "),
			ansi_strtrim(col_blue(args), 25)
		))
	}
	invisible(x)
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

# The name `as_filter()` arguments travel under in `...`, from
# `._config_input()` to `._call_input()`. No formal or `$` lookup on the way
# partial-matches it.
INPUT_ARGS <- ".shinyfilters_args"

# Returns the arguments of an `as_filter()` override for one column. The data
# mask holds the configuration's columns, like `with_filter()`'s, plus `.x`.
._input_args <- function(args, config, name, call) {
	.data <- config@data
	.data$.x <- .data[[name]]
	lapply(set_names(nm = names(args)), function(arg) {
		value <- args[[arg]]
		if (!is_quosure(value)) {
			return(value)
		}
		try_fetch(
			{
				eval_tidy(value, rlang::as_data_mask(.data))
			},
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
