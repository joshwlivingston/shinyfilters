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
	if (!is.function(ns)) {
		stop(error_message_invalid_ns)
	}
	._check_valid_ns_function(ns)
}

._check_valid_ns_function <- function(ns) {
	if (!._is_valid_ns_function(ns)) {
		stop(error_message_invalid_ns)
	}
}

._is_valid_ns_function <- function(ns) {
	identical(
		functionBody(NS("x")),
		functionBody(value)
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
