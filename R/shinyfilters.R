# R/shinyfilters.R
#
# Configure which input filterInput() creates for each column of a data.frame

# Function: shinyfilters() ####
#' Configure the Filters for a Data Frame
#'
#' `shinyfilters()` creates a set of interdependent filters for use in a
#' \pkg{shiny} application.
#'
#' @param .data A `data.frame`.
#' @param ... Named arguments passed to the selected input.
#' @param area *(character)*. Logical. Controls whether to use  [textAreaInput]
#'   (`TRUE`) or [textInput] (`FALSE`). Only applies when `textbox` is
#'   `TRUE`.
#' @param radio *(character, factor, list, logical)*. Logical. Controls whether
#'   to use [radioButtons] (`TRUE`) or a dropdown input (`FALSE`). For
#'   character vectors, `radio` only applies if `textbox` is `FALSE`. `TRUE`
#'   turns off the `selectize` default; setting both to `TRUE` is an error.
#' @param range *(Date, POSIXt)*. Logical. Controls whether to use
#'   [dateRangeInput] (`TRUE`) or [dateInput] (`FALSE`).
#' @param selectize *(character, factor, list, logical)*. Logical. Controls
#'   whether to use [selectizeInput] (`TRUE`) or [selectInput] (`FALSE`). For
#'   character vectors, `selectize` only applies if `textbox` is `FALSE`.
#' @param multiple Passed to [selectInput] or [selectizeInput].
#' @param slider *(numeric)*. Logical. Controls whether to use [sliderInput]
#'   (`TRUE`) or [numericInput] (`FALSE`).
#' @param textbox *(character)*. Logical. Controls whether to use a text input
#'   (`TRUE`) or a dropdown input (`FALSE`).
#' @param ns An optional namespace created by [NS()] or an object to be coerced
#'   to a namespace. Useful when using `shinyfilters()` inside a \pkg{shiny}
#'   module.
#'
#' @returns A [shinyfilters][shinyfilters-class] object.
#'
#' @seealso [with_filters()], [with_ns()]
#'
#' @examplesIf interactive()
#' shinyfilters(nyc_flights)
#'
#' # Use sliders for every numeric column
#' shinyfilters(nyc_flights, slider = TRUE)
#' @export
shinyfilters <- function(
	.data,
	...,
	area = FALSE,
	radio = FALSE,
	range = TRUE,
	selectize = TRUE,
	multiple = TRUE,
	slider = TRUE,
	textbox = FALSE,
	ns = NULL
) {
	if (!is.data.frame(.data)) {
		cli_abort(
			"{.arg .data} must be a {.cls data.frame}, not {.obj_type_friendly {(.data)}}."
		)
	}
	if (nrow(.data) == 0) {
		cli_abort("{.arg .data} must have at least one row.")
	}
	if (!is.null(ns)) {
		._resolve_ns(ns, call = current_env())
	}
	args <- list(...)
	if (length(args) > 0) {
		check_named_list_or_null(args, arg = "...")
	}
	flags <- list(
		area = area,
		radio = radio,
		range = range,
		selectize = selectize,
		multiple = multiple,
		slider = slider,
		textbox = textbox
	)
	# `radio = TRUE` asks for radio buttons, so the `selectize` default gives
	# way. Passing both is still an error.
	if (isTRUE(radio) && missing(selectize)) {
		flags$selectize <- NULL
	}
	class_shinyfilters(
		data = .data,
		args = ._remove_default_flags(c(flags, args)),
		ns = ns
	)
}

