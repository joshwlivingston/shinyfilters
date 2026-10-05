# Recursively inject na.rm into a quosure
quo_inject_narm <- function(q, value = TRUE, overwrite = FALSE) {
	quo_inject(q, "na.rm", value, overwrite)
}

quo_inject <- function(q, arg, value, overwrite = FALSE) {
	if (!is_quosure(q)) {
		stop("Input must be a quosure")
	}
	expr <- quo_get_expr(q)
	env <- quo_get_env(q)
	new_expr <- expr_inject(expr, env, arg, value, overwrite)
	new_quosure(new_expr, env)
}

# ---------------------------------------------------------
# Recursive AST Walker
# ---------------------------------------------------------
expr_inject <- function(expr, env, arg, value, overwrite) {
	# Base case: if it's not a call (e.g., a symbol or literal)
	if (!is.call(expr)) {
		return(expr)
	}

	# 1. Recurse into arguments FIRST
	# Using native base R AST modification (expr[[i]]) is vastly safer than rlang::call_modify
	# because it preserves positional structure precisely.
	if (length(expr) > 1) {
		for (i in 2:length(expr)) {
			expr[[i]] <- expr_inject(expr[[i]], env, arg, value, overwrite)
		}
	}

	# 2. Extract the function name and object safely
	call_head <- expr[[1]]
	fn <- NULL
	fn_name <- NULL

	if (is.symbol(call_head)) {
		fn_name <- as.character(call_head)

		# Strictly look up as a function to bypass local vectors (e.g., if you have `range <- c(1,10)`)
		fn <- tryCatch(
			get(fn_name, envir = env, mode = "function"),
			error = function(e) {
				# Fallback for primitive or global functions
				tryCatch(match.fun(fn_name), error = function(e) NULL)
			}
		)
	} else {
		# Handle namespaced calls (e.g., base::range) or anonymous closures
		fn <- tryCatch(eval(call_head, envir = env), error = function(e) NULL)
	}

	# 3. Check if the function accepts {arg}
	if (is.function(fn) && fn_accepts_arg(fn, arg, fn_name)) {
		has_arg <- arg %in% names(expr)

		if (!has_arg || overwrite) {
			# Natively append/overwrite the named argument in the call object
			expr[[arg]] <- value
		}
	}

	return(expr)
}

# ---------------------------------------------------------
# Function Inspector
# ---------------------------------------------------------
fn_accepts_arg <- function(fn, arg, fn_name = NULL) {
	if (!is.function(fn)) {
		return(FALSE)
	}

	# Safely get formal arguments (handles closures and primitives like `range` and `sum`)
	fmls <- tryCatch(
		{
			if (is.primitive(fn)) formals(args(fn)) else formals(fn)
		},
		error = function(e) NULL
	)

	if (is.null(fmls)) {
		return(FALSE)
	}
	arg_names <- names(fmls)

	# Layer 1: Function explicitly takes {arg}
	if (arg %in% arg_names) {
		return(TRUE)
	}

	# Layer 2: Function takes `...` and might delegate {arg}
	if ("..." %in% arg_names) {
		bdy <- body(fn)
		if (!is.null(bdy)) {
			bdy_char <- deparse(bdy)

			# Heuristic A: Literal {arg} inside the body
			if (any(grepl(arg, bdy_char))) {
				return(TRUE)
			}

			# Heuristic B: S3 Generic (like `mean`)
			if (any(grepl("UseMethod", bdy_char))) {
				gen_name <- fn_name

				# Pull generic name from the UseMethod signature if we don't know it
				if (is.null(gen_name)) {
					match <- regmatches(
						bdy_char,
						regexpr('UseMethod\\(\\"[^\\"]+\\"\\)', bdy_char)
					)
					if (length(match) > 0) {
						gen_name <- gsub('UseMethod\\("|"\\)', "", match[1])
					}
				}

				if (!is.null(gen_name)) {
					methods_list <- suppressWarnings(
						tryCatch(
							as.character(methods(gen_name)),
							error = function(e) NULL
						)
					)

					for (m in methods_list) {
						cls <- sub(paste0("^", gen_name, "\\."), "", m)
						m_fn <- tryCatch(
							getS3method(gen_name, cls),
							error = function(e) {
								tryCatch(match.fun(m), error = function(e) NULL)
							}
						)

						if (is.function(m_fn)) {
							m_fmls <- tryCatch(
								{
									if (is.primitive(m_fn)) formals(args(m_fn)) else formals(m_fn)
								},
								error = function(e) NULL
							)

							if (arg %in% names(m_fmls)) return(TRUE)
						}
					}
				}
			}
		}
	}

	return(FALSE)
}
