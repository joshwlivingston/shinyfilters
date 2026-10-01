test_that("mutate() sets inputs by column name", {
	skip_if_not_installed("dplyr")
	cfg <- shinyfilters(df_config)
	expect_identical(dplyr::mutate(cfg), cfg)
	expect_identical(
		filterInput(dplyr::mutate(cfg, x = "radio", letters = "selectize")),
		filterInput(with_filter(cfg, x = "radio", letters = "selectize"))
	)
})

test_that("mutate() sets inputs for the columns across() selects", {
	skip_if_not_installed("dplyr")
	cfg <- shinyfilters(df_config)
	expect_identical(
		filterInput(dplyr::mutate(cfg, across(where(is.numeric), "slider"))),
		filterInput(with_filter(cfg, where(is.numeric), "slider"))
	)
})

test_that("across() matches its arguments like dplyr::across()", {
	skip_if_not_installed("dplyr")
	cfg <- shinyfilters(df_config)
	numeric_sliders <- filterInput(with_filter(cfg, where(is.numeric), "slider"))

	expect_identical(
		filterInput(dplyr::mutate(
			cfg,
			across(.cols = where(is.numeric), .fns = "slider")
		)),
		numeric_sliders
	)
	expect_identical(
		filterInput(dplyr::mutate(cfg, across(.fns = "slider", where(is.numeric)))),
		numeric_sliders
	)
	expect_identical(
		filterInput(dplyr::mutate(cfg, across(.fns = "selectize"))),
		filterInput(with_filter(cfg, everything(), "selectize"))
	)
	expect_identical(
		filterInput(dplyr::mutate(cfg, dplyr::across(x, "radio"))),
		filterInput(with_filter(cfg, x, "radio"))
	)
	expect_identical(
		filterInput(dplyr::mutate(cfg, across(x, ~"radio"))),
		filterInput(with_filter(cfg, x, "radio"))
	)
})

test_that("mutate() accepts across_filters() too", {
	skip_if_not_installed("dplyr")
	cfg <- shinyfilters(df_config)
	expect_identical(
		filterInput(dplyr::mutate(
			cfg,
			across_filters(where(is.numeric), "slider")
		)),
		filterInput(with_filter(cfg, where(is.numeric), "slider"))
	)
})

test_that("mutate() applies its arguments in order", {
	skip_if_not_installed("dplyr")
	cfg <- shinyfilters(df_config)
	expect_identical(
		filterInput(dplyr::mutate(cfg, x = "radio", across(x, "selectize"))),
		filterInput(with_filter(cfg, x = "selectize"))
	)
})

test_that("mutate() labels a custom input the way with_filter() does", {
	skip_if_not_installed("dplyr")
	my_select <- function(inputId, label, choices) {
		shiny::selectInput(inputId, label, choices)
	}
	cfg <- shinyfilters(df_config)
	expect_snapshot(variant = snapshot_variant(), {
		print(dplyr::mutate(cfg, across(letters, my_select)))
		print(dplyr::mutate(cfg, letters = my_select))
	})
})

test_that("select() keeps the selected columns", {
	skip_if_not_installed("dplyr")
	cfg <- shinyfilters(df_config)
	expect_identical(
		names(dplyr::select(cfg, where(is.numeric))),
		c("x", "a_very_very_long_name")
	)
	expect_identical(names(dplyr::select(cfg, letters, x)), c("letters", "x"))
})

test_that("mutate() errors", {
	skip_if_not_installed("dplyr")
	cfg <- shinyfilters(df_config)
	expect_snapshot(error = TRUE, variant = snapshot_variant(), {
		dplyr::mutate(cfg, across(where(is.numeric)))
		dplyr::mutate(cfg, x = across(where(is.numeric), "slider"))

		dplyr::mutate(cfg, .keep = "none")
		dplyr::mutate(cfg, .by = x)

		dplyr::mutate(cfg, 1 + 1)
		dplyr::mutate(cfg, nope = "radio")
		dplyr::mutate(cfg, x = "radioo")
	})
})

test_that("pull() returns one column's input", {
	skip_if_not_installed("dplyr")
	cfg <- shinyfilters(df_config)
	expect_identical(dplyr::pull(cfg, x), cfg[["x"]])
	expect_identical(dplyr::pull(cfg, "x"), cfg[["x"]])
	expect_identical(dplyr::pull(cfg), cfg[["a_very_very_long_name"]])
})

test_that("pull() errors", {
	skip_if_not_installed("dplyr")
	cfg <- shinyfilters(df_config)
	expect_snapshot(error = TRUE, variant = snapshot_variant(), {
		dplyr::pull(cfg, x, name = letters)
	})
})

test_that("as.character() renders the inputs as HTML", {
	cfg <- shinyfilters(df_config)
	res <- as.character(cfg)
	expect_identical(res, as.character(filterInput(cfg)))
	expect_type(res, "character")
})

test_that("as.data.frame() returns the data", {
	cfg <- with_filter(shinyfilters(df_config), x = "radio")
	expect_identical(as.data.frame(cfg), df_config)
})

test_that("as_tibble() returns the data", {
	skip_if_not_installed("tibble")
	cfg <- shinyfilters(df_config)
	expect_identical(tibble::as_tibble(cfg), tibble::as_tibble(df_config))
})

test_that("as.data.table() returns the data", {
	skip_if_not_installed("data.table")
	cfg <- shinyfilters(df_config)
	expect_identical(
		data.table::as.data.table(cfg),
		data.table::as.data.table(df_config)
	)
})
