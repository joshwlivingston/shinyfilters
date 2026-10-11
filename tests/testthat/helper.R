# Calls `fn` the way user code does, from outside the package: test code itself
# runs inside the package's namespace.
call_as_user <- function(fn, ...) {
	caller <- function(fn, ...) fn(...)
	environment(caller) <- globalenv()
	caller(fn, ...)
}

# The rows `i` of a data frame, with the classes of its columns kept. Base `[`
# drops a class that has no `[` method.
rows_with_classes <- function(df, i) {
	out <- df[i, , drop = FALSE]
	for (name in names(df)) {
		oldClass(out[[name]]) <- oldClass(df[[name]])
	}
	out
}
