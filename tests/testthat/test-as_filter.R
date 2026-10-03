test_that("as_filter() arguments replace the ones shinyfilters passes", {
	cfg <- with_filter(
		shinyfilters(df_config),
		x = as_filter("slider", value = range(.x), label = "X", step = 2)
	)
	expect_identical(
		cfg$x,
		shiny::sliderInput(
			"x",
			"X",
			min = 2L,
			max = 10L,
			value = c(2L, 10L),
			step = 2
		)
	)
})

test_that("as_filter() takes any input with_filter() does", {
	cfg <- shinyfilters(df_config)
	my_numeric <- function(inputId, label, value, min, max, step = NA) {
		shiny::numericInput(inputId, label, value, min, max, step)
	}
	expect_identical(
		with_filter(cfg, x = as_filter("slider")),
		with_filter(cfg, x = "slider")
	)
	expect_identical(
		with_filter(cfg, x = as_filter(shiny::sliderInput)),
		with_filter(cfg, x = "slider")
	)
	expect_identical(
		with_filter(cfg, x = as_filter(my_numeric, step = 2))$x,
		shiny::numericInput("x", "x", 10L, 2L, 10L, 2)
	)
})

test_that("as_filter() works in every with_filter() form", {
	cfg <- shinyfilters(df_config)
	range_slider <- as_filter("slider", value = range(.x))
	expected <- filterInput(with_filter(
		cfg,
		x = as_filter("slider", value = range(.x)),
		a_very_very_long_name = as_filter("slider", value = range(.x))
	))
	expect_identical(
		filterInput(with_filter(cfg, where(is.numeric), range_slider)),
		expected
	)
	expect_identical(
		filterInput(with_filter(
			cfg,
			across_filters(where(is.numeric), range_slider)
		)),
		expected
	)
	expect_identical(
		filterInput(with_filter(
			cfg,
			across_filters(
				where(is.numeric),
				as_filter("slider", value = range(.x))
			)
		)),
		expected
	)
})

test_that("an argument that uses `.x` is computed when the input is created", {
	cfg <- with_filter(
		shinyfilters(df_config),
		x = as_filter("slider", value = range(.x))
	)
	expect_identical(
		with_filter(cfg, x = x * 2L)$x,
		shiny::sliderInput("x", "x", min = 4L, max = 20L, value = c(4L, 20L))
	)
})

test_that("`.x` keeps the column's missing values", {
	df <- data.frame(stringsAsFactors = FALSE, a = c(NA, 3L, 1L))
	cfg <- with_filter(
		shinyfilters(df),
		a = as_filter(
			"slider",
			value = range(.x, na.rm = TRUE),
			step = sum(is.na(.x))
		)
	)
	expect_identical(
		cfg$a,
		shiny::sliderInput(
			"a",
			"a",
			min = 1L,
			max = 3L,
			value = c(1L, 3L),
			step = 1L
		)
	)
})

test_that("an argument that uses `.x` can use other columns", {
	cfg <- with_filter(
		shinyfilters(df_config),
		x,
		as_filter("slider", max = max(.x) + max(a_very_very_long_name))
	)
	expect_identical(
		cfg$x,
		shiny::sliderInput("x", "x", min = 2L, max = 13.5, value = 10L)
	)
})

test_that("other arguments are evaluated when as_filter() is called", {
	cfg <- shinyfilters(df_config)
	labels <- c(x = "First", a_very_very_long_name = "Second")
	for (col in names(labels)) {
		cfg <- with_filter(
			cfg,
			all_of(col),
			as_filter("slider", label = labels[[col]])
		)
	}
	expect_identical(
		cfg$x,
		shiny::sliderInput("x", "First", min = 2L, max = 10L, value = 10L)
	)
})

test_that("other arguments can use columns inside with_filter(col = ...)", {
	cfg <- with_filter(
		shinyfilters(df_config),
		x = as_filter("slider", max = max(a_very_very_long_name) * 10),
		a_very_very_long_name = a_very_very_long_name * 2
	)
	expect_identical(
		cfg$x,
		shiny::sliderInput("x", "x", min = 2L, max = 35, value = 10L)
	)
})

test_that("as_filter() arguments reach inputs that take `...`", {
	cfg <- with_filter(
		shinyfilters(df_config),
		letters = as_filter("selectize", multiple = TRUE, selected = NULL)
	)
	expect_identical(
		cfg$letters,
		shiny::selectizeInput(
			"letters",
			"letters",
			choices = c("a", "b", "c"),
			selected = NULL,
			multiple = TRUE
		)
	)
})

test_that("`ns`, `[`, and `[[` apply to as_filter() inputs", {
	cfg <- with_filter(
		shinyfilters(df_config, ns = shiny::NS("m")),
		x = as_filter("slider", value = range(.x))
	)
	expect_identical(
		cfg$x,
		shiny::sliderInput("m-x", "x", min = 2L, max = 10L, value = c(2L, 10L))
	)
	expect_identical(cfg["x"]$x, cfg$x)
	expect_identical(cfg[["x"]], cfg$x)
})

test_that("print() shows as_filter() arguments", {
	cfg <- with_filter(
		shinyfilters(df_config),
		across_filters(where(is.numeric), as_filter("slider", value = range(.x))),
		letters = as_filter("radio", inline = TRUE, label = "Letters"),
		factors = as_filter("selectize"),
		x = x * 2L
	)
	expect_snapshot(variant = snapshot_variant(), {
		print(cfg)
		print(as_filter(shiny::sliderInput, value = range(.x), step = 2))
		print(as_filter("selectize"))
	})
})

test_that("an argument that uses `.x` can use shiny::req()", {
	cfg <- with_filter(
		shinyfilters(df_config),
		x = as_filter("slider", value = shiny::req(FALSE, .x))
	)
	expect_error(filterInput(cfg), class = "shiny.silent.error")
})

test_that("as_filter() errors", {
	cfg <- shinyfilters(df_config)
	expect_snapshot(error = TRUE, variant = snapshot_variant(), {
		as_filter("sldier")
		as_filter(1:3)
		as_filter("slider", range(.x))
		as_filter("slider", inputId = "x")

		with_filter(cfg, nope = as_filter("slider"))
		with_filter(cfg, x, as_filter("sldier"))
		with_filter(cfg, x, as_filter("slider", max = max(a_very_very_long_name)))

		filterInput(with_filter(cfg, x = as_filter("slider", value = nope(.x))))
		filterInput(with_filter(cfg, x = as_filter("slider", valeu = 1)))
		filterInput(with_filter(cfg, letters = as_filter("slider", value = 1)))
	})
})
