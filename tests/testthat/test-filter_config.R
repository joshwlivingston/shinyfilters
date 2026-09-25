test_that("as_filters() applies `ns` to input ids", {
	res <- filterInput(as_filters(data.frame(a = letters), ns = shiny::NS("m")))
	expect_match(as.character(res), 'id="m-a"', fixed = TRUE)
})

test_that("as_filters(): `ns` must be result of shiny::NS()", {
	expect_snapshot(error = TRUE, {
		as_filters(data.frame(a = letters), ns = function(x) x)
	})
})

test_that("as_filters() without overrides matches filterInput(<data.frame>)", {
	expect_identical(
		filterInput(as_filters(df_config, slider = TRUE)),
		filterInput(df_config, slider = TRUE)
	)
})

test_that("with_filter() call forms are equivalent", {
	cfg <- as_filters(df_config, slider = TRUE)
	expected <- filterInput(with_filter(cfg, x = "radio"))
	col <- "x"
	expect_identical(filterInput(with_filter(cfg, x, "radio")), expected)
	expect_identical(filterInput(with_filter(cfg, "x", "radio")), expected)
	expect_identical(
		filterInput(with_filter(cfg, all_of(col), "radio")),
		expected
	)
	expect_identical(
		filterInput(with_filter(cfg, x, shiny::radioButtons)),
		expected
	)
})

test_that("with_filter() selects columns with tidyselect", {
	expected <- filterInput(df_config, slider = TRUE)
	expect_identical(
		filterInput(with_filter(
			as_filters(df_config),
			where(is.numeric),
			"slider"
		)),
		expected
	)
	expect_identical(
		filterInput(with_filter(
			as_filters(df_config),
			c(x, a_very_very_long_name),
			"slider"
		)),
		expected
	)
})

test_that("numeric + radio / selectize -> choices in numeric order", {
	res <- filterInput(with_filter(as_filters(df_config), x = "radio"))
	expect_identical(
		res[[3]],
		shiny::radioButtons("x", "x", choices = c(2L, 9L, 10L))
	)
	res <- filterInput(with_filter(as_filters(df_config), x = "selectize"))
	expect_identical(
		res[[3]],
		shiny::selectizeInput("x", "x", choices = c(2L, 9L, 10L))
	)
})

test_that("global `radio = TRUE` doesn't apply to numeric columns", {
	res <- filterInput(as_filters(df_config, radio = TRUE))
	expect_identical(
		res[[3]],
		filterInput(df_config$x, inputId = "x", label = "x")
	)
})

test_that("factor + radio keeps level order", {
	res <- filterInput(with_filter(as_filters(df_config), factors = "radio"))
	expect_identical(
		res[[2]],
		shiny::radioButtons(
			"factors",
			"factors",
			choices = factor(c("lo", "hi"), c("lo", "hi"))
		)
	)
})

test_that("keyword override replaces conflicting global flags", {
	res <- filterInput(with_filter(
		as_filters(df_config, selectize = TRUE),
		letters = "radio"
	))
	expect_identical(
		res[[1]],
		filterInput(
			df_config$letters,
			inputId = "letters",
			label = "letters",
			radio = TRUE
		)
	)
})

test_that("area -> shiny::textAreaInput", {
	res <- filterInput(with_filter(as_filters(df_config), letters = "area"))
	expect_identical(res[[1]], shiny::textAreaInput("letters", "letters"))
})

test_that("overrides work on columns with NA", {
	df <- data.frame(a = c(NA, 3L, 1L))
	res <- filterInput(with_filter(as_filters(df), a = "radio"))
	expect_identical(res[[1]], shiny::radioButtons("a", "a", choices = c(1L, 3L)))
})

test_that("every column overridden, and one-column data frames", {
	res <- filterInput(with_filter(as_filters(df_config), everything(), "radio"))
	expect_length(res, ncol(df_config))
	res <- filterInput(with_filter(as_filters(data.frame(a = 1:3)), a = "slider"))
	expect_identical(
		res[[1]],
		filterInput(1:3, inputId = "a", label = "a", slider = TRUE)
	)
})

