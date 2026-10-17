# Column names that tell the tidyselect helpers apart: upper and lower case, a
# regular expression metacharacter, zero-padded numbers, and a name that isn't
# syntactic. One column of each type for `where()`.
df_select <- data.frame(
	stringsAsFactors = FALSE,
	check.names = FALSE,
	id = 1:3,
	name = c("a", "b", "c"),
	x1 = c(1.5, 2, 3),
	x2 = c(4, 5, 6),
	x3 = 7:9,
	X10 = c(TRUE, FALSE, TRUE),
	a.b = factor(c("u", "v", "u")),
	ab_x = c("p", "q", "r"),
	wk01 = 1:3,
	wk02 = 4:6,
	`my col` = c("p", "q", "r"),
	end_x = as.Date("2024-01-01") + 0:2
)

# What `[` and tidyselect each do with `expr`, evaluated in `env`
select_both <- function(expr, data, env) {
	withr::local_options(lifecycle_verbosity = "quiet")
	list(
		ours = select_outcome(
			eval(bquote(.cfg[.(expr)]), list(.cfg = shinyfilters(data)), env)
		),
		theirs = select_outcome(
			tidyselect::eval_select(expr, data, env = env, allow_rename = FALSE)
		)
	)
}

# What `code` selects, or the message of its error, on one line. An error that
# wraps another, as tidyselect's "In argument:" does, gives the wrapped message.
select_outcome <- function(code) {
	tryCatch(
		{
			selected <- names(code)
			if (length(selected) == 0) {
				selected <- "nothing"
			}
			paste("selects", paste(selected, collapse = ", "))
		},
		error = function(cnd) {
			while (!is.null(cnd$parent)) {
				cnd <- cnd$parent
			}
			msg <- trimws(cli::ansi_strip(conditionMessage(cnd)))
			paste("error:", gsub("[[:space:]]*\n[[:space:]]*", " / ", msg))
		}
	)
}

# `[` selects the columns tidyselect does, or errors with the message
# tidyselect does
expect_selects_like_tidyselect <- function(expr, data = df_select) {
	expr <- substitute(expr)
	res <- suppressWarnings(select_both(expr, data, parent.frame()))
	label <- paste0("`[", paste(deparse(expr), collapse = ""), "]`")
	both_error <- all(startsWith(unlist(res), "error:"))
	expect_identical(
		res$ours,
		res$theirs,
		label = if (both_error) paste("the error of", label) else label,
		expected.label = if (both_error) {
			"tidyselect's error"
		} else {
			"what tidyselect does"
		}
	)
}
