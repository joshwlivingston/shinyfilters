# Function: ._prepare_input_args ####
._prepare_input_args <- function(x, ...) {
	args_provided <- list(...)
	args <- do.call(
		args_filter_input,
		c(list(x = x), args_provided)
	)

	check_named_list_or_null(args)
	if (any(names(args_provided) %in% names(args))) {
		error_input_args(x, names(args))
	}

	return(args)
}

# Function: ._prepare_update_input_args ####
._prepare_update_input_args <- function(x, ...) {
	args_provided <- list(...)
	args <- do.call(
		args_update_filter_input,
		c(list(x = x), args_provided)
	)
	check_named_list_or_null(args)
	return(args)
}

# Function: error_input_args ####
error_input_args <- function(x, unsupported_args) {
	vector_class <- class(x)[[1L]]
	multiple_unsupported_args <- isTRUE(length(unsupported_args) > 1L)
	stop(
		sprintf(
			paste0(
				"The argument%s `%s`%s",
				"%s not supported in when used with `%s` objects."
			),
			if (multiple_unsupported_args) "s\n -" else "",
			paste0(unsupported_args, collapse = "`\n - `"),
			if (multiple_unsupported_args) "\n" else " ",
			if (multiple_unsupported_args) "are" else "is",
			vector_class
		)
	)
}
