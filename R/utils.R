# R/utils.R
#
# Utility functions used throughout package

check_named_list_or_null <- function(value) {
	if (is.null(value)) {
		return(invisible())
	}
	if (!is.list(value)) {
		stop("Value must be a NULL or a list.")
	}
	if (is.null(names(value)) || any(names(value) == "")) {
		stop("All list elements must be named.")
	}
	if (!identical(names(value), unique(names(value)))) {
		stop("All list names must be unique.")
	}
}

s7_check_is_valid_list_dispatch <- function(x, function_name) {
	cls <- S7_class(x)
	if (!is.null(cls)) {
		stop(
			sprintf(
				"No method found for `%s()` for class `%s`.",
				function_name,
				cls@name
			)
		)
	}
}

._check_valid_shiny_ns <- function(ns) {
	if (
		!is.function(ns) ||
			!identical(
				functionBody(NS("x")),
				functionBody(ns)
			)
	) {
		stop("`ns` must be the result of calling `shiny::NS()`.")
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

check_is_nonempty_string <- function(x) {
	if (
		!identical(length(x), 1L) ||
			is.null(x) ||
			is.na(x) ||
			!is.character(x) ||
			identical(x, "")
	) {
		stop(sprintf("`%s` must be a non-empty string", deparse(substitute(x))))
	}
}
