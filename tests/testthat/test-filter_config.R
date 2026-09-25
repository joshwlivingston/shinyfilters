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
	expected <- filterInput(with_filter(cfg, int = "radio"))
	year <- "int"
	expect_identical(filterInput(with_filter(cfg, int, "radio")), expected)
	expect_identical(filterInput(with_filter(cfg, "int", "radio")), expected)
	expect_identical(
		filterInput(with_filter(cfg, all_of(year), "radio")),
		expected
	)
	expect_identical(
		filterInput(with_filter(cfg, int, shiny::radioButtons)),
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
		filterInput(with_filter(as_filters(df_config), c(int, dbl), "slider")),
		expected
	)
})

test_that("numeric + radio / selectize -> choices in numeric order", {
	res <- filterInput(with_filter(as_filters(df_config), int = "radio"))
	expect_identical(
		res[[3]],
		shiny::radioButtons("int", "int", choices = c(2L, 9L, 10L))
	)
	res <- filterInput(with_filter(as_filters(df_config), int = "selectize"))
	expect_identical(
		res[[3]],
		shiny::selectizeInput("int", "int", choices = c(2L, 9L, 10L))
	)
})

test_that("global `radio = TRUE` doesn't apply to numeric columns", {
	res <- filterInput(as_filters(df_config, radio = TRUE))
	expect_identical(
		res[[3]],
		filterInput(df_config$int, inputId = "int", label = "int")
	)
})

test_that("factor + radio keeps level order", {
	res <- filterInput(with_filter(as_filters(df_config), fct = "radio"))
	expect_identical(
		res[[2]],
		shiny::radioButtons(
			"fct",
			"fct",
			choices = factor(c("lo", "hi"), c("lo", "hi"))
		)
	)
})

test_that("keyword override replaces conflicting global flags", {
	res <- filterInput(with_filter(
		as_filters(df_config, selectize = TRUE),
		chr = "radio"
	))
	expect_identical(
		res[[1]],
		filterInput(df_config$chr, inputId = "chr", label = "chr", radio = TRUE)
	)
})

test_that("area -> shiny::textAreaInput", {
	res <- filterInput(with_filter(as_filters(df_config), chr = "area"))
	expect_identical(res[[1]], shiny::textAreaInput("chr", "chr"))
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
	cfg <- as_filters(df_config, ns = shiny::NS("m")) |>
		with_filter(int = "radio", chr = my_select)
	html <- as.character(filterInput(cfg))
	for (col in names(df_config)) {
		expect_match(html, sprintf('id="m-%s"', col), fixed = TRUE)
	}
})

test_that("with_filter(): last write wins", {
	cfg <- as_filters(df_config)
	specific_last <- cfg |>
		with_filter(where(is.numeric), "slider") |>
		with_filter(int = "radio") |>
		filterInput()
	expect_identical(
		specific_last[[3]],
		filterInput(with_filter(cfg, int = "radio"))[[3]]
	)
	class_last <- cfg |>
		with_filter(int = "radio") |>
		with_filter(where(is.numeric), "slider") |>
		filterInput()
	expect_identical(
		class_last[[3]],
		filterInput(df_config$int, inputId = "int", label = "int", slider = TRUE)
	)
})

test_that("filterInput(<FilterConfig>, ...) merges with global arguments", {
	expect_identical(
		filterInput(as_filters(df_config), slider = TRUE),
		filterInput(df_config, slider = TRUE)
	)
})

test_that("as_filters() and with_filter() errors", {
	cfg <- as_filters(df_config)
	expect_snapshot(error = TRUE, {
		as_filters(1:3)
		as_filters(df_config, TRUE)
		with_filter(df_config, int = "radio")
		with_filter(cfg)
		with_filter(cfg, int)
		with_filter(cfg, int, "radio", "slider")
		with_filter(cfg, int = "radio", "chr")
		with_filter(cfg, nope = "radio")
		with_filter(cfg, nope, "radio")
		with_filter(cfg, where(is.logical), "radio")
		with_filter(cfg, int = "radioo")
		with_filter(cfg, int, c("radio", "slider"))
		with_filter(cfg, int, radio)
		with_filter(cfg, int = 1)
		filterInput(with_filter(cfg, fct = "slider"))
		filterInput(with_filter(cfg, dbl = "range"))
	})
})