test_that("`ns` applies to keyword, function, and default inputs", {
	my_select <- function(inputId, label, choices) {
		shiny::selectInput(inputId, label, choices)
	}
	cfg <- as_filters(df_config, ns = shiny::NS("m"))
	cfg <- with_filter(cfg, x = "radio", letters = my_select)
	html <- as.character(filterInput(cfg))
	for (col in names(df_config)) {
		expect_match(html, sprintf('id="m-%s"', col), fixed = TRUE)
	}
})

test_that("with_filter(): last write wins", {
	cfg <- as_filters(df_config)
	specific_last <- with_filter(cfg, where(is.numeric), "slider")
	specific_last <- filterInput(with_filter(specific_last, x = "radio"))
	expect_identical(
		specific_last[[3]],
		filterInput(with_filter(cfg, x = "radio"))[[3]]
	)
	class_last <- with_filter(cfg, x = "radio")
	class_last <- filterInput(with_filter(
		class_last,
		where(is.numeric),
		"slider"
	))
	expect_identical(
		class_last[[3]],
		filterInput(
			df_config$x,
			inputId = "x",
			label = "x",
			slider = TRUE
		)
	)
})

test_that("filterInput(<shinyfilters>, ...) merges with global arguments", {
	expect_identical(
		filterInput(as_filters(df_config), slider = TRUE),
		filterInput(df_config, slider = TRUE)
	)
	expect_identical(
		filterInput(as_filters(df_config), ns = shiny::NS("m")),
		filterInput(df_config, ns = shiny::NS("m"))
	)
})

test_that("range override on Date and POSIXct columns", {
	df <- data.frame(
		dte = as.Date("2024-01-01") + 0:1,
		dtm = as.POSIXct("2024-01-01", tz = "UTC") + 0:1 * 86400
	)
	res <- filterInput(with_filter(as_filters(df), everything(), "range"))
	expect_identical(
		res[[1]],
		filterInput(df$dte, inputId = "dte", label = "dte", range = TRUE)
	)
	expect_identical(
		res[[2]],
		filterInput(df$dtm, inputId = "dtm", label = "dtm", range = TRUE)
	)
})

test_that("radio override on logical columns", {
	df <- data.frame(lgl = c(TRUE, FALSE))
	res <- filterInput(with_filter(as_filters(df), lgl = "radio"))
	expect_identical(
		res[[1]],
		filterInput(df$lgl, inputId = "lgl", label = "lgl", radio = TRUE)
	)
})

test_that("function overrides receive args_filter_input() output", {
	my_numeric <- function(inputId, label, value, min, max) {
		shiny::numericInput(inputId, label, value, min, max)
	}
	res <- filterInput(with_filter(as_filters(df_config), x = my_numeric))
	expect_identical(
		res[[3]],
		filterInput(df_config$x, inputId = "x", label = "x")
	)
})

test_that("as_filters() and with_filter() errors", {
	cfg <- as_filters(df_config)
	expect_snapshot(error = TRUE, {
		as_filters(1:3)
		as_filters(df_config[0, ])
		as_filters(df_config, TRUE)
		with_filter(df_config, x = "radio")
		with_filter(cfg)
		with_filter(cfg, x)
		with_filter(cfg, x, "radio", "slider")
		with_filter(cfg, x = "radio", "letters")
		with_filter(cfg, nope = "radio")
		with_filter(cfg, nope, "radio")
		with_filter(cfg, where(is.logical), "radio")
		with_filter(cfg, x = "radioo")
		with_filter(cfg, x, c("radio", "slider"))
		with_filter(cfg, x, radio)
		with_filter(cfg, x = 1)
		filterInput(with_filter(cfg, factors = "slider"))
		filterInput(with_filter(cfg, a_very_very_long_name = "range"))
		filterInput(with_filter(
			as_filters(data.frame(a = NA_integer_)),
			a = "radio"
		))
		filterInput(as_filters(data.frame(a = NA_integer_)))
	})
})

test_that("print() shows each column's input", {
	my_select <- function(inputId, label, choices) {
		shiny::selectInput(inputId, label, choices)
	}
	cfg <- as_filters(df_config, slider = TRUE, ns = shiny::NS("m"))
	cfg <- with_filter(cfg, x = "radio", letters = my_select)
	expect_snapshot({
		print(as_filters(df_config))
		print(cfg)
		print(with_filter(as_filters(df_config), factors = "slider"))
		print(as_filters(df_config, args_unique = "bad"))
		print(as_filters(data.frame(x = "a")))
	})
})

