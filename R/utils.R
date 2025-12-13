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
	if (any(names(value) == "")) {
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
			sprintf("No method found for `%s()` for class `%s`.", function_name, cls)
		)
	}
}

._check_valid_shiny_ns <- function(ns) {
	if (
		!is.function(ns) ||
			!identical(
				functionBody(shiny::NS("x")),
				functionBody(ns)
			)
	) {
		stop("`ns` must be the result of calling `shiny::NS()`.")
	}
}

# Generic: ._call_provided_f ####
._call_provided_f <- new_generic(
	name = "._call_provided_f",
	dispatch_args = c(".f", "args"),
	fun = function(.f, args = NULL, x, ...) {
		S7_dispatch()
	}
)

## Method: function, NULL ####
method(
	._call_provided_f,
	list(class_function, NULL)
) <- function(.f, args, x) {
	.f(x)
}

## Method: function, list ####
method(
	._call_provided_f,
	list(class_function, class_list)
) <- function(.f, args, x) {
	do.call(.f, c(list(x = x, args)))
}

set_names <- function(object = nm, nm) {
	names(object) <- nm
	return(object)
}

as_list_ <- function(x) {
	if (is.null(x)) {
		return(list(x))
	}
	return(as.list(x))
}
