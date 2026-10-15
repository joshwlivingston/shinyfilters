# Subsetting in shinyfilters
#
# Subsetting a shinyfilters object is designed to facilitate easy selection of
# filters by different attributes. This is a common task when building a
# sidebar with a lot of filters, where filters are often hierarchically
# organized.
#
# The fastest way to support this is to implement tidyselect and add it as a
# dependency. However, tidyselect has a particular way of evaluating
# expressions, one that isn't a perfect fit for shinyfilters.
#
# For selection, shinyfilters implements methods for `[` and `[[`. They select
# filters the same way; the difference is that `[[` also calls `filterInput()`.
#
# Selection also occurs inside `with_filters()`. There, all arguments are
# are parsed by amtching one of these patterns:
#
# <column> = <input-keyword>
# <column> = <input-function>(<arg>*)
# <column> = set_filter(<input>*, <arg>*)
# <columns> ~ <input-keyword>
# <columns> ~ <input-function>(<arg>*)
# <columns> ~ set_filter(<input>*, <arg>*)
#
# where:
#
# <column> is a valid column name.
# <columns> is a valid column selection expression.
# <input-function> is a valid shiny input function.
# <input> is a valid input expression.
# <arg> is a valid argument expression.
# [X] OR [Y] means X, Y, or X and Y.
# X* means 0 or more X.
# set_filter() is a utility for argument-only expressions.
#
# Examples
#
# dep_delay ~ sliderInput(value = range(.x), step = 5, label = "Dep Delay")
# where(is.numeric) ~ "slider"
# c(origin, dest) ~ set_args(choices = sort(unique(.x), decreasing = TRUE))
#
# Each <tag>'s validity is enforced through its own function.
#
# <columns> | parse_expr_column()
# <input>   | parse_expr_input()
# <arg>     | parse_expr_arg()
#
# parse_expr_column() is what is used inside `[` and `[[` as well.
#
# parse_expr_column()
#
# A column expression is valid when:
#
# 1. It is a singular quoted or unquoted column name
# 2. A vector or list of column names, quoted or unquoted, created by c()
#    (or list()).
#  * Note: this step does not include nyc_flights[c(dep_delay, origin)] but not
#    nyc_flights[x], where x <- c("dep_delay", "origin")
# It evaluates as a recyclable logical.
# It is a character vector of valid column names.
# It is a valid predicate function (inspiration from tidyselect).
# It evaluates as a numeric vector of column indices.
#
# The following operations are supported
#
# X:Y
# Sequence from X to Y.
# X and Y are valid scalar column expressions, but cannot be a predicate function.
#
# !X
# Not X.
# X is a valid column expression.
#
# -X
# Same as !X, except as an element of c() or list().
# -X:Y is read as -(X:Y), not (-X):Y.
#
# c(X, -Y, !Z)
# Elements apply left to right.
# -Y removes Y from the columns selected so far. When it comes first, it
# removes Y from every column.
# !Z adds every column that isn't Z.
#
# X & Y
# The intersection of X and Y.
# X and Y are valid column expressions.
#
# X | Y
# The intersection of X and Y.
# X and Y are valid column expressions.
#
# (X | Y) & Z
# X and Z, Y and Z, or X, Y, and Z.
# X, Y, and Z are valid column expressions.
`[.shinyfilters::shinyfilters` <- function(x, i, ...) {
	call <- sys.call()
	call[[1]] <- as.name("[")
	if (...length()) {
		cli_abort(
			c(
				"Can't subset a {.cls shinyfilters} object by rows and columns.",
				i = "Select columns with {.code x[cols]}."
			),
			call = call
		)
	}
	if (missing(i)) {
		return(x)
	}
	._filter_select(x, substitute(i), call)
}

`[[.shinyfilters::shinyfilters` <- function(x, i, ...) {
	call <- sys.call()
	call[[1]] <- as.name("[[")
	if (...length()) {
		cli_abort(
			c(
				"Can't subset a {.cls shinyfilters} object by rows and columns.",
				i = "Select columns with {.code x[cols]}."
			),
			call = call
		)
	}
	if (missing(i)) {
		return(x)
	}
	selection <- ._filter_select(x, substitute(i), call)
	inputs <- filterInput(selection)
	if (length(inputs) == 1) {
		# One column gives its input, as `$` does.
		return(inputs[[1]])
	}
	inputs
}

