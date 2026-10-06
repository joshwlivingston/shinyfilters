test_that("across_filters() sets inputs for the columns it selects", {
	cfg <- shinyfilters(df_config)
	expect_identical(
		filterInput(with_filters(cfg, across_filters(where(is.numeric), "slider"))),
		filterInput(with_filters(cfg, where(is.numeric), "slider"))
	)
	expect_identical(
		filterInput(with_filters(cfg, across_filters(x, ~"radio"))),
		filterInput(with_filters(cfg, x, "radio"))
	)
	expect_identical(
		filterInput(with_filters(cfg, shinyfilters::across_filters(x, "radio"))),
		filterInput(with_filters(cfg, x, "radio"))
	)
})

test_that("across_filters() matches its arguments like across()", {
	cfg <- shinyfilters(df_config)
	numeric_sliders <- filterInput(with_filters(cfg, where(is.numeric), "slider"))

	expect_identical(
		filterInput(with_filters(
			cfg,
			across_filters(.cols = where(is.numeric), .fns = "slider")
		)),
		numeric_sliders
	)
	expect_identical(
		filterInput(with_filters(
			cfg,
			across_filters(.fns = "slider", where(is.numeric))
		)),
		numeric_sliders
	)
	expect_identical(
		filterInput(with_filters(cfg, across_filters(.fns = "selectize"))),
		filterInput(with_filters(cfg, everything(), "selectize"))
	)
})

test_that("with_filters() mixes across_filters() with named columns in order", {
	cfg <- shinyfilters(df_config)
	expect_identical(
		filterInput(with_filters(
			cfg,
			across_filters(everything(), "selectize"),
			x = "radio"
		)),
		filterInput(with_filters(
			with_filters(cfg, everything(), "selectize"),
			x = "radio"
		))
	)
	expect_identical(
		filterInput(with_filters(
			cfg,
			x = "radio",
			across_filters(x, "selectize")
		)),
		filterInput(with_filters(cfg, x = "selectize"))
	)
})

test_that("across_filters() errors", {
	cfg <- shinyfilters(df_config)
	expect_snapshot(error = TRUE, variant = snapshot_variant(), {
		across_filters(x, "radio")

		with_filters(cfg, across_filters())
		with_filters(cfg, across_filters(where(is.numeric)))
		with_filters(cfg, across_filters(x, "radio", .names = "{.col}_1"))
		with_filters(cfg, across_filters(x, "radio", foo = 1))
		with_filters(cfg, x = across_filters(where(is.numeric), "slider"))

		with_filters(cfg, across_filters(x, letters ~ "radio"))
		with_filters(cfg, across_filters(x, ~ mean(.x)))
		with_filters(cfg, across_filters(x, list(a = "radio")))

		with_filters(cfg, across(x, "radio"))
	})
})
