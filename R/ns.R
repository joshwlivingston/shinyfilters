._resolve_ns <- new_generic("._resolve_ns", "ns")

method(._resolve_ns, class_any) <- function(ns, call = caller_env()) {
	._resolve_ns(NS(ns), call = call)
}

method(._resolve_ns, class_function) <- function(ns, call = caller_env()) {
	._check_valid_shiny_ns(ns, call = call)
	return(ns)
}

# The session whose `input` holds a configuration's inputs by column name
._config_session <- function(config, session) {
	if (is.null(config@ns) || is.null(session)) {
		return(session)
	}
	session$rootScope()$makeScope(._resolve_ns(config@ns)(character()))
}

._apply_ns <- function(ns, ..., call = caller_env()) {
	ns <- ._resolve_ns(ns, call = call)
	args <- list(...)

	input_id_column <- arg_name_input_id(args$x)
	if (is.null(input_id_column)) {
		cli_abort(
			"{.code arg_name_input_id(x)} must not return {.code NULL} when {.arg ns} is provided.",
			call = call
		)
	}
	if (is.null(args[[input_id_column]])) {
		cli_abort(
			"{.arg {input_id_column}} is required when {.arg ns} is provided.",
			call = call
		)
	}

	args[[input_id_column]] <- ns(args[[input_id_column]])
	return(args)
}
