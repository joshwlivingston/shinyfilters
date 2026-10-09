test_that("with_filters() sets inputs for the columns across() selects", {
	cfg <- shinyfilters(df_config)
	expect_identical(
		filterInput(with_filters(cfg, across(x, ~"radio"))),
		filterInput(with_filters(cfg, x, "radio"))
	)
	expect_identical(
		filterInput(with_filters(cfg, dplyr::across(x, "radio"))),
		filterInput(with_filters(cfg, x, "radio"))
	)
})

test_that("with_filters() sets inputs for the columns across() selects (tidyselect)", {
	skip_if_not_installed("tidyselect")
	cfg <- shinyfilters(df_config)
	expect_identical(
		filterInput(with_filters(
			cfg,
			across(tidyselect::where(is.numeric), "slider")
		)),
		filterInput(with_filters(cfg, tidyselect::where(is.numeric), "slider"))
	)
})

test_that("across() matches its arguments like dplyr::across()", {
	skip_if_not_installed("tidyselect")
	cfg <- shinyfilters(df_config)
	numeric_sliders <- filterInput(with_filters(
		cfg,
		tidyselect::where(is.numeric),
		"slider"
	))

	expect_identical(
		filterInput(with_filters(
			cfg,
			across(.cols = tidyselect::where(is.numeric), .fns = "slider")
		)),
		numeric_sliders
	)
	expect_identical(
		filterInput(with_filters(
			cfg,
			across(.fns = "slider", tidyselect::where(is.numeric))
		)),
		numeric_sliders
	)
	expect_identical(
		filterInput(with_filters(cfg, across(.fns = "selectize"))),
		filterInput(with_filters(cfg, tidyselect::everything(), "selectize"))
	)
})

test_that("with_filters() mixes across() with named columns in order", {
	cfg <- shinyfilters(df_config)
	expect_identical(
		filterInput(with_filters(
			cfg,
			x = "radio",
			across(x, "selectize")
		)),
		filterInput(with_filters(cfg, x = "selectize"))
	)
})

test_that("with_filters() mixes across() with named columns in order (tidyselect)", {
	skip_if_not_installed("tidyselect")
	cfg <- shinyfilters(df_config)
	expect_identical(
		filterInput(with_filters(
			cfg,
			across(tidyselect::everything(), "selectize"),
			x = "radio"
		)),
		filterInput(with_filters(
			with_filters(cfg, tidyselect::everything(), "selectize"),
			x = "radio"
		))
	)
})

test_that("across() that resolves to dplyr's function selects columns", {
	skip_if_not_installed("dplyr", "1.0.0")
	cfg <- shinyfilters(df_config)
	across <- dplyr::across
	expect_identical(
		filterInput(with_filters(cfg, across(x, "radio"))),
		filterInput(with_filters(cfg, x, "radio"))
	)
})

test_that("with_filters() leaves another function named across() alone", {
	cfg <- shinyfilters(df_config)
	across <- function(x) x * 2L
	expect_identical(
		with_filters(cfg, y = across(x)),
		with_filters(cfg, y = x * 2L)
	)
	from_enclosing_scope <- function() with_filters(cfg, y = across(x))
	expect_identical(from_enclosing_scope(), with_filters(cfg, y = x * 2L))
	expect_identical(
		filterInput(with_filters(cfg, dplyr::across(x, "radio"))),
		filterInput(with_filters(cfg, x, "radio"))
	)
	expect_snapshot(error = TRUE, variant = snapshot_variant(), {
		with_filters(cfg, across(x, "radio"))
	})
})

test_that("with_filters() errors with across()", {
	cfg <- shinyfilters(df_config)
	expect_snapshot(error = TRUE, variant = snapshot_variant(), {
		with_filters(cfg, across())
		with_filters(cfg, across(x, "radio", .names = "{.col}_1"))
		with_filters(cfg, across(x, "radio", foo = 1))

		with_filters(cfg, across(x, letters ~ "radio"))
		with_filters(cfg, across(x, ~ mean(.x)))
		with_filters(cfg, across(x, ~ list(step = 2)))

		with_filters(cfg, base::across(x, "radio"))
	})
})

test_that("with_filters() errors with across() (tidyselect)", {
	skip_if_not_installed("tidyselect")
	cfg <- shinyfilters(df_config)
	expect_snapshot(error = TRUE, variant = snapshot_variant(), {
		with_filters(cfg, across(tidyselect::where(is.numeric)))
		with_filters(cfg, x = across(tidyselect::where(is.numeric), "slider"))
	})
})
