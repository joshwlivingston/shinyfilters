# R/as_filter.R
#
# as_filter(): pair an input with arguments for it. Arguments that use `.x` are
# captured, and evaluated for each column when its input is created.

# Function: as_filter() ####
#' Set the Arguments of an Input
#'
#' `as_filter()` pairs an input with arguments for it. Use it wherever
#' [with_filter()], [across_filters()], or [dplyr::mutate()] take an input, to
#' change the arguments shinyfilters passes for a column, such as a slider's
#' `value`, or to add others, such as `step` or `width`.
#'
#' @param input The input: a keyword or a \pkg{shiny} input function, as
#'   described in [with_filter()].
#' @param ... Named arguments for `input`. They replace the ones shinyfilters
#'   passes for the column, such as `label`, `choices`, `min`, `max`, and
#'   `value`. `inputId` can't be set: an input's id is always its column's
#'   name.
#'
#'   An argument that uses `.x` is computed for each column when its input is
#'   created. `.x` is the column, missing values included, so pass
#'   `na.rm = TRUE` where it matters. The configuration's other columns can be
#'   used by name.
#'
#'   Other arguments are evaluated right away. Written inside
#'   `with_filter(.config, col = as_filter(...))`, they can use the columns
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
as_filter <- function(input, ...) {
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
	# Only an argument that uses `.x` waits for its column. The rest are
	# evaluated now, where `as_filter()` is called: they keep the values their
	# variables have at the call, and see the columns inside `with_filter()`.
	args <- lapply(args, function(arg) {
		if (".x" %in% all.vars(quo_get_expr(arg))) arg else eval_tidy(arg)
	})
	structure(
		list(
			input = resolve_filter_override(input, call = current_env()),
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
	if (!is.function(input)) {
		input <- INPUT_KEYWORDS[[unclass(input)]]$fn
	}
	cat_line(paste(
		col_magenta("<shinyfilters_filter>"),
		col_grey(symbol$bullet),
		col_cyan(._input_name(input))
	))
	args <- ._format_input_args(x$args)
	if (length(args) > 0) {
		cat_line(paste0("  ", ._pad(names(args)), " = ", col_blue(args)))
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
	mask <- as.list(config@data)
	mask$.x <- config@data[[name]]
	lapply(set_names(nm = names(args)), function(arg) {
		value <- args[[arg]]
		if (!is_quosure(value)) {
			return(value)
		}
		try_fetch(
			eval_tidy(value, data = mask),
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
