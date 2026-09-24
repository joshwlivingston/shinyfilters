# R/utils.R
#
# Utility functions used throughout package

check_named_list_or_null <- function(
	value,
	arg = caller_arg(value),
	call = caller_env()
) {
	if (is.null(value)) {
		return(invisible())
	}
	if (!is.list(value)) {
		cli_abort(
			"{.arg {arg}} must be a {.cls list} or {.code NULL}, not {.obj_type_friendly {value}}.",
			call = call
		)
	}
	if (is.null(names(value)) || any(names(value) == "")) {
		cli_abort("All elements of {.arg {arg}} must be named.", call = call)
	}
	if (!identical(names(value), unique(names(value)))) {
		cli_abort("All names in {.arg {arg}} must be unique.", call = call)
	}
}

s7_check_is_valid_list_dispatch <- function(
	x,
	function_name,
	call = caller_env()
) {
	cls <- S7_class(x)
	if (!is.null(cls)) {
		cli_abort(
			"No {.fn {function_name}} method found for class {.cls {cls@name}}.",
			call = call
		)
	}
}

._check_valid_shiny_ns <- function(ns, call = caller_env()) {
	if (
		!is.function(ns) ||
			!identical(
				functionBody(NS("x")),
				functionBody(ns)
			)
	) {
		cli_abort(
			"{.arg ns} must be the result of calling {.fn shiny::NS}.",
			call = call
		)
	}
}

set_names <- function(object = nm, nm) {
	names(object) <- nm
	return(object)
}

all_trues <- function(x) {
	all_something(x, TRUE)
}

all_something <- function(x, something) {
	rep(something, len(x))
}

len <- function(x) {
	len <- dim(x)[[1]]
	if (is.null(len)) {
		len <- length(x)
	}
	return(len)
}

check_is_nonempty_string <- function(
	x,
	arg = caller_arg(x),
	call = caller_env()
) {
	if (
		!identical(length(x), 1L) ||
			is.null(x) ||
			is.na(x) ||
			!is.character(x) ||
			identical(x, "")
	) {
		cli_abort(
			"{.arg {arg}} must be a single non-empty string, not {.obj_type_friendly {x}}.",
			call = call
		)
	}
}
