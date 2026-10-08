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

check_shinyfilters <- function(x, arg = caller_arg(x), call = caller_env()) {
	if (!S7_inherits(x, class_shinyfilters)) {
		cli_abort(
			"{.arg {arg}} must be created by {.fn shinyfilters}, not {.obj_type_friendly {x}}.",
			call = call
		)
	}
}

s7_check_is_valid_list_dispatch <- function(x, function_name) {
	cls <- S7_class(x)
	if (!is.null(cls)) {
		# Build the call from the name: older S7 dispatch inlines the generic and
		# object into the frame's call, which can't be deparsed on R < 4.
		cli_abort(
			"No {.fn {function_name}} method found for class {.cls {cls@name}}.",
			call = call2(function_name)
		)
	}
}

._check_valid_shiny_ns <- function(ns, call = caller_env()) {
	if (!._is_valid_ns_function(ns)) {
		cli_abort(
			"{.arg ns} must not be a custom function.",
			call = call
		)
	}
}

._is_valid_ns_function <- function(ns) {
	is.function(ns) &&
		identical(
			functionBody(NS("x")),
			functionBody(ns)
		)
}

# Marks the function that calls it as private: that function errors unless
# package code called it, so `shinyfilters:::fn()` fails in user code. A private
# function must be called directly: passed to `lapply()`, its caller is base R.
._private <- function() {
	if (identical(topenv(parent.frame(2)), topenv(environment()))) {
		return(invisible())
	}
	cli_abort(
		c(
			"This function is internal to {.pkg shinyfilters}.",
			i = "Change a {.cls shinyfilters} object with {.fn with_filters}, {.fn with_args}, {.fn with_defaults}, or {.fn with_ns}."
		),
		call = parent.frame()
	)
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

# Register an S3 method for a generic owned by a suggested package.
#
# NAMESPACE's delayed `S3method(pkg::generic, class)` form only works from
# R 3.6.0 ("Writing R Extensions", 1.5.2), and this package supports R 3.5, so
# the methods for dplyr, tibble, and data.table generics are registered here
# instead. Modelled on the `s3_register()` helper vctrs documents for reuse.
._s3_register <- function(generic, class, method) {
	pieces <- strsplit(generic, "::", fixed = TRUE)[[1]]
	package <- pieces[[1]]
	generic <- pieces[[2]]

	register <- function(...) {
		registerS3method(generic, class, method, envir = asNamespace(package))
	}

	setHook(packageEvent(package, "onLoad"), register)
	if (isNamespaceLoaded(package)) {
		register()
	}

	invisible()
}

deprecated <- function() {
	missing_arg()
}
