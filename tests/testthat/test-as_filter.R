test_that("as_filter() arguments replace the ones shinyfilters passes", {
	cfg <- with_filters(
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

test_that("as_filter() takes any input with_filters() does", {
	cfg <- shinyfilters(df_config)
	my_numeric <- function(inputId, label, value, min, max, step = NA) {
		shiny::numericInput(inputId, label, value, min, max, step)
	}
	expect_identical(
		with_filters(cfg, x = as_filter("slider")),
		with_filters(cfg, x = "slider")
	)
	expect_identical(
		with_filters(cfg, x = as_filter(shiny::sliderInput)),
		with_filters(cfg, x = "slider")
	)
	expect_identical(
		with_filters(cfg, x = as_filter(my_numeric, step = 2))$x,
		shiny::numericInput("x", "x", 10L, 2L, 10L, 2)
	)
})

test_that("as_filter() without an input keeps the column's input", {
	cfg <- shinyfilters(df_config, slider = TRUE)
	expect_identical(
		with_filters(cfg, x = as_filter(value = range(.x), step = 2))$x,
		shiny::sliderInput(
			"x",
			"x",
			min = 2L,
			max = 10L,
			value = c(2L, 10L),
			step = 2
		)
	)
	expect_identical(
		with_filters(cfg, letters = as_filter(label = "Letters"))$letters,
		filterInput(
			df_config$letters,
			inputId = "letters",
			label = "Letters",
			selectize = TRUE,
			multiple = TRUE
		)
	)
	expect_identical(
		with_filters(
			with_filters(cfg, letters = "radio"),
			letters = as_filter(inline = TRUE)
		),
		with_filters(cfg, letters = as_filter("radio", inline = TRUE))
	)
})

test_that("as_filter() without an input works in every with_filters() form", {
	cfg <- shinyfilters(df_config, slider = TRUE)
	range_value <- as_filter(value = range(.x))
	expected <- filterInput(with_filters(
		cfg,
		x = as_filter(value = range(.x)),
		a_very_very_long_name = as_filter(value = range(.x))
	))
	expect_identical(
		filterInput(with_filters(cfg, where(is.numeric), range_value)),
		expected
	)
	expect_identical(
		filterInput(with_filters(cfg, where(is.numeric) ~ range_value)),
		expected
	)
	expect_identical(
		filterInput(with_filters(
			cfg,
			across_filters(where(is.numeric), ~ as_filter(value = range(.x)))
		)),
		expected
	)
})

test_that("as_filter() works in every with_filters() form", {
	cfg <- shinyfilters(df_config)
	range_slider <- as_filter("slider", value = range(.x))
	expected <- filterInput(with_filters(
		cfg,
		x = as_filter("slider", value = range(.x)),
		a_very_very_long_name = as_filter("slider", value = range(.x))
	))
	expect_identical(
		filterInput(with_filters(cfg, where(is.numeric), range_slider)),
		expected
	)
	expect_identical(
		filterInput(with_filters(
			cfg,
			across_filters(where(is.numeric), range_slider)
		)),
		expected
	)
	expect_identical(
		filterInput(with_filters(
			cfg,
			across_filters(
				where(is.numeric),
				as_filter("slider", value = range(.x))
			)
		)),
		expected
	)
	expect_identical(
		filterInput(with_filters(
			cfg,
			across_filters(
				where(is.numeric),
				~ as_filter("slider", value = range(.x))
			)
		)),
		expected
	)
})

test_that("a new input keeps the as_filter() arguments it names", {
	cfg <- shinyfilters(df_config)
	numeric <- with_filters(cfg, x = as_filter(shiny::numericInput, step = 2))
	expect_identical(
		with_filters(numeric, where(is.numeric) ~ "slider")$x,
		shiny::sliderInput("x", "x", min = 2L, max = 10L, value = 10L, step = 2)
	)

	radio <- with_filters(
		cfg,
		letters = as_filter("radio", inline = TRUE, label = "Letters")
	)
	expect_identical(
		with_filters(radio, letters = "selectize")$letters,
		shiny::selectizeInput(
			"letters",
			"Letters",
			choices = c("a", "b", "c"),
			multiple = TRUE
		)
	)

	args_first <- with_filters(cfg, x = as_filter(value = range(.x)))
	expect_identical(
		with_filters(args_first, where(is.numeric) ~ "slider")$x,
		shiny::sliderInput("x", "x", min = 2L, max = 10L, value = c(2L, 10L))
	)
})

test_that("a new input that takes `...` keeps every as_filter() argument", {
	my_slider <- function(inputId, label, ...) {
		shiny::sliderInput(inputId, label, ...)
	}
	cfg <- with_filters(
		shinyfilters(df_config),
		x = as_filter("slider", step = 2, ticks = FALSE)
	)
	expect_identical(
		with_filters(cfg, x = my_slider)$x,
		shiny::sliderInput(
			"x",
			"x",
			min = 2L,
			max = 10L,
			value = 10L,
			step = 2,
			ticks = FALSE
		)
	)
})

test_that("an input a column doesn't support keeps every as_filter() argument", {
	cfg <- shinyfilters(df_config)
	set <- with_filters(cfg, factors = as_filter(inline = TRUE))
	expect_identical(
		with_filters(with_filters(set, factors = "slider"), factors = "radio"),
		with_filters(cfg, factors = as_filter("radio", inline = TRUE))
	)
})

test_that("as_filter() arguments add to the ones set earlier", {
	cfg <- shinyfilters(df_config)
	expect_identical(
		with_filters(
			with_filters(cfg, x = as_filter("slider", step = 2, width = "50%")),
			x = as_filter("slider", width = "100%", ticks = FALSE)
		),
		with_filters(
			cfg,
			x = as_filter("slider", step = 2, width = "100%", ticks = FALSE)
		)
	)
})

test_that("`.update_fn` stays with the input it updates", {
	cfg <- shinyfilters(df_config)
	set <- with_filters(
		cfg,
		letters = as_filter(
			shiny::checkboxGroupInput,
			.update_fn = shiny::updateCheckboxGroupInput
		)
	)
	expect_identical(
		with_filters(set, letters = as_filter(inline = TRUE)),
		with_filters(
			cfg,
			letters = as_filter(
				shiny::checkboxGroupInput,
				inline = TRUE,
				.update_fn = shiny::updateCheckboxGroupInput
			)
		)
	)
	expect_identical(
		with_filters(
			with_filters(cfg, letters = shiny::checkboxGroupInput),
			letters = as_filter(.update_fn = shiny::updateCheckboxGroupInput)
		),
		set
	)
	expect_identical(
		with_filters(set, letters = shiny::checkboxGroupInput),
		set
	)
	expect_identical(
		with_filters(set, letters = "radio"),
		with_filters(cfg, letters = "radio")
	)
})

test_that("an argument that uses `.x` is computed when the input is created", {
	cfg <- with_filters(
		shinyfilters(df_config),
		x = as_filter("slider", value = range(.x))
	)
	expect_identical(
		with_filters(cfg, x = x * 2L)$x,
		shiny::sliderInput("x", "x", min = 4L, max = 20L, value = c(4L, 20L))
	)
})

test_that("`.x` keeps the column's missing values", {
	df <- data.frame(stringsAsFactors = FALSE, a = c(NA, 3L, 1L))
	cfg <- with_filters(
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

test_that("a call in an argument that uses `.x` gets `na.rm = TRUE`", {
	df <- data.frame(stringsAsFactors = FALSE, a = c(NA, 3L, 1L))
	cfg <- shinyfilters(df)
	spread <- function(x, ...) {
		dots <- list(...)
		diff(range(x, na.rm = isTRUE(dots$na.rm)))
	}
	expect_identical(
		with_filters(cfg, a = as_filter("slider", value = mean(.x)))$a,
		shiny::sliderInput("a", "a", min = 1L, max = 3L, value = 2)
	)
	expect_identical(
		with_filters(cfg, a = as_filter("slider", step = spread(.x)))$a,
		shiny::sliderInput("a", "a", min = 1L, max = 3L, value = 3L, step = 2L)
	)
	expect_identical(
		with_filters(
			cfg,
			a = as_filter("slider", label = paste(max(.x, na.rm = FALSE)))
		)$a,
		shiny::sliderInput("a", "NA", min = 1L, max = 3L, value = 3L)
	)
})

test_that("a namespaced call in an argument that uses `.x` gets `na.rm = TRUE`", {
	df <- data.frame(stringsAsFactors = FALSE, a = c(NA, 3L, 1L))
	cfg <- shinyfilters(df)
	expected <- shiny::sliderInput("a", "a", min = 1L, max = 3L, value = 2)
	expect_identical(
		with_filters(cfg, a = as_filter("slider", value = base::mean(.x)))$a,
		expected
	)
	expect_identical(
		with_filters(
			cfg,
			a = as_filter("slider", value = stats::quantile(.x, 0.5, names = FALSE))
		)$a,
		expected
	)
})

test_that("an argument that uses `.x` can use `[`, parentheses, and `if`", {
	expect_no_warning(
		slider <- as_filter(
			"slider",
			value = (.x[3] + 1L) * 2L,
			step = if (is.integer(.x)) 2L else 0.5
		)
	)
	expect_identical(
		with_filters(shinyfilters(df_config), x = slider)$x,
		shiny::sliderInput("x", "x", min = 2L, max = 10L, value = 6L, step = 2L)
	)
})

test_that("an argument that uses `.x` can use other columns", {
	cfg <- with_filters(
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
		cfg <- with_filters(
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

test_that("other arguments can use columns inside with_filters(col = ...)", {
	cfg <- with_filters(
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
	cfg <- with_filters(
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
	cfg <- with_filters(
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
	cfg <- with_filters(
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

test_that("print() shortens a long as_filter() argument", {
	cfg <- with_filters(
		shinyfilters(df_config),
		letters = as_filter(label = "A label that runs past thirty characters")
	)
	expect_snapshot(print(cfg), variant = snapshot_variant())
})

test_that("print() marks a row by its input, not its as_filter() arguments", {
	cfg <- with_filters(
		shinyfilters(df_config, slider = TRUE),
		x = as_filter(value = range(.x)),
		letters = as_filter(label = "Letters")
	)
	expect_snapshot(variant = snapshot_variant(), {
		print(cfg)
		print(as_filter(value = range(.x)))
	})
})

test_that("print() shows `.update_fn`", {
	checkbox <- shiny::checkboxGroupInput
	update_checkbox <- shiny::updateCheckboxGroupInput
	cfg <- with_filters(
		shinyfilters(df_config),
		letters = as_filter(
			shiny::checkboxGroupInput,
			inline = TRUE,
			.update_fn = shiny::updateCheckboxGroupInput
		),
		factors = as_filter(checkbox, .update_fn = update_checkbox),
		x = as_filter(
			function(inputId, label, ...) shiny::tags$div(),
			.update_fn = function(session, inputId, ...) NULL
		)
	)
	expect_snapshot(variant = snapshot_variant(), {
		print(cfg)
		print(as_filter(shiny::checkboxGroupInput, .update_fn = update_checkbox))
		print(as_filter(.update_fn = shiny::updateCheckboxGroupInput))
	})
})

test_that("an argument that uses `.x` can use shiny::req()", {
	cfg <- with_filters(
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
		as_filter()
		as_filter("slider", .update_fn = "updateSliderInput")

		with_filters(cfg, nope = as_filter("slider"))
		with_filters(cfg, nope = as_filter(step = 2))
		with_filters(cfg, x, as_filter("sldier"))
		with_filters(cfg, x, as_filter("slider", max = max(a_very_very_long_name)))

		filterInput(with_filters(cfg, x = as_filter("slider", value = nope(.x))))
		filterInput(with_filters(cfg, x = as_filter("slider", valeu = 1)))
		filterInput(with_filters(cfg, letters = as_filter("slider", value = 1)))
		filterInput(with_filters(cfg, letters = as_filter(valeu = 1)))
	})
})
