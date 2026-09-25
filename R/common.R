# Function: ._prepare_input_args ####
._prepare_input_args <- function(x, ..., call = caller_env()) {
	args_provided <- list(...)
	args <- do.call(
		args_filter_input,
		c(list(x = x), args_provided)
	)

	check_named_list_or_null(
		args,
		arg = "args_filter_input(x)",
		call = call
	)
	if (any(names(args_provided) %in% names(args))) {
		error_input_args(
			x,
			intersect(names(args_provided), names(args)),
			call = call
		)
	}

	return(args)
}

# Function: ._prepare_update_input_args ####
._prepare_update_input_args <- function(x, ..., call = caller_env()) {
	args_provided <- list(...)
	args <- do.call(
		args_update_filter_input,
		c(list(x = x), args_provided)
	)
	check_named_list_or_null(
		args,
		arg = "args_update_filter_input(x)",
		call = call
	)
	return(args)
}

# Function: error_input_args ####
error_input_args <- function(x, unsupported_args, call = caller_env()) {
	vector_class <- class(x)[[1L]]
	cli_abort(
		"The {qty(unsupported_args)}argument{?s} {.arg {unsupported_args}} {?is/are} not supported with {.cls {vector_class}} objects.",
		call = call
	)
}