._filter_select <- function(
	.filters,
	expr,
	call = there(),
	env = parent.frame(2)
) {
	mask <- names(.filters@data)
	res <- ._parse_expr_column(expr, mask, .filters@data, call, env)
	._modify(
		.filters,
		data = .filters@data[, res, drop = FALSE]
	)
}

._parse_expr_column <- function(expr, mask, data, call, env) {
	if (is.null(expr)) {
		return(character(0))
	}

	if (is.atomic(expr) && length(expr) == 1 && is.na(expr)) {
		cli_abort(c("Selections can't have missing values."), call = call)
	}

	if (is.symbol(expr)) {
		char <- as.character(expr)
		if (char %in% mask) {
			return(char)
		}
		if (is.null(get0(char, env))) {
			cli_abort("Column {.code {char}} doesn't exist.", call = call)
		}
	}

	# A single column name as a string
	if (is.character(expr) && length(expr) == 1) {
		if (expr == "") {
			cli_abort(
				c(
					"Can't select columns.",
					"i" = "Cannot select an empty string ({.val }).",
					"*" = "Selection {.code {deparse(expr)}} is an empty string."
				),
				call = call
			)
		}
		if (expr %in% mask) {
			return(expr)
		}
	}

	if (is.numeric(expr)) {
		# A numeric index
		expr_int <- as.integer(expr)
		is_rounded <- as.numeric(expr_int) != expr
		if (is_rounded) {
			cli_abort(
				c(
					"Indices must be whole numbers.",
					"*" = "Got {.code {expr}}."
				),
				call = call
			)
		}
		if (expr <= length(mask)) {
			return(mask[expr])
		}
		cli_abort(
			c(
				"Can't select columns past the end.",
				"i" = "Column {expr} doesn't exist.",
				"i" = "There are only {length(mask)} columns."
			),
			call = call
		)
	}

	if (is.logical(expr)) {
		# A boolean
		return(mask[expr])
	}

	res <- NULL
	if (is.call(expr)) {
		switch(
			function_name(expr),
			"(" = return(._parse_expr_column(expr[[2]], mask, data, call, env)),
			"-" = {
				if (length(expr) == 2) {
					# unary
					return(mask[
						!mask %in% ._parse_expr_column(expr[[2]], mask, data, call, env)
					])
				}
				# binary
				lhs <- eval(expr[[2]], env)
				rhs <- eval(expr[[3]], env)
				return(lhs - rhs)
			},
			"/" = {
				lhs <- ._parse_expr_column(expr[[2]], mask, data, call, env)
				rhs <- ._parse_expr_column(expr[[3]], mask, data, call, env)
				return(lhs[!lhs %in% rhs])
			},
			"c" = ,
			"list" = {
				# Bare c() or list() selects nothing
				if (length(expr) == 1) {
					return(character(0))
				}
				elements <- c_elements(expr)
				is_lgl <- vapply(elements, is.logical, logical(1))
				if (all(is_lgl)) {
					return(mask[unlist(elements)])
				}
				if (any(is_lgl)) {
					cli_abort(
						c(
							"Can't select columns with {.code {deparse(expr)}}.",
							"x" = "Logical values can't be combined with other selections."
						),
						call = call
					)
				}
				if (
					all(vapply(
						elements,
						function(x) is.character(x) || is.symbol(x),
						logical(1)
					))
				) {
					cols <- as.character(unlist(elements))
					missing_lgl <- !cols %in% mask
					missing <- cols[missing_lgl]
					if (length(missing) == 0) {
						return(unique(cols))
					}
					blanks <- cols[cols == ""]
					if (length(blanks) > 0) {
						cli_abort(
							c(
								"Can't select columns.",
								"i" = "Cannot select an empty string ({.val }).",
								"*" = format_inline(
									"Selection {.code {deparse(expr)}} contains {length(blanks)} empty string{?s}."
								)
							),
							call = call
						)
					}
					bad <- vapply(elements, is.character, logical(1L)) & missing_lgl
					if (any(bad)) {
						cli_abort(
							"Column{?s} {.code {cols[bad]}} {?doesn't/don't} exist.",
							call = call
						)
					}
				}
				selected <- if (is_minus(elements[[1]])) mask else character(0)
				for (i in seq_along(elements)) {
					selected <- if (is_minus(elements[[i]])) {
						# when - is used, take the set difference
						# this means c(dep_delay, -carrier) returns dep_delay
						#
						# to return dep_delay followed by anything not carrier, use !
						# c(dep_delay, !carrier)
						selected[
							!selected %in%
								._parse_expr_column(
									strip_minus(elements[[i]]),
									mask,
									data,
									call,
									env
								)
						]
					} else {
						# standard path: accumulate selections via union
						unique(c(
							selected,
							._parse_expr_column(elements[[i]], mask, data, call, env)
						))
					}
				}
				return(selected)
			},
			":" = {
				# `-X:Y` is parsed by R as `(-X):Y`
				# For selection, we read it here as `-(X:Y)`
				if (is_minus(expr)) {
					return(mask[
						!mask %in%
							._parse_expr_column(strip_minus(expr), mask, data, call, env)
					])
				}
				from <- ._parse_expr_column(expr[[2]], mask, data, call, env)
				to <- ._parse_expr_column(expr[[3]], mask, data, call, env)
				if (length(from) == 1 && length(to) == 1) {
					return(mask[match(from, mask):match(to, mask)])
				}
				abort_select_colon(from, to, expr, call)
			},
			"&" = {
				res_lhs <- ._parse_expr_column(expr[[2]], mask, data, call, env)
				res_rhs <- ._parse_expr_column(expr[[3]], mask, data, call, env)
				if (
					length(res_lhs) == 1 && length(res_rhs) == 1 && res_lhs != res_rhs
				) {
					cli_abort(
						c(
							"Can't take the intersection of two distinct columns",
							"i" = "{.code {deparse(expr)}} is always an empty selection."
						),
						call = call
					)
				}
				return(res_lhs[res_lhs %in% res_rhs])
			},
			"|" = return(unique(c(
				._parse_expr_column(expr[[2]], mask, data, call, env),
				._parse_expr_column(expr[[3]], mask, data, call, env)
			))),
			"!" = return(mask[
				!mask %in% ._parse_expr_column(expr[[2]], mask, data, call, env)
			]),
			"starts_with" = {
				if (length(expr) > 2) {
					cli_abort("too many argument starts_with", call = call)
				}
				if (!is.character(expr[[2]])) {
					cli_abort("starts_with must be a single string", call = call)
				}
				return(grep(paste0("^", expr[[2]]), mask, value = TRUE))
			},
			"ends_with" = {
				if (length(expr) > 2) {
					cli_abort("too many argument ends_with", call = call)
				}
				if (!is.character(expr[[2]])) {
					cli_abort("ends_with must be a single string", call = call)
				}
				return(grep(paste0(expr[[2]], "$"), mask, value = TRUE))
			},
			"contains" = {
				if (length(expr) > 2) {
					cli_abort("too many argument contains", call = call)
				}
				if (!is.character(expr[[2]])) {
					cli_abort("contains must be a single string", call = call)
				}
				return(grep(expr[[2]], mask, value = TRUE))
			},
			"matches" = {
				if (length(expr) > 2) {
					cli_abort("too many argument matches", call = call)
				}
				if (!is.character(expr[[2]])) {
					cli_abort("matches must be a single string", call = call)
				}
				return(grep(paste0("^", expr[[2]], "$"), mask, value = TRUE))
			},
			"num_range" = {
				if (length(expr) > 3) {
					cli_abort("too many argument num_range", call = call)
				}

				char <- expr[[2]]
				if (is.symbol(char)) {
					char <- as.character(char)
				} else if (!is.character(char)) {
					cli_abort("not coercible to character num_range", call = call)
				}
				if (!is.numeric(expr[[3]])) {
					cli_abort("num_range must be a numeric vector", call = call)
				}

				cols <- paste0(char, expr[[3]])
				missing <- cols[!cols %in% mask]
				if (length(missing) == 0) {
					return(cols)
				}
				cli_abort(
					"Column{?s} {.code {missing}} {?doesn't/don't} exist.",
					call = call
				)
			},
			"all_of" = {
				if (length(expr) != 2) {
					cli_abort(
						c(
							"{.fn all_of} takes exactly one argument.",
							"i" = "Got {.code {deparse(expr)}}."
						),
						call = call
					)
				}
				res <- eval(expr[[2]], env)
				if (!is.character(res) && !is.numeric(res)) {
					cli_abort(
						"{.fn all_of} needs a character or numeric vector, not {.obj_type_friendly {res}}.",
						call = call
					)
				}
				if (is.numeric(res)) {
					is_negative <- res < 0
					if (any(is_negative)) {
						n <- sum(is_negative)
						val <- res[is_negative]
						loc <- which(is_negative)
						cli_abort(
							c(
								"Selections provided to {.fn all_of} can't be negative.",
								"i" = "{.code {deparse(expr[[2]])}} contains {n} negative value{?s}.",
								"*" = "{qty(length(val))}Invalid value{?s}: {val}.",
								"*" = "{qty(length(loc))}Location{?s}: {loc}."
							),
							call = call
						)
					}
				}
			},
			"any_of" = {
				if (length(expr) != 2) {
					cli_abort(
						c(
							"{.fn any_of} takes exactly one argument.",
							"i" = "Got {.code {deparse(expr)}}."
						),
						call = call
					)
				}
				res <- eval(expr[[2]], env)
				if (!is.character(res) && !is.numeric(res)) {
					cli_abort(
						"{.fn any_of} needs a character or numeric vector, not {.obj_type_friendly {res}}.",
						call = call
					)
				}
				if (anyNA(res)) {
					missing <- is.na(res)
					n <- sum(missing)
					loc <- which(missing)
					cli_abort(
						c(
							"Selections can't have missing values.",
							"i" = "Got {.code {deparse(expr)}}.",
							"*" = "{.code {deparse(expr[[2]])}} {qty(n)} {?is a/has {n}} missing value{?s}.",
							if (n > 1) c("*" = "{qty(length(loc))}Location{?s}: {loc}.")
						),
						call = call
					)
				}
				if (is.numeric(res)) {
					is_negative <- res < 0
					if (any(is_negative)) {
						n <- sum(is_negative)
						val <- res[is_negative]
						loc <- which(is_negative)
						cli_abort(
							c(
								"Selections provided to {.fn any_of} can't be negative.",
								"i" = "{.code {deparse(expr[[2]])}} contains {n} negative value{?s}.",
								"*" = "{qty(length(val))}Invalid value{?s}: {val}.",
								"*" = "{qty(length(loc))}Location{?s}: {loc}."
							),
							call = call
						)
					}
					res_int <- as.integer(res)
					is_rounded <- as.numeric(res_int) != res
					if (any(is_rounded)) {
						val <- res[is_rounded]
						loc <- which(is_rounded)
						cli_abort(
							c(
								"Indices must be whole numbers.",
								"*" = "Got {.code {deparse(expr)}}.",
								"*" = "{qty(length(val))}Invalid value{?s}: {val}.",
								"*" = "{qty(length(loc))}Location{?s}: {loc}."
							),
							call = call
						)
					}
					return(mask[res[res <= length(mask)]])
				}
				return(mask[mask %in% res])
			},
			"everything" = return(mask),
			"last_col" = return(mask[length(mask)]),
			"where" = {
				.f <- eval(expr[[2]], env)
				res <- lapply(data, .f)
				if (all(lengths(res) == 1)) {
					res_lgl <- suppressWarnings(as.logical(unlist(res)))
					if (!anyNA(res_lgl)) {
						# logical vector
						return(mask[res_lgl])
					}
				}
				cli_abort(
					c(
						"Predicate must return {.code TRUE}, {.code FALSE}.",
						"i" = "Got {.code {deparse(expr)}}."
					),
					call = call
				)
			},
			NULL
		)
	}

	if (is.null(res)) {
		res <- eval(expr, env)
	}

	if (is.atomic(res)) {
		if (anyNA(res)) {
			missing <- is.na(res)
			n <- sum(missing)
			loc <- which(missing)
			cli_abort(
				c(
					"Selections can't have missing values.",
					"i" = "Got {.code {deparse(expr)}}.",
					"*" = "{.code {deparse(expr[[2]])}} {qty(n)} {?is a/has {n}} missing value{?s}.",
					if (n > 1) c("*" = "{qty(length(loc))}Location{?s}: {loc}.")
				),
				call = call
			)
		}

		if (!is.null(names(res))) {
			has_name <- names(res) != ""
			if (any(has_name)) {
				named <- res[has_name]
				renames <- names(res)[has_name]
				cli_abort(
					c(
						"Can't rename filters.",
						"i" = "Got {.code {deparse(expr)}}.",
						"*" = "Rename {.code {named}} to {.code {renames}} before calling {.fn shinyfilters}."
					),
					call = call
				)
			}
		}
	}

	if (is.function(res)) {
		.f <- res
		res <- .f(data)
		if (all(lengths(res) == 1)) {
			res_char <- suppressWarnings(as.character(res))
			if (!anyNA(res_char)) {
				# character vector
				missing <- res_char[!res_char %in% mask]
				if (length(missing) == 0) {
					return(unique(res_char))
				}
				cli_abort(c("Bad!"), call = call)
			}

			res_lgl <- suppressWarnings(as.logical(res))
			if (!anyNA(res_lgl)) {
				# logical vector
				return(mask[res_lgl])
			}
		}

		cli_abort(
			c(
				"Predicate must return a {.cls logical} or {.cls character} vector, not {.obj_type_friendly {res}}."
			),
			call = call
		)
	}

	if (is.character(res)) {
		missing <- res[!res %in% mask]
		if (length(missing) == 0) {
			return(unique(res))
		}
		blanks <- res[res == ""]
		if (length(blanks) > 0) {
			cli_abort(
				c(
					"Can't select columns.",
					"i" = "Cannot select an empty string ({.val }).",
					"*" = format_inline(
						"Selection {.code {deparse(expr)}} {qty(blanks)} {?is an/contains {length(blanks)}} empty string{?s}."
					)
				),
				call = call
			)
		}
		cli_abort(
			"Column{?s} {.code {missing}} {?doesn't/don't} exist.",
			call = call
		)
	}

	if (is.numeric(res)) {
		# A numeric index
		res_int <- as.integer(res)
		is_rounded <- as.numeric(res_int) != res
		if (any(is_rounded)) {
			val <- res[is_rounded]
			loc <- which(is_rounded)
			cli_abort(
				c(
					"Indices must be whole numbers.",
					"*" = "Got {.code {deparse(expr)}}.",
					"*" = "{qty(length(val))}Invalid value{?s}: {val}.",
					"*" = "{qty(length(loc))}Location{?s}: {loc}."
				),
				call = call
			)
		}
		res_oob <- as.character(res[res > length(mask)])
		if (length(res_oob) == 0) {
			return(mask[res])
		}
		cli_abort(
			c(
				"Can't select columns past the end.",
				"i" = "Column{?s} {res_oob} {?doesn't/don't} exist.",
				"i" = "There are only {length(mask)} columns."
			),
			call = call
		)
	}

	if (is.logical(res)) {
		# A logical vector
		return(mask[res])
	}

	# Return empty character vector if no matching columns found
	cli_abort(
		c(
			"Unable to parse selection.",
			"i" = "Got {.code {deparse(expr)}}."
		),
		call = call
	)
}

