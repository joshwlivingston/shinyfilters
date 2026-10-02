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

test_that("mutate() adds and replaces columns", {
	skip_if_not_installed("dplyr")
	cfg <- shinyfilters(df_config)
	added <- dplyr::mutate(cfg, y = x * 2, flag = TRUE, z = y + 1)
	expect_identical(
		as.data.frame(added),
		transform(df_config, y = x * 2, flag = TRUE, z = x * 2 + 1)
	)

	replaced <- dplyr::mutate(cfg, x = "radio", x = x / 2)
	expect_identical(as.data.frame(replaced)$x, df_config$x / 2)
	expect_identical(
		filterInput(replaced),
		filterInput(with_filter(shinyfilters(as.data.frame(replaced)), x = "radio"))
	)
})

test_that("mutate() chooses the input for a column it added", {
	skip_if_not_installed("dplyr")
	cfg <- shinyfilters(df_config)
	expect_identical(
		filterInput(dplyr::mutate(cfg, y = x * 2, y = "slider")),
		filterInput(with_filter(
			shinyfilters(transform(df_config, y = x * 2)),
			y = "slider"
		))
	)
	expect_identical(
		filterInput(dplyr::mutate(cfg, y = x * 2, across(y, "slider"))),
		filterInput(dplyr::mutate(cfg, y = x * 2, y = "slider"))
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

		dplyr::mutate(cfg, y = shiny::selectInput)
		dplyr::mutate(cfg, y = nope * 2)
		dplyr::mutate(cfg, x = radio)
		dplyr::mutate(cfg, y = 1:2)
		dplyr::mutate(cfg, y = NULL)
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

test_that("a config placed in a UI renders its inputs", {
	cfg <- shinyfilters(df_config, selectize = TRUE)
	expect_identical(
		htmltools::renderTags(shiny::sidebarPanel(cfg)),
		htmltools::renderTags(shiny::sidebarPanel(filterInput(cfg)))
	)
})

test_that("a config placed in the UI of a bookmarked app errors", {
	shiny::shinyOptions(bookmarkStore = "url")
	on.exit(shiny::shinyOptions(bookmarkStore = NULL))
	cfg <- shinyfilters(df_config)
	expect_snapshot(error = TRUE, variant = snapshot_variant(), {
		htmltools::renderTags(shiny::sidebarPanel(cfg))
	})
	expect_no_error(htmltools::renderTags(shiny::sidebarPanel(filterInput(cfg))))
})

test_that("a config rendered in a session of a bookmarked app doesn't error", {
	cfg <- shinyfilters(df_config)
	shiny::withReactiveDomain(shiny::MockShinySession$new(), {
		shiny::shinyOptions(bookmarkStore = "url")
		expect_identical(
			shiny::getShinyOption("bookmarkStore"),
			"url"
		)
		expect_no_error(htmltools::renderTags(shiny::sidebarPanel(cfg)))
	})
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

test_that("the class name the S3 registrations use is stable", {
	expect_identical(
		class(shinyfilters(df_config))[[1]],
		"shinyfilters::shinyfilters"
	)
})

test_that("select() errors name the user's call", {
	skip_if_not_installed("dplyr")
	cfg <- shinyfilters(df_config)
	expect_snapshot(error = TRUE, variant = snapshot_variant(), {
		dplyr::select(cfg, nope)
		dplyr::select(cfg)
		dplyr::select(cfg, where(is.complex))
		dplyr::select(cfg, where(is.complex), where(is.raw))
	})
})
