# R/update_filter_config.R
#
# Update the inputs filterInput() creates for the columns of a shinyfilters
# object

## Method: updateFilterInput() ####
method(updateFilterInput, class_shinyfilters) <- function(x, ...) {
	._config_update_inputs(x, names(x@data), list(...), call = caller_env())
}

# Updates the inputs of `cols` from the configuration's data. `call` reaches
# `._config_update()` through a closure: a call object in `MoreArgs` is
# evaluated.
._config_update_inputs <- function(config, cols, args, call) {
	._check_update_fns(config, cols, call)
	args <- ._config_update_args(config, args)
	ids <- get_input_ids(config@data)[match(cols, names(config@data))]
	mapply(
		function(name, id) ._config_update(name, id, config, args, call),
		cols,
		ids,
		SIMPLIFY = FALSE
	)
}

# The configuration with its data filtered, which the server updates from
._config_filtered <- function(config, data) {
	the$allowed <- TRUE
	on.exit({
		the$allowed <- FALSE
	})
	set_props(config, data = data)
}

# The arguments every column's update gets: the configuration's defaults,
# except the ones that set a value, and the session. A namespaced id is
# complete, so it goes through the root session.
._config_update_args <- function(config, args) {
	defaults <- config@args[!(names(config@args) %in% VALUE_ARGS)]
	args <- modifyList(defaults, args)
	session <- args$session
	if (is.null(session)) {
		session <- getDefaultReactiveDomain()
	}
	if (!is.null(session) && !is.null(config@ns)) {
		session <- session$rootScope()
	}
	args$session <- session
	args
}

# The arguments that set an input's value. An update leaves the value alone.
VALUE_ARGS <- c("value", "selected", "start", "end")

# Updates the input for one column of a shinyfilters config
._config_update <- function(name, id, config, args, call) {
	col <- config@data[[name]]
	if (!is.null(config@ns)) {
		id <- ._resolve_ns(config@ns)(id)
	}
	col_args <- c(
		list(x = col),
		set_names(list(id), do.call(arg_name_input_id, c(list(col), args))),
		args
	)
	override <- config@overrides[[name]]
	input_args <- override$args[!(names(override$args) %in% VALUE_ARGS)]
	if (length(input_args) > 0) {
		col_args[[INPUT_ARGS]] <- ._input_args(input_args, config, name, call)
	}
	try_fetch(
		if (!is.null(override$update)) {
			do.call(
				._call_update_filter_input,
				c(col_args, list(.f = override$update$fn))
			)
		} else if (is.null(override$input)) {
			do.call(updateFilterInput, col_args)
		} else {
			do.call(
				update_filter_input_override,
				c(col_args, list(override = override$input))
			)
		},
		error = function(cnd) {
			._resignal_silent(cnd)
			cli_abort(
				"Can't update the input for column {.field {name}}.",
				parent = cnd,
				call = call
			)
		}
	)
}

# An input set by a function can be updated when it is a shiny input, or
# `as_filter()` named the function that updates it.
._check_update_fns <- function(config, cols, call) {
	unknown <- vapply(
		cols,
		function(name) {
			override <- config@overrides[[name]]
			is.function(override$input) &&
				is.null(override$update) &&
				is.null(._update_fn(override$input))
		},
		logical(1)
	)
	if (any(unknown)) {
		cols <- cols[unknown]
		cli_abort(
			c(
				"Can't update the input for column{?s} {.field {cols}}.",
				x = "{qty(cols)}{?Its/Their} input{?s} {?is/are} set by {?a function/functions} with no known update function.",
				i = "Name one with {.code as_filter(<input>, .update_fn = <function>)}."
			),
			call = call
		)
	}
}

# The shiny function that updates an input, or `NULL` for any other function
._update_fn <- function(fn) {
	switch(
		._input_name(fn),
		dateInput = updateDateInput,
		dateRangeInput = updateDateRangeInput,
		numericInput = updateNumericInput,
		radioButtons = updateRadioButtons,
		selectInput = updateSelectInput,
		selectizeInput = updateSelectizeInput,
		sliderInput = updateSliderInput,
		textAreaInput = updateTextAreaInput,
		textInput = updateTextInput
	)
}

# Generic: update_filter_input_override() ####
#
# Mirrors `filter_input_override()`: the same signatures choose the update
# that matches the input.
update_filter_input_override <- new_generic(
	"update_filter_input_override",
	c("x", "override")
)

## Keyword flags supported by updateFilterInput() ####
._update_filter_input_keyword <- function(x, override, ...) {
	args <- modifyList(list(...), ._keyword_flags(override))
	do.call(updateFilterInput, c(list(x = x), args))
}

method(
	update_filter_input_override,
	list(
		class_character,
		class_input_area |
			class_input_radio |
			class_input_selectize |
			class_input_textbox
	)
) <- ._update_filter_input_keyword

method(
	update_filter_input_override,
	list(
		class_factor | class_logical | class_list,
		class_input_radio | class_input_selectize
	)
) <- ._update_filter_input_keyword

method(
	update_filter_input_override,
	list(class_numeric, class_input_slider)
) <- ._update_filter_input_keyword

method(
	update_filter_input_override,
	list(class_Date | class_POSIXt, class_input_range)
) <- ._update_filter_input_keyword

## Numeric discrete choices ####
method(
	update_filter_input_override,
	list(class_numeric, class_input_radio | class_input_selectize)
) <- function(x, override, ...) {
	args <- list(...)
	choices <- ._discrete_choice_inputs(
		x,
		choices_asis = isTRUE(args$choices_asis),
		args_unique = args$args_unique,
		args_sort = args$args_sort
	)
	update <- ._update_fn(INPUT_KEYWORDS[[unclass(override)]]$fn)
	._call_update_input(update, choices, ...)
}

## Function ####
method(
	update_filter_input_override,
	list(class_any, class_function)
) <- function(x, override, ...) {
	._call_update_filter_input(x, ._update_fn(override), ...)
}
