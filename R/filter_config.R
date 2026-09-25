# R/filter_config.R
#
# Configure which input filterInput() creates for each column of a data.frame

# Function: as_filters() ####
#' Configure the Filters for a Data Frame
#'
#' `as_filters()` stores a data frame with the arguments used to create its
#' filters. Pass the result to [with_filter()] to choose the input for
#' individual columns, then to [filterInput()] to create the inputs.
#'
#' @param data A data frame.
#' @param ... Named arguments passed to [filterInput()] for every column, such
#'   as `slider = TRUE` or `selectize = TRUE`.
#' @param ns An optional namespace created by [shiny::NS()].
#'
#' @returns A `FilterConfig` object.
#'
#' @seealso [with_filter()]
#'
#' @examples
#' cars <- mtcars[c("mpg", "cyl", "gear")]
#'
#' cars |>
#'   as_filters(slider = TRUE) |>
#'   with_filter(cyl, "radio") |>
#'   filterInput()
#' @export
as_filters <- function(data, ..., ns = NULL) {
	if (!is.data.frame(data)) {
		cli_abort(
			"{.arg data} must be a data frame, not {.obj_type_friendly {data}}."
		)
	}
	if (!is.null(ns)) {
		._check_valid_shiny_ns(ns)
	}
	args <- list(...)
	if (length(args) > 0) {
		check_named_list_or_null(args, arg = "...")
	}
	FilterConfig(data = data, args = args, ns = ns)
}

## Method: filterInput() ####
method(filterInput, FilterConfig) <- function(x, ...) {
	call <- caller_env()
	args <- modifyList(c(x@args, list(ns = x@ns)), list(...))
	data <- x@data

	filter_input <- function(col, id, label, name) {
		col_args <- c(
			list(x = col),
			do.call(._id_label_args, c(list(col, id, label), args)),
			args
		)
		override <- x@overrides[[name]]
		if (is.null(override)) {
			return(do.call(filterInput, col_args))
		}
		try_fetch(
			do.call(
				filter_input_override,
				c(col_args, list(override = override$input))
			),
			shinyfilters_error_unsupported_input = function(cnd) {
				cli_abort(
					"Can't create an input for column {.field {name}}.",
					parent = cnd,
					call = call
				)
			}
		)
	}

	do.call(
		tagList,
		mapply(
			filter_input,
			data,
			get_input_ids(data),
			get_input_labels(data),
			names(data),
			SIMPLIFY = FALSE
		)
	)
}

# Function: with_filter() ####
#' Choose the Input for Columns
#'
#' `with_filter()` sets the input that [filterInput()] creates for one or more
#' columns of a configuration made by [as_filters()]. When a column is set
#' more than once, the last call wins.
#'
#' @param config A configuration created by [as_filters()].
#' @param ... Either two unnamed arguments, or any number of named arguments:
#'
#'   * `with_filter(config, cols, input)`: `cols` selects columns with
#'     <[`tidy-select`][tidyselect::language]>, such as `cyl`,
#'     `c(mpg, disp)`, or `where(is.numeric)`.
#'   * `with_filter(config, col = input, ...)`: each name is a column.
#'
#'   Each input is either a keyword (`"area"`, `"radio"`, `"range"`,
#'   `"selectize"`, `"slider"`, `"textbox"`) or a \pkg{shiny} input function,
#'   such as [shiny::radioButtons()]. `"radio"` and `"selectize"` also work
#'   with numeric columns, using the sorted unique values as choices.
#'
#' @returns The updated configuration.
#'
#' @seealso [as_filters()]
#'
#' @examples
#' cars <- mtcars[c("mpg", "cyl", "gear")]
#'
#' # Select columns, then choose their input
#' cars |>
#'   as_filters() |>
#'   with_filter(where(is.numeric), "slider") |>
#'   with_filter(cyl, "radio") |>
#'   filterInput()
#'
#' # Name columns directly
#' cars |>
#'   as_filters(slider = TRUE) |>
#'   with_filter(cyl = "radio", gear = "selectize") |>
#'   filterInput()
#' @export
with_filter <- function(config, ...) {
	if (!S7_inherits(config, FilterConfig)) {
		cli_abort(
			"{.arg config} must be created by {.fn as_filters}, not {.obj_type_friendly {config}}."
		)
	}
	.with_filter(config, ..., .call = current_env())
}

.with_filter <- new_generic(".with_filter", "config")

method(.with_filter, FilterConfig) <- function(
	config,
	...,
	.call = caller_env()
) {
	quos <- enquos(...)
	nms <- names2(quos)

	if (length(quos) > 0 && all(nms != "")) {
		unknown <- setdiff(nms, names(config@data))
		if (length(unknown) > 0) {
			cli_abort("Can't find column{?s} {.field {unknown}}.", call = .call)
		}
		overrides <- lapply(quos, ._new_override, call = .call)
	} else if (length(quos) == 2 && all(nms == "")) {
		cols <- names(eval_select(
			quos[[1]],
			config@data,
			allow_rename = FALSE,
			error_call = .call
		))
		if (length(cols) == 0) {
			cli_abort(
				"{.code {as_label(quos[[1]])}} doesn't select any columns.",
				call = .call
			)
		}
		overrides <- rep(
			list(._new_override(quos[[2]], call = .call)),
			length(cols)
		)
		names(overrides) <- cols
	} else {
		cli_abort(
			c(
				"{.fn with_filter} takes two unnamed arguments or only named arguments.",
				i = "Select columns: {.code with_filter(config, c(a, b), \"radio\")}.",
				i = "Name columns: {.code with_filter(config, a = \"radio\", b = \"slider\")}."
			),
			call = .call
		)
	}

	overrides_all <- config@overrides
	overrides_all[names(overrides)] <- overrides
	set_props(config, overrides = overrides_all)
}

._new_override <- function(quo, call) {
	label <- as_label(quo)
	input <- try_fetch(
		eval_tidy(quo),
		error = function(cnd) {
			cli_abort(
				c(
					"Can't evaluate the input {.code {label}}.",
					i = "Keywords are strings, e.g. {.code \"radio\"}."
				),
				parent = cnd,
				call = call
			)
		}
	)
	list(input = resolve_filter_override(input, call = call), label = label)
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
	flags_off <- lapply(INPUT_KEYWORDS, \(keyword) FALSE)
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
	fallback <- S7::method(
		filter_input_override,
		list(class_any, class_input_keyword)
	)
	keywords <- names(INPUT_KEYWORDS)
	is_supported <- vapply(
		keywords,
		function(keyword) {
			found <- S7::method(
				filter_input_override,
				object = list(x, input_keyword(keyword))
			)
			!identical(found, fallback)
		},
		logical(1)
	)
	keywords[is_supported]
}
