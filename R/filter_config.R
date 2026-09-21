#' @export
as_filters <- function(
	data,
	area = FALSE,
	radio = FALSE,
	range = FALSE,
	selecitze = FALSE,
	slider = FALSE,
	textbox = FALSE,
	ns = NULL,
	choices_asis = FALSE,
	args_unique = list(),
	args_sort = list(),
	custom_dispatch_args = list(),
	custom_argument_args = list()
) {
	if (!is.list(custom_dispatch_args)) {
		stop("`custom_dispatch_args` must be a list")
	}
	if (!is.list(custom_argument_args)) {
		stop("`custom_argument_args` must be a list")
	}

	FilterConfig(
		data = data,
		dispatch_args = c(
			list(
				area = area,
				radio = radio,
				range = range,
				selecitze = selecitze,
				slider = slider,
				textbox = textbox,
				choices_asis = choices_asis,
				args_unique = args_unique,
				args_sort = args_sort
			),
			custom_dispatch_args,
			custom_argument_args
		),
		ns = ns
	)
}

method(filterInput, FilterConfig) <- function(x, ...) {
	if (!identical(list(...), list())) {
		warning(
			"! Ignorning arguments supplied to `filterInput()`\n",
			"  i Provide arguments to `as_filters()` instead\n",
			sprintf(
				"  * Ignored arguments:\n    * `%s`",
				paste0(names(list(...)), collapse = "`\n    * `")
			)
		)
	}
	out <- vector("list", ncol(x@data))
	names(out) <- names(x@data)

	args <- c(x@dispatch_args, list(ns = x@ns))
	nms <- names(x@filter_overrides)
	for (i in seq_along(x@filter_overrides)) {
		id <- nms[[i]]
		subset <- x@data[, id, drop = FALSE]
		override <- x@filter_overrides[[i]]
		out[nms[[i]]] <- filter_input_override(subset, override, id, args)
	}
	columns_original <- setdiff(names(x@data), nms)
	original <- x@data[, columns_original, drop = FALSE]
	out[columns_original] <- do.call(filterInput, c(args, list(x = original)))
	do.call(tagList, out)
}

filter_input_override <- new_generic(
	"filter_input_override",
	c("x", "override")
)
method(
	filter_input_override,
	list(class_data.frame, class_character)
) <- function(x, override, id, args) {
	x[[id]] <- TRANSFORMS[[override]](x[[id]])
	args_overridden <- modifyList(
		args,
		c(
			list(x = x),
			setNames(list(TRUE), override)
		)
	)
	do.call(filterInput, args_overridden)
}

method(
	filter_input_override,
	list(class_data.frame, class_function)
) <- function(x, override, id, args) {
	call_override <- function(col, id, label) {
		override_args <- list(
			x = col,
			override = override,
			args = c(args, list(inputId = id, label = label))
		)
		do.call(filter_input_override, override_args)
	}
	do.call(
		tagList,
		mapply(
			call_override,
			x,
			get_input_ids(x),
			get_input_labels(x),
			SIMPLIFY = FALSE
		)
	)
}

method(
	filter_input_override,
	list(class_atomic, class_function)
) <- function(x, override, id, args) {
	fun_transform <- TRANSFORMS_BY_FUN[[obj_address(override)]]
	if (!is.null(fun_transform)) {
		x <- fun_transform(x)
	}
	do.call(call_filter_input, c(list(x = x, .f = override), args))
}

#' @export
with_filter <- function(config, ...) {
	.with_filter(config, ...)
}

#' @rdname with_filter
#' @export
with_filters <- with_filter

