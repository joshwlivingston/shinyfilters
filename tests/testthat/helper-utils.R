s3_unregister <- function(generic, class) {
	pieces <- strsplit(generic, "::", fixed = TRUE)[[1]]
	table <- asNamespace(pieces[[1]])[[".__S3MethodsTable__."]]
	name <- paste(pieces[[2]], class, sep = ".")
	if (exists(name, envir = table, inherits = FALSE)) {
		rm(list = name, envir = table)
	}
}

# Evaluates `code` with `method` registered, then removes the method and the
# load hook so nothing leaks into other tests.
with_s3_register <- function(generic, class, method, code) {
	package <- strsplit(generic, "::", fixed = TRUE)[[1]][[1]]
	event <- packageEvent(package, "onLoad")
	hooks <- getHook(event)
	on.exit(setHook(event, hooks, "replace"), add = TRUE)
	if (isNamespaceLoaded(package)) {
		on.exit(s3_unregister(generic, class), add = TRUE)
	}

	._s3_register(generic, class, method)
	code
}