# Drops input flags set to `FALSE`, `filterInput()`'s default. `selectize`
# stays: it is an argument of `selectInput()` too, where `FALSE` isn't the
# default.
._remove_default_flags <- function(args) {
	is_flag <- names(args) %in% setdiff(INPUT_FLAGS, "selectize")
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
	# `print()`'s dry run never evaluates a column's arguments.
	if (!the$dry_run && length(override$args) > 0) {
		col_args[[INPUT_ARGS]] <- ._input_args(override$args, config, name, call)
	}
	# Arguments without an input leave the choice to `filterInput()`.
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

## Methods: $, [[, [, names(), dim(), .DollarNames(), str() ####
`$.shinyfilters::shinyfilters` <- function(x, name) {
	._check_not_inspected(parent.frame())
	._config_column(x, name, call = call("$", substitute(x), as.name(name)))
}

# A UI function such as `bslib::accordion()` has htmltools inspect its
# contents before the page is rendered, so before `as.tags()` creates the
# inputs. htmltools reads a child's attributes with `$`, and calls `str()` on
# a descendant it doesn't recognize, then errors. `env` is the method's caller.
._check_not_inspected <- function(env) {
	if (!identical(topenv(env), asNamespace("htmltools"))) {
		return(invisible())
	}
	cli_abort(
		c(
			"{.cls shinyfilters} objects cannot be used in some shiny functions.",
			i = "Use {.code [[}, {.code $}, {.fn filterInput}, or {.code dplyr::pull()} to render the filters directly."
		),
		call = NULL
	)
}

`str.shinyfilters::shinyfilters` <- function(object, ...) {
	._check_not_inspected(parent.frame())
	NextMethod()
}

`[[.shinyfilters::shinyfilters` <- function(x, i, ...) {
	call <- sys.call()
	call[[1]] <- as.name("[[")
	._check_columns_only(nargs(), call)
	if (missing(i)) {
		return(x)
	}
	selection <- new_quosure(substitute(i), parent.frame())
	res <- ._select_columns(x, selection, as_label(selection), call)
	inputs <- filterInput(res)
	# One column gives its input, as `$` does.
	if (length(inputs) == 1) {
		return(inputs[[1]])
	}
	inputs
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
	._check_columns_only(nargs(), call)
	if (missing(i)) {
		return(x)
	}
	selection <- new_quosure(substitute(i), parent.frame())
	._select_columns(x, selection, as_label(selection), call)
}

# `n_args` counts the object: more than one index asks for rows and columns.
._check_columns_only <- function(n_args, call) {
	if (n_args > 2) {
		cli_abort(
			c(
				"Can't subset a {.cls shinyfilters} object by rows and columns.",
				i = "Select columns with {.code x[cols]}."
			),
			call = call
		)
	}
}

`dim.shinyfilters::shinyfilters` <- function(x) {
	dim(x@data)
}

# Shared by `[` and dplyr's `select()`. Each passes the user's selection and
# its own call and label, so errors name the code the user wrote.
._select_columns <- function(x, selection, label, call) {
	._private()
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
	._modify(
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
	if (!(col %in% nms)) {
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
	# Arguments alone don't choose the input, or mark the row.
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
			header,
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
	defaults <- ._default_overrides(x)
	inputs <- ._dry_run_inputs(x)
	# With the space: a function's name can start with the ASCII cross, `x`.
	is_error <- startsWith(inputs, paste0(symbol$cross, " "))
	width <- max(0L, ansi_nchar(inputs[!is_error], type = "width"))
	styled_inputs <- ifelse(
		is_error,
		col_red(inputs),
		vapply(
			inputs,
			function(input) {
				if (grepl(".+::.+", input)) {
					pkg_func <- strsplit(input, "::")[[1]]
					paste(
						col_cyan(pkg_func[[2]]),
						col_grey(sprintf("{%s}", pkg_func[[1]]))
					)
				} else {
					col_cyan(ansi_align(input, width))
				}
			},
			character(1L)
		)
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
		._set_by_default(x, inputs, defaults)
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
	# A column's arguments follow its row, under its input.
	indent <- strrep(
		" ",
		ansi_nchar(marker[[1]], type = "width") +
			min(25, max(ansi_nchar(nms, type = "width"))) +
			min(25, max(ansi_nchar(types, type = "width"))) +
			8
	)
	arg_lines <- lapply(nms, function(nm) {
		args <- ._format_override_args(x@overrides[[nm]])
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
			ansi_strtrim(
				vapply(
					seq_along(args),
					function(i) {
						color <- if (names(args)[[i]] == ".update_fn") {
							col_cyan
						} else {
							col_blue
						}
						if (grepl(".+::.+", args[[i]])) {
							pkg_func <- strsplit(args[[i]], "::")[[1]]
							paste(
								col_cyan(pkg_func[[2]]),
								col_grey(sprintf("{%s}", pkg_func[[1]]))
							)
						} else {
							color(args[[i]])
						}
					},
					character(1L)
				),
				max(36, console_width() - nchar(indent))
			)
		)
	})
	lines <- Map(c, sub("\\s+$", "", lines), arg_lines)
	cat_line(unlist(lines, use.names = FALSE))

	if (length(defaults) > 0) {
		cat_line()
		values <- vapply(defaults, ._format_arg, character(1))
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

# Columns whose input differs from the one `shinyfilters()`'s own defaults
# give them. `defaults` are the configuration's default overrides.
._set_by_default <- function(config, inputs, defaults) {
	if (length(defaults) == 0) {
		return(rep(FALSE, length(inputs)))
	}
	args <- c(
		._remove_default_flags(._signature_defaults()),
		list(ns = config@ns)
	)
	inputs != ._dry_run_inputs(config, args = args)
}

# The default arguments that differ from `shinyfilters()`'s own: the arguments
# it names, as they are in effect, then any other. One that isn't stored is
# `FALSE`, as `filterInput()` has it.
._default_overrides <- function(config) {
	args <- config@args
	signature <- ._signature_defaults()
	current <- lapply(names(signature), function(name) {
		if (name %in% names(args)) args[[name]] else FALSE
	})
	names(current) <- names(signature)
	differs <- !mapply(identical, current, signature)
	c(current[differs], args[!(names(args) %in% names(signature))])
}

# The defaults of the arguments `shinyfilters()` passes to `filterInput()`
._signature_defaults <- function() {
	args <- formals(shinyfilters)
	as.list(args[!(names(args) %in% c(".data", "...", "ns"))])
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

._dry_run_result <- function(.f) {
	the$dry_run_fn <- .f
	structure(list(fn = .f), class = "shinyfilters_dry_run")
}

._dry_run_inputs <- function(config, args = ._config_args(config)) {
	res <- ._dry_run(config, args = args)
	nms <- names(config@data)
	vapply(
		seq_along(res),
		function(i) ._dry_run_label(res[[i]], config@overrides[[nms[[i]]]]$label),
		character(1)
	)
}

# One result per column: the input `._call_input()` was asked to call, or the
# error that kept `filterInput()` from getting that far.
._dry_run <- function(
	config,
	cols = names(config@data),
	args = ._config_args(config)
) {
	the$dry_run <- TRUE
	on.exit({
		assign("dry_run", FALSE, envir = the)
		assign("dry_run_fn", NULL, envir = the)
	})

	data <- config@data
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

._dry_run_label <- function(res, label = NULL) {
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
	._input_name(res$fn, label)
}

# The name of a shiny input function. Any other function has its `label`, the
# name it was written with, or `<custom>` without one.
._input_name <- function(fn, label = NULL) {
	inputs <- ._shiny_inputs()
	for (name in names(inputs)) {
		if (identical(fn, inputs[[name]])) {
			return(name)
		}
	}
	if (is.null(label)) "<custom>" else label
}

._is_shiny_input <- function(fn) {
	any(vapply(._shiny_inputs(), identical, logical(1), fn))
}

# The shiny inputs `filterInput()` creates. A function, so they are looked up
# when it is called: a list made when the package is built would hold the
# functions of the shiny installed then, which a later shiny no longer matches.
._shiny_inputs <- function() {
	list(
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
}

# Function: with_filters() ####
#' Choose the Input for Columns
#'
#' `with_filters()` sets the input that [filterInput()] creates for one or more
#' columns of a configuration made by [shinyfilters()], and adds or replaces
#' columns computed from the others. When a column's input is chosen more than
#' once, the last one wins; the arguments set for the column stay with it.
#'
#' @param .filters A configuration created by [shinyfilters()].
#' @param ... Either two unnamed arguments, or any number of named arguments,
#'   formulas, and `across()` calls:
#'
#'   * `with_filters(.filters, cols, input)`: `cols` selects columns with
#'     <[`tidy-select`][tidyselect::language]>, such as `cyl`,
#'     `c(mpg, disp)`, or `where(is.numeric)`.
#'   * `with_filters(.filters, col = input, ...)`: each name is a column.
#'   * `with_filters(.filters, col = expression, ...)`: adds or replaces a
#'     column, computed from the other columns. A replaced column keeps its
#'     input. A function or a single string is always read as an input, and
#'     code with `:=` arguments as an input's arguments; any other value is the
#'     column's data. A column takes precedence over a variable of the same
#'     name.
#'   * `with_filters(.filters, cols ~ input, ...)`: a two-sided formula selects
#'     columns on its left, like `cols` above, and names one input for all of
#'     them on its right. It can be mixed with named columns.
#'   * `with_filters(.filters, across(cols, input), ...)`: `across()` does the
#'     same as a formula, with the first two arguments of [dplyr::across()].
#'     `cols` defaults to every column, and `input` can be a one-sided
#'     formula, such as `~ "slider"`. Its other arguments aren't supported.
#'     The call is read as written and never run, so \pkg{dplyr} isn't
#'     needed. Another function named `across()`, your own or an attached
#'     package's, is never read this way: it is called like any other
#'     function. Write `dplyr::across()` to select columns then.
#'   * `with_filters(.filters, cols ~ arg := value, ...)`: sets an argument of
#'     the inputs the columns have, as [with_args()] does. `list()` holds
#'     several arguments, and `across(cols, arg := value)` works too.
#'   * `with_filters(.filters, col := value, ...)`: the same as `col = value`
#'     when `col` is a column. `:=` never adds a column.
#'
#'   Each input is either a keyword or the \pkg{shiny} input function it
#'   stands for, such as [shiny::radioButtons()] for `"radio"`. The keywords
#'   are `"area"`, `"date"`, `"numeric"`, `"radio"`, `"range"`, `"select"`,
#'   `"selectize"`, `"slider"`, and `"textbox"`. `"date"`, `"numeric"`, and
#'   `"select"` are the inputs columns have by default: use them to opt a
#'   column out of a default argument such as `slider = TRUE`. `"radio"`,
#'   `"select"`, and `"selectize"` work with any column: a number or a date
#'   uses its sorted unique values as choices, and a datetime its dates.
#'
#'   Other functions are called like [call_filter_input()]: they receive the
#'   arguments [args_filter_input()] returns for the column's type, plus any
#'   other arguments they accept.
#'
#'   An input takes its arguments with it, wherever an input goes. Write
#'   `input ~ arguments`, such as `col = "slider" ~ value := range(.x)` or
#'   `cols ~ "slider" ~ list(value := range(.x), step = 5)`, or call the
#'   function with `:=` arguments, such as
#'   `col = sliderInput(value := range(.x))`. Either is read as written and
#'   never run; [with_args()] describes the arguments.
#'
#'   [shinyfilters_server()] needs the function that updates an input that
#'   isn't one [filterInput()] creates. A \pkg{shinyWidgets} input comes with
#'   its own, such as `updatePickerInput()` for `pickerInput()`. For any other,
#'   name it with `.update_fn := fn` among the arguments, such as
#'   `col = checkboxGroupInput(.update_fn := updateCheckboxGroupInput)`.
#'
#'   Arguments stay with the column: setting it again adds to them, replacing
#'   those of the same name, and an input chosen later keeps the ones it has an
#'   argument for. They are matched by name only, so set an argument again if
#'   its value doesn't suit the new input. `.update_fn` stays with the input
#'   instead: a new input drops it.
#'
#' @returns The updated configuration.
#'
#' @seealso [shinyfilters()], [with_args()]
#'
#' @examples
#' filters <- shinyfilters(nyc_flights)
#' filters <- with_filters(filters, origin = "radio", carrier = "selectize")
#' filters
#'
#' # Choose one input for several columns with tidyselect
#' filters <- with_filters(filters, where(is.numeric), "slider")
#' filterInput(filters)
#'
#' # Or select columns and name others in one call
#' with_filters(
#'   filters,
#'   where(is.character) ~ "selectize",
#'   origin = "radio"
#' )
#'
#' # across() selects columns too. Later arguments win.
#' with_filters(
#'   filters,
#'   across(everything(), "selectize"),
#'   origin = "radio"
#' )
#'
#' # Give an input its arguments. `.x` is the column the input is for.
#' with_filters(filters, dep_delay = "slider" ~ value := range(.x))
#'
#' # Add a column computed from the others
#' with_filters(filters, delay_sq = dep_delay^2)
#'
#' # Give one column the input it has by default
#' filters <- shinyfilters(nyc_flights, slider = TRUE)
#' with_filters(filters, distance = "numeric")
#' @export
with_filters <- function(.filters, ...) {
	check_shinyfilters(.filters)
	if (...length() == 0) {
		._abort_with_filter_form(list(), call = current_env())
	}
	.with_filters(.filters, ..., .call = current_env())
}

.with_filters <- new_generic(".with_filters", ".filters")

method(.with_filters, class_shinyfilters) <- function(
	.filters,
	...,
	.call = caller_env(),
	.fn = "with_filters"
) {
	config <- .filters
	# `:=` is read here, not by rlang: it sets an argument.
	quos <- enquos(..., .unquote_names = FALSE)
	if (._is_cols_input_pair(quos)) {
		return(._override_cols(
			config,
			quos[[1]],
			quos[[2]],
			call = .call,
			fn = .fn
		))
	}
	quos <- ._name_walrus(quos, config, call = .call, fn = .fn)
	nms <- names2(quos)
	named <- nms != ""
	is_across <- vapply(quos, ._is_across_call, logical(1))
	is_formula <- !named & vapply(quos, ._is_cols_formula, logical(1))

	if (any(is_across & named)) {
		i <- which(is_across & named)[[1]]
		._abort_across_named(nms[[i]], call = .call)
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

# `with_filters(filters, cols, input)`: two unnamed arguments, the first a plain
# column selection. The second is the columns' input, however it is written.
._is_cols_input_pair <- function(quos) {
	if (length(quos) != 2 || any(names2(quos) != "")) {
		return(FALSE)
	}
	cols <- quos[[1]]
	!._is_across_call(cols) &&
		!._is_cols_formula(cols) &&
		!._is_arg_walrus(quo_get_expr(cols)) &&
		!._is_across_call(quos[[2]])
}

# Reached only from `with_filters()`: `mutate()` checks its own argument shapes
# before forwarding, so its wording never has to appear here.
._abort_with_filter_form <- function(quos, call) {
	cli_abort(
		c(
			"{.fn with_filters} takes two unnamed arguments, or named arguments, {.code cols ~ input} formulas, and {.fn across} calls.",
			x = ._other_across_hint(quos),
			i = "Select columns: {.code with_filters(filters, c(a, b), \"radio\")}.",
			i = "Name columns: {.code with_filters(filters, a = \"radio\", b = \"slider\")}.",
			i = "Mix the two: {.code with_filters(filters, c(a, b) ~ \"radio\", x = \"slider\")}."
		),
		call = call
	)
}

._override_cols <- function(config, cols, input, call, fn) {
	._private()
	selected <- ._eval_cols(config, cols, call = call)
	override <- ._value_override(config, input, call = call, fn = fn)
	overrides <- rep(list(override), length(selected))
	names(overrides) <- selected
	._set_overrides(config, overrides)
}

# What the right side of a formula, or the second argument of `across()`, gives
# its columns: a `:=` spec, read as written, or an input, evaluated.
._value_override <- function(config, quo, call, fn) {
	spec <- ._read_spec(quo_get_expr(quo), call = call)
	if (is.null(spec)) {
		return(._new_override(quo, call = call, fn = fn))
	}
	._spec_override(spec, quo_get_env(quo), config, call = call, fn = fn)
}

# The columns a tidyselect expression selects: at least one
._eval_cols <- function(config, cols, call) {
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
	selected
}

# A `:=` spec, a function, or a single string sets the column's input or its
# arguments; any other value is the column's data, computed from the other
# columns.
._set_column <- function(config, name, quo, call, fn) {
	._private()
	label <- ._label(quo)
	data <- config@data
	spec <- ._read_spec(quo_get_expr(quo), call = call, list_is_args = FALSE)
	if (!is.null(spec)) {
		._check_column_exists(name, data, label, is.null(spec$input), call, fn)
		override <- ._spec_override(
			spec,
			quo_get_env(quo),
			config,
			call = call,
			fn = fn
		)
		return(._set_overrides(config, set_names(list(override), name)))
	}

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
		._check_keyword_symbol(quo, value, call = call)
		._check_column_exists(name, data, label, FALSE, call, fn)
		override <- ._override(value, quo, call = call, fn = fn)
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
	._modify(config, data = data, added = added, replaced = replaced)
}

# An input or its arguments are for a column the configuration has. `label` is
# the code that names them; `sets_args` says it sets arguments only.
._check_column_exists <- function(name, data, label, sets_args, call, fn) {
	if (name %in% names(data)) {
		return(invisible())
	}
	cli_abort(
		c(
			"Can't find column {.field {name}}.",
			x = if (sets_args) {
				"{.code {label}} sets arguments for an existing column's input."
			} else {
				"{.code {label}} chooses the input for an existing column."
			},
			i = "To add a column, compute it from the others: {.code {fn}(filters, {name} = <expression>)}."
		),
		call = call
	)
}

._set_overrides <- function(config, overrides) {
	._private()
	overrides_all <- config@overrides
	for (name in names(overrides)) {
		overrides_all[[name]] <- ._merge_override(config, name, overrides[[name]])
	}
	._modify(config, overrides = overrides_all)
}

# Arguments stay with their column: a new input keeps the ones it
# names, and the override's own arguments are added to them. An override
# without an input keeps the column's input. The function
# that updates an input stays with that input, until another one is named. A
# shinyWidgets input that has none named gets its own.
._merge_override <- function(config, name, override) {
	old <- config@overrides[[name]]
	input <- override$input
	fn <- override$fn
	label <- override$label
	args <- old$args
	update <- override$update
	if (is.null(input) && !is.null(old)) {
		input <- old$input
		fn <- old$fn
		label <- old$label
	} else if (length(args) > 0) {
		named <- ._override_arg_names(config, name, override)
		if (!is.null(named)) {
			args <- args[names(args) %in% named]
		}
	}
	if (is.null(update) && identical(input, old$input)) {
		update <- old$update
	}
	if (is.null(update) && is.function(input)) {
		update <- ._shinywidgets_update(input)
	}
	args[names(override$args)] <- override$args
	out <- list(input = input, args = args, fn = fn)
	if (length(args) == 0) {
		out$args <- NULL
	}
	out$label <- label
	out$update <- update
	out
}

# The arguments named by the input an override gives a column, or `NULL` when
# it may take any: a dry run can't tell which input it is, or it is a function
# with `...`. shiny's inputs don't count: they check their `...`, or pass them
# to an input whose arguments `._input_arg_names()` already includes.
._override_arg_names <- function(config, name, override) {
	overrides <- config@overrides
	overrides[[name]] <- override[c("input", "fn")]
	res <- ._dry_run(._modify(config, overrides = overrides), name)[[1]]
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
	label <- ._label(quo)
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
	._check_keyword_symbol(quo, input, call = call)
	._override(input, quo, call = call, fn = fn)
}

# An unquoted keyword that names a function, such as `range`, is a mistake:
# the function would be called as the input.
._check_keyword_symbol <- function(quo, input, call) {
	expr <- quo_get_expr(quo)
	if (!is_symbol(expr) || !is.function(input)) {
		return(invisible())
	}
	keyword <- as.character(expr)
	if (keyword %in% names(INPUT_KEYWORDS)) {
		cli_abort(
			c(
				"Can't use the function {.fn {keyword}} as an input.",
				i = "Keywords are strings: {.code \"{keyword}\"}."
			),
			call = call
		)
	}
}

# `quo` is the input as it was written, which labels a function.
._override <- function(input, quo, call, fn) {
	out <- list(input = resolve_filter_override(input, call = call), fn = fn)
	if (is.function(out$input)) {
		out$label <- ._fn_label(quo)
	}
	out
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
#' @param .filters A configuration created by [shinyfilters()].
#' @param ns The namespace: a string, used as the id passed to [shiny::NS()];
#'   a namespace created by [shiny::NS()]; or `NULL` to remove the namespace.
#'   [shinyfilters_server()] finds the inputs by it, so it is the full
#'   namespace of their ids.
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
with_ns <- function(.filters, ns) {
	if (missing(ns)) {
		cli_abort(
			"{.arg ns} must be supplied. Use {.code NULL} to remove the namespace."
		)
	}
	check_shinyfilters(.filters)
	if (is.function(ns)) {
		._check_valid_shiny_ns(ns)
	}
	._modify(.filters, ns = ns)
}

# Function: with_defaults() ####
#' Change the Default Arguments of a Configuration
#'
#' `with_defaults()` adds, replaces, or removes the arguments that a
#' configuration made by [shinyfilters()] passes to [filterInput()] for every
#' column.
#'
#' @param .filters A configuration created by [shinyfilters()].
#' @param ... Named arguments passed to [filterInput()] for every column, such
#'   as `textbox = TRUE` or `width = "200px"`. An argument set to `NULL`, or an
#'   input flag such as `slider` set to `FALSE`, [filterInput()]'s default, is
#'   removed. `selectize = FALSE` is kept: [shiny::selectInput()] takes it
#'   too. Arguments not named here keep their current values.
#'
#' @returns The updated configuration.
#'
#' @seealso [shinyfilters()], [with_filters()], [with_ns()]
#'
#' @examples
#' filters <- shinyfilters(nyc_flights, width = "200px")
#'
#' # Turn a default off
#' filters <- with_defaults(filters, slider = FALSE)
#' filters
#'
#' # Replace one
#' with_defaults(filters, width = "100%")
#'
#' # Remove one
#' with_defaults(filters, width = NULL)
#' @export
with_defaults <- function(.filters, ...) {
	check_shinyfilters(.filters)
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
	defaults <- .filters@args
	for (name in names(args)) {
		defaults[[name]] <- args[[name]]
	}
	defaults <- ._remove_default_flags(defaults)
	._modify(.filters, args = if (length(defaults) > 0) defaults else list())
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
		if (identical(input, ._keyword_fn(keyword))) {
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
	args <- ._keyword_args(list(...), override)
	do.call(filterInput, c(list(x = x), args))
}

# `args` with the `filterInput()` flags a keyword sets, and no other flag that
# is on. A flag that is off is left as it is, not set to `FALSE` or removed:
# `selectize = FALSE` is an argument of `selectInput()` too.
._keyword_args <- function(args, keyword) {
	is_on <- names(args) %in% INPUT_FLAGS & !vapply(args, isFALSE, logical(1))
	modifyList(args[!is_on], INPUT_KEYWORDS[[unclass(keyword)]]$args)
}

method(
	filter_input_override,
	list(
		class_character,
		class_input_area |
			class_input_radio |
			class_input_select |
			class_input_selectize |
			class_input_textbox
	)
) <- ._filter_input_keyword

method(
	filter_input_override,
	list(
		class_factor | class_logical | class_list,
		class_input_radio | class_input_select | class_input_selectize
	)
) <- ._filter_input_keyword

method(
	filter_input_override,
	list(class_numeric, class_input_numeric | class_input_slider)
) <- ._filter_input_keyword

method(
	filter_input_override,
	list(class_Date | class_POSIXt, class_input_date | class_input_range)
) <- ._filter_input_keyword

## Discrete choices for a column that isn't discrete ####
method(
	filter_input_override,
	list(
		class_any,
		class_input_radio | class_input_select | class_input_selectize
	)
) <- function(x, override, ...) {
	args <- ._keyword_args(list(...), override)
	choices <- ._coerced_choices(x, args, server = args$server)
	do.call(
		._call_input,
		c(list(._keyword_fn(override), choices), args)
	)
}

# The choices of a column coerced to a discrete input: its unique values in
# their own order, as the text `as_discrete()` gives them. Values with the same
# text are one choice.
._coerced_choices <- function(x, args, ...) {
	choices_asis <- isTRUE(args$choices_asis)
	choices <- ._discrete_choice_inputs(
		x,
		choices_asis = choices_asis,
		args_unique = args$args_unique,
		args_sort = args$args_sort,
		...
	)
	choices <- as_discrete(choices$choices)
	if (!choices_asis) {
		choices <- unique(choices)
	}
	list(choices = choices)
}

## Function ####
method(
	filter_input_override,
	list(class_any, class_function)
) <- function(x, override, ...) {
	._call_filter_input(x, override, ...)
}

## Unsupported keyword ####
._abort_unsupported_keyword <- function(x, override, ...) {
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

method(
	filter_input_override,
	list(class_any, class_input_keyword)
) <- ._abort_unsupported_keyword

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