.with_filter <- new_generic(".with_filter", c("config"))
method(.with_filter, FilterConfig) <- function(config, ...) {
	expressions <- enquos(...)
	nms <- names(expressions)
	if (is.null(nms) || all(nms == "")) {
		if (length(expressions) > 2) {
			stop(
				"`...` can only be any number of named arguments, or two unnamed arguments"
			)
		}
		ids <- resolve_id(expressions[[1]], config)
		filter_overrides <- resolve_filter_override(expressions[[2]])

		if (
			length(filter_overrides) != 1 &&
				!identical(length(filter_overrides), length(ids))
		) {
			stop(
				"If more than one override is provided, it must equal the length of the provided ids"
			)
		}

		out <- vector("list", length(ids))
		for (i in seq_along(out)) {
			out[[i]] <- filter_overrides
		}
		filter_overrides <- out
	} else {
		ids <- lapply(nms, resolve_id, config = config)

		id_not_found <- vapply(ids, is.null, logical(1L))
		if (any(id_not_found)) {
			stop(sprintf(
				"Invalid argument names provided:\n* `%s`",
				paste0(nms[id_not_found], collapse = "`\n* `")
			))
		}

		filter_overrides <- lapply(expressions, resolve_filter_override)
		override_not_found <- vapply(filter_overrides, is.null, logical(1L))
		if (any(override_not_found)) {
			stop(sprintf(
				"Invalid argument values provided for:\n* `%s`",
				paste0(nms[override_not_found], collapse = "`\n* `")
			))
		}
	}

	set_props(
		config,
		filter_overrides = modifyList(
			config@filter_overrides,
			setNames(filter_overrides, ids)
		)
	)
}

#' @export
id <- function(x) {
	x <- to_chr(x)
	structure(x, class = unique(c("shinyfilters_id", class(x))))
}

resolve_id <- new_generic("resolve_id", c("id", "config"))
method(resolve_id, list(class_character, FilterConfig)) <- function(
	id,
	config
) {
	if (length(id) == 0) {
		stop("`id` cannot be empty")
	}
	ids <- get_input_ids(config@data)
	if (length(id) == 1) {
		has_provided_class <- vapply(config@data, checker_function(id), logical(1L))
		if (any(has_provided_class)) {
			# 1 / 2
			# Matches the class of at least one obj in obj
			return(ids[has_provided_class])
		}
	} else if (length(setdiff(id, ids)) > 0) {
		stop(
			sprintf(
				"Provided ids are not found in data:\n* `%s`",
				paste0(setdiff(id, ids), collapse = "`\n* `")
			)
		)
	}

	if (all(id %in% ids)) {
		# 2 / 2
		# ID of the object provided
		return(id)
	}

	return(invisible())
}
method(resolve_id, list(class_shinyfilters_id, class_any)) <- function(
	id,
	config
) {
	ids <- get_input_ids(config@data)
	if (id %in% ids) {
		# 1 / 1
		# ID of the object provided
		return(unclass(id))
	}

	return(invisible())
}
method(resolve_id, list(NULL, class_any)) <- function(id, config) return(NULL)
method(resolve_id, list(class_quosure, FilterConfig)) <- function(id, config) {
	column <- as_label(id)
	if (!is.null(config@data[[column]])) {
		return(column)
	}
	res <- eval_tidy(id)
	resolve_id(res, config)
}

resolve_filter_override <- new_generic("resolve_filter_override", "override")
method(resolve_filter_override, class_character) <- function(override) {
	if (override %in% DISPATCH_KEYWORDS) {
		return(override)
	}
}
method(resolve_filter_override, class_function) <- function(override) {
	return(override)
}
method(resolve_filter_override, class_quosure) <- function(override) {
	override <- eval_tidy(override, as_data_mask(DISPATCH_KEYWORDS))
	resolve_filter_override(override)
}

checker_function <- function(id) {
	if (id == "numeric") {
		return(function(x) {
			inherits(x, "integer") || inherits(x, "numeric")
		})
	} else if (id == "double") {
		return(function(x) {
			typeof(x) == "double" && inherits(x, "numeric")
		})
	} else {
		return(function(x) inherits(x, id))
	}
}
