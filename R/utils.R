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
	if (!._is_valid_ns_function(ns)) {
		cli_abort(
			"{.arg ns} must be the result of calling {.fn shiny::NS}.",
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

as_something <- new_generic(
	"as_something",
	c("x", "using"),
	fun = function(x, using) {
		S7_dispatch()
	}
)
method(as_something, list(class_atomic, class_function)) <- function(x, using) {
	error <- function(info) {
		cli_abort(
			c(
				sprintf("Unable to coerce to class %s", class(using(NA))),
				"*" = info
			),
			call = caller_env(3)
		)
	}

	res <- suppressWarnings(using(x))
	check_none_na(res, error)
	return(res)
}
method(as_something, list(class_list, class_function)) <- function(x, using) {
	res <- unlist(x)
	if (length(res) == length(x)) {
		return(as_something(res, using))
	}
	cli_abort(
		"Unable to coerce {.arg x} from {.cls list} to {.cls {class(using(NA))}}",
		call = caller_env(2)
	)
}

as_numeric <- function(x) {
	as_something(x, as.numeric)
}

as_character <- function(x) {
	as_something(x, as.character)
}

check_none_na <- function(x, error) {
	if (anyNA(x)) {
		error("NA's found after coercion")
	}
}