# Replace nested `c()`, `list()`, or `(` by its own elements
c_elements <- function(expr) {
	elements <- as.list(expr[-1])
	out <- list()
	for (i in seq_along(elements)) {
		nested <- is.call(elements[[i]]) &&
			length(elements[[i]]) > 1 &&
			function_name(elements[[i]]) %in% c("c", "list", "(")
		out <- c(out, if (nested) c_elements(elements[[i]]) else elements[i])
	}
	out
}

is_minus <- function(expr) {
	if (!is.call(expr)) {
		return(FALSE)
	}
	name <- function_name(expr)
	if (name == "-" && length(expr) == 2) {
		return(TRUE)
	}
	name == ":" && is_minus(expr[[2]])
}

strip_minus <- function(expr) {
	if (function_name(expr) == "-") {
		return(expr[[2]])
	}
	expr[[2]] <- strip_minus(expr[[2]])
	expr
}

function_name <- function(expr) {
	fn_node <- expr[[1]]
	fn_name <- if (is.symbol(fn_node)) {
		as.character(fn_node)
	} else if (
		is.call(fn_node) &&
			length(fn_node) == 3 &&
			as.character(fn_node[[1]]) %in% c("::", ":::")
	) {
		as.character(fn_node[[3]])
	} else {
		""
	}
}

here <- function() {
	parent.frame()
}

there <- function() {
	parent.frame(2)
}

abort_select_colon <- function(from, to, expr, call) {
	from_diag <- if (length(from) != 1) colon_abort_message(from, expr[[2]])
	to_diag <- if (length(to) != 1) colon_abort_message(to, expr[[3]])
	range_str <- deparse(expr)
	cli_abort(
		c(
			"Invalid select expression provided.",
			"i" = "Got {.code {range_str}}",
			"i" = "Each side of {.code :} must be length 1.",
			"i" = "Invalid length{qty(c(from_diag, to_diag))}{?s}:",
			from_diag$info,
			to_diag$info
		),
		call = call
	)
}

colon_abort_message <- function(res, expr) {
	str <- deparse(expr)
	list(
		code = str,
		info = setNames(
			format_inline("{.code {str}}, {length(res)}"),
			"*"
		)
	)
}
