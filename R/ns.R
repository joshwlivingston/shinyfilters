resolve_ns <- new_generic("resolve_ns", "ns")

method(resolve_ns, class_any) <- function(ns, call = caller_env()) {
	resolve_ns(NS(ns), call = call)
}

method(resolve_ns, class_function) <- function(ns, call = caller_env()) {
	._check_valid_shiny_ns(ns, call = call)
	return(ns)
}
