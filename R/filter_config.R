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
#' @returns A `shinyfilters` object. `names(filters)` lists its columns;
#'   `filters$col` and `filters[["col"]]`
#'   return the input [filterInput()] creates for a single column, including
#'   any [with_filter()] overrides.
#'
#' @seealso [with_filter()]
#'
#' @examples
#' cars <- mtcars[c("mpg", "cyl", "gear")]
#'
#' filters <- as_filters(cars, slider = TRUE)
#' filters <- with_filter(filters, cyl, "radio")
#' filterInput(filters)
#'
#' # The input for one column
#' filters$cyl
#' @export
as_filters <- function(data, ..., ns = NULL) {
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
	class_shinyfilters(data = data, args = args, ns = ns)
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

## Methods: $, [[, names(), .DollarNames() ####
method(`$`, class_shinyfilters) <- function(x, name) {
	._config_column(x, name, call = call("$", substitute(x), as.name(name)))
}

method(`[[`, class_shinyfilters) <- function(x, i, ...) {
	._config_column(x, i, call = call("[[", substitute(x), substitute(i)))
}

method(.DollarNames, class_shinyfilters) <- function(x, pattern = "") {
	grep(pattern, names(x), value = TRUE)
}

method(names, class_shinyfilters) <- function(x) {
	names(x@data)
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
method(print, class_shinyfilters) <- function(x, ...) {
	data <- x@data
	nms <- names(data)
	overridden <- nms %in% names(x@overrides)

	n_filters <- ncol(data)
	header <- format_inline("{n_filters} filter{?s}")
	if (!is.null(x@ns)) {
		header <- paste(
			header,
			symbol$bullet,
			format_inline("namespace {.val {x@ns(character())}}")
		)
	}
	cat_rule(
		left = paste(col_blue("<shinyfilters>"), symbol$line, header)
	)

	if (length(x@args) > 0) {
		values <- vapply(x@args, ._format_arg, character(1))
		defaults <- paste(names(values), "=", values, collapse = ", ")
		cat_line(col_grey("Defaults"), "  ", defaults)
	}
	cat_line()

	inputs <- ._dry_run_inputs(x)
	is_error <- startsWith(inputs, symbol$cross)
	width <- max(0L, ansi_nchar(inputs[!is_error], type = "width"))
	styled_inputs <- ifelse(
		is_error,
		col_red(inputs),
		col_cyan(ansi_align(inputs, width))
	)
	dot <- col_blue(if (is_utf8_output()) "\u25cf" else "*")
	marker <- ifelse(overridden, paste0("  ", dot), "")
	types <- vapply(data, ._type_abbr, character(1))
	lines <- paste0(
		"  ",
		._pad(nms),
		"  ",
		col_grey(._pad(types)),
		"  ",
		styled_inputs,
		marker
	)
	cat_line(sub("\\s+$", "", lines))

	if (any(overridden)) {
		cat_line()
		cat_line(dot, col_grey(" set by with_filter()"))
	}
	invisible(x)
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
	the$dry_run <- TRUE
	on.exit({
		assign("dry_run", FALSE, envir = the)
		assign("dry_run_fn", NULL, envir = the)
	})

	data <- config@data
	args <- ._config_args(config)
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
			._dry_run_label(res, config@overrides[[name]])
		},
		names(data),
		get_input_ids(data),
		get_input_labels(data),
		USE.NAMES = FALSE
	)
}

._dry_run_label <- function(res, override) {
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
	for (name in names(SHINY_INPUTS)) {
		if (identical(res$fn, SHINY_INPUTS[[name]])) {
			return(name)
		}
	}
	if (is.function(override$input)) {
		return(override$label)
	}
	"<custom>"
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
#'   Other functions are called like [call_filter_input()]: they receive the
#'   arguments [args_filter_input()] returns for the column's type, plus any
#'   other arguments they accept.
#'
#' @returns The updated configuration.
#'
#' @seealso [as_filters()]
#'
#' @examples
#' cars <- mtcars[c("mpg", "cyl", "gear")]
#'
#' # Select columns, then choose their input
#' filters <- as_filters(cars)
#' filters <- with_filter(filters, where(is.numeric), "slider")
#' filters <- with_filter(filters, cyl, "radio")
#' filterInput(filters)
#'
#' # Name columns directly
#' filters <- as_filters(cars, slider = TRUE)
#' filters <- with_filter(filters, cyl = "radio", gear = "selectize")
#' filterInput(filters)
#' @export
with_filter <- function(config, ...) {
	if (!S7_inherits(config, class_shinyfilters)) {
		cli_abort(
			"{.arg config} must be created by {.fn as_filters}, not {.obj_type_friendly {config}}."
		)
	}
	.with_filter(config, ..., .call = current_env())
}

.with_filter <- new_generic(".with_filter", "config")

method(.with_filter, class_shinyfilters) <- function(
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