test_that("print() resolves custom methods", {
	ClassRadio <- S7::new_class("ClassRadio", S7::class_character)
	ClassCustom <- S7::new_class("ClassCustom", S7::class_character)
	S7::method(filterInput, ClassRadio) <- function(x, ...) {
		call_filter_input(x, shiny::radioButtons, ...)
	}
	S7::method(filterInput, ClassCustom) <- function(x, ...) {
		shiny::tags$div()
	}
	ClassWrapped <- S7::new_class("ClassWrapped", S7::class_character)
	S7::method(filterInput, ClassWrapped) <- function(x, ...) {
		res <- call_filter_input(x, shiny::radioButtons, ...)
		stopifnot(inherits(res, "shiny.tag"))
		htmltools::tagAppendAttributes(res, class = "wrapped")
	}
	df <- structure(
		list(
			radio = ClassRadio(c("a", "b")),
			custom = ClassCustom(c("a", "b")),
			wrapped = ClassWrapped(c("a", "b"))
		),
		class = "data.frame",
		row.names = 1:2
	)
	expect_snapshot(print(as_filters(df)))
})

test_that("print() resets the dry run after an error", {
	local({
		local_mocked_bindings(
			._dry_run_label = function(...) {
				rlang::abort("boom", class = "shinyfilters_test_error")
			}
		)
		expect_error(
			capture.output(print(as_filters(df_config))),
			class = "shinyfilters_test_error"
		)
	})
	expect_identical(
		filterInput(as_filters(df_config)),
		filterInput(df_config)
	)
})

test_that("`$`, `[[`, and names() access columns", {
	cfg <- with_filter(as_filters(df_config, ns = shiny::NS("m")), x = "radio")
	res <- filterInput(cfg)
	expect_identical(cfg$x, res[[3]])
	expect_identical(cfg[["letters"]], res[[1]])
	expect_identical(cfg[[4]], res[[4]])
	expect_identical(names(cfg), names(df_config))
	expect_identical(utils::.DollarNames(cfg, "^a_"), "a_very_very_long_name")
})

test_that("`$` and `[[` error on unknown columns", {
	cfg <- as_filters(df_config)
	expect_snapshot(error = TRUE, {
		cfg$nope
		cfg[["nope"]]
		cfg[[9]]
		cfg[[c("x", "nope")]]
		cfg[[1:2]]
	})
})

test_that("`[` returns a config with the selected columns", {
	cfg <- with_filter(as_filters(df_config, slider = TRUE), x = "radio")
	sub <- cfg[c("x", "letters")]
	expect_identical(names(sub), c("x", "letters"))
	expect_identical(filterInput(sub)[[1]], filterInput(cfg)[[3]])
	expect_identical(filterInput(sub)[[2]], filterInput(cfg)[[1]])
	expect_identical(names(cfg[3:4]), c("x", "a_very_very_long_name"))
	expect_identical(cfg[], cfg)
	expect_identical(names(cfg[-1]), names(df_config)[-1])
	expect_identical(names(cfg[c("x", "x")]), "x")
	expect_identical(names(cfg[c(x, letters)]), c("x", "letters"))
	expect_identical(
		names(cfg[where(is.numeric)]),
		c("x", "a_very_very_long_name")
	)
	cols <- c("factors", "x")
	expect_identical(names(cfg[cols]), cols)
	expect_snapshot(print(cfg[c("letters", "x")]))
})

test_that("`[` errors on unknown columns", {
	cfg <- as_filters(df_config)
	expect_snapshot(error = TRUE, {
		cfg["nope"]
		cfg[9]
		cfg[TRUE]
		cfg[0]
		cfg[character(0)]
		cfg[, "x"]
		cfg[1, 2]
	})
})

test_that("methods for base generics don't mask them in the namespace", {
	ns <- asNamespace("shinyfilters")
	external <- c(
		ls(baseenv(), all.names = TRUE),
		getNamespaceExports("utils"),
		getNamespaceExports("methods")
	)
	masked <- intersect(ls(ns, all.names = TRUE), external)
	masked <- setdiff(masked, ".__S3MethodsTable__.")
	expect_identical(masked, character())
})
