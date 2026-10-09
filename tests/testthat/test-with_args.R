test_that("with_args() sets an argument with `cols ~ list()`", {
	cfg <- shinyfilters(df_config)
	expect_identical(
		with_args(cfg, x ~ list(value = range(.x)))$x,
		shiny::sliderInput("x", "x", min = 2L, max = 10L, value = c(2L, 10L))
	)
	expect_identical(
		with_args(cfg, letters ~ list(label = "Letters"))$letters,
		filterInput(
			df_config$letters,
			inputId = "letters",
			label = "Letters",
			selectize = TRUE,
			multiple = TRUE
		)
	)
})

test_that("with_args() sets several arguments with list()", {
	cfg <- shinyfilters(df_config)
	expect_identical(
		with_args(cfg, x ~ list(value = range(.x), step = 2))$x,
		shiny::sliderInput(
			"x",
			"x",
			min = 2L,
			max = 10L,
			value = c(2L, 10L),
			step = 2
		)
	)
})

test_that("with_args() applies its arguments in order", {
	cfg <- shinyfilters(df_config)
	expect_identical(
		filterInput(with_args(
			cfg,
			x ~ list(value = range(.x)),
			a_very_very_long_name ~ list(step = 0.5)
		)),
		filterInput(with_args(
			with_args(cfg, x ~ list(value = range(.x))),
			a_very_very_long_name ~ list(step = 0.5)
		))
	)
})

test_that("with_args() applies its arguments in order (tidyselect)", {
	skip_if_not_installed("tidyselect")
	cfg <- shinyfilters(df_config)
	expect_identical(
		with_args(
			cfg,
			tidyselect::where(is.numeric) ~ list(step = 2),
			x ~ list(step = 4)
		)$x,
		shiny::sliderInput("x", "x", min = 2L, max = 10L, value = 10L, step = 4)
	)
})

test_that("with_args() keeps the column's input and its earlier arguments", {
	cfg <- shinyfilters(df_config)
	expect_identical(
		with_args(
			with_args(cfg, x ~ list(step = 2)),
			x ~ list(value = range(.x))
		)$x,
		shiny::sliderInput(
			"x",
			"x",
			min = 2L,
			max = 10L,
			value = c(2L, 10L),
			step = 2
		)
	)
	radio <- with_filters(cfg, letters = "radio")
	expect_identical(
		with_args(radio, letters ~ list(inline = TRUE))$letters,
		shiny::radioButtons(
			"letters",
			"letters",
			choices = c("a", "b", "c"),
			inline = TRUE
		)
	)
})

test_that("an input chosen later keeps the with_args() arguments it names", {
	cfg <- with_args(
		shinyfilters(df_config),
		x ~ list(step = 2, ticks = FALSE)
	)
	expect_identical(
		with_filters(cfg, x = "numeric")$x,
		shiny::numericInput("x", "x", value = 10L, min = 2L, max = 10L, step = 2)
	)

	radio <- with_filters(
		shinyfilters(df_config),
		letters = "radio" ~ list(inline = TRUE, label = "Letters")
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

	args_first <- with_args(
		shinyfilters(df_config, slider = FALSE),
		x ~ list(value = range(.x))
	)
})

test_that("an input chosen later keeps the with_args() arguments it names (tidyselect)", {
	skip_if_not_installed("tidyselect")
	cfg <- with_args(
		shinyfilters(df_config),
		x ~ list(step = 2, ticks = FALSE)
	)
	args_first <- with_args(
		shinyfilters(df_config, slider = FALSE),
		x ~ list(value = range(.x))
	)
	expect_identical(
		with_filters(args_first, tidyselect::where(is.numeric) ~ "slider")$x,
		shiny::sliderInput("x", "x", min = 2L, max = 10L, value = c(2L, 10L))
	)
})

test_that("an input chosen later that takes `...` keeps every argument", {
	my_slider <- function(inputId, label, ...) {
		shiny::sliderInput(inputId, label, ...)
	}
	cfg <- with_args(
		shinyfilters(df_config),
		x ~ list(step = 2, ticks = FALSE)
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

test_that("an input a column doesn't support keeps every argument", {
	cfg <- shinyfilters(df_config)
	set <- with_filters(cfg, factors = "select" ~ list(inline = TRUE))
	expect_identical(
		with_filters(with_filters(set, factors = "slider"), factors = "radio"),
		with_filters(cfg, factors = "radio" ~ list(inline = TRUE))
	)
})

test_that("arguments add to the ones set earlier", {
	cfg <- shinyfilters(df_config)
	expect_identical(
		with_filters(
			with_filters(cfg, x = "slider" ~ list(step = 2, width = "50%")),
			x = "slider" ~ list(width = "100%", ticks = FALSE)
		),
		with_filters(
			cfg,
			x = "slider" ~ list(step = 2, width = "100%", ticks = FALSE)
		)
	)
})

test_that("an input is the same written as a keyword or a function", {
	cfg <- shinyfilters(df_config)
	expect_identical(
		with_filters(cfg, x = shiny::sliderInput),
		with_filters(cfg, x = "slider")
	)
	expect_identical(
		with_filters(cfg, x = shiny::sliderInput ~ list(step = 2)),
		with_filters(cfg, x = "slider" ~ list(step = 2))
	)
})

test_that("a function of the user's own takes arguments", {
	cfg <- shinyfilters(df_config)
	my_numeric <- function(inputId, label, value, min, max, step = NA) {
		shiny::numericInput(inputId, label, value, min, max, step)
	}
	expected <- shiny::numericInput("x", "x", 10L, 2L, 10L, 2)
	expect_identical(
		with_filters(cfg, x = my_numeric ~ list(step = 2))$x,
		expected
	)
	expect_identical(
		with_filters(cfg, x, my_numeric ~ list(step = 2))$x,
		expected
	)
})

test_that("a value that uses `.x` is computed when the input is created", {
	cfg <- with_args(shinyfilters(df_config), x ~ list(value = range(.x)))
	expect_identical(
		with_filters(cfg, x = x * 2L)$x,
		shiny::sliderInput("x", "x", min = 4L, max = 20L, value = c(4L, 20L))
	)

	df <- data.frame(a = c(NA, 3L, 1L))
	expect_identical(
		with_args(shinyfilters(df), a ~ list(value = range(.x)))$a,
		shiny::sliderInput("a", "a", min = 1L, max = 3L, value = c(1L, 3L))
	)
})

test_that("`.x` keeps the column's missing values", {
	df <- data.frame(a = c(NA, 3L, 1L))
	cfg <- with_args(
		shinyfilters(df),
		a ~ list(value = range(.x, na.rm = TRUE), step = sum(is.na(.x)))
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

test_that("a call in a value that uses `.x` gets `na.rm = TRUE`", {
	df <- data.frame(a = c(NA, 3L, 1L))
	cfg <- shinyfilters(df)
	spread <- function(x, ...) {
		dots <- list(...)
		diff(range(x, na.rm = isTRUE(dots$na.rm)))
	}
	expect_identical(
		with_args(cfg, a ~ list(value = mean(.x)))$a,
		shiny::sliderInput("a", "a", min = 1L, max = 3L, value = 2)
	)
	expect_identical(
		with_args(cfg, a ~ list(step = spread(.x)))$a,
		shiny::sliderInput("a", "a", min = 1L, max = 3L, value = 3L, step = 2L)
	)
	expect_identical(
		with_args(cfg, a ~ list(label = paste(max(.x, na.rm = FALSE))))$a,
		shiny::sliderInput("a", "NA", min = 1L, max = 3L, value = 3L)
	)
})

test_that("a namespaced call in a value that uses `.x` gets `na.rm = TRUE`", {
	df <- data.frame(a = c(NA, 3L, 1L))
	cfg <- shinyfilters(df)
	expected <- shiny::sliderInput("a", "a", min = 1L, max = 3L, value = 2)
	expect_identical(
		with_args(cfg, a ~ list(value = base::mean(.x)))$a,
		expected
	)
	expect_identical(
		with_args(
			cfg,
			a ~ list(value = stats::quantile(.x, 0.5, names = FALSE))
		)$a,
		expected
	)
})

test_that("a value that uses `.x` can use `[`, parentheses, and `if`", {
	expect_no_warning(
		cfg <- with_args(
			shinyfilters(df_config),
			x ~
				list(
					value = (.x[3] + 1L) * 2L,
					step = if (is.integer(.x)) 2L else 0.5
				)
		)
	)
	expect_identical(
		cfg$x,
		shiny::sliderInput("x", "x", min = 2L, max = 10L, value = 6L, step = 2L)
	)
})

test_that("a value that uses `.x` can use other columns", {
	cfg <- with_args(
		shinyfilters(df_config),
		x ~ list(max = max(.x) + max(a_very_very_long_name))
	)
	expect_identical(
		cfg$x,
		shiny::sliderInput("x", "x", min = 2L, max = 13.5, value = 10L)
	)
})

test_that("`ns`, `[`, and `[[` apply to inputs with arguments", {
	cfg <- with_args(
		shinyfilters(df_config, ns = shiny::NS("m")),
		x ~ list(value = range(.x))
	)
	expect_identical(
		cfg$x,
		shiny::sliderInput("m-x", "x", min = 2L, max = 10L, value = c(2L, 10L))
	)
	expect_identical(cfg["x"]$x, cfg$x)
	expect_identical(cfg[["x"]], cfg$x)
})

test_that("other values are evaluated right away and can use the columns", {
	cfg <- shinyfilters(df_config)
	label <- "First"
	set <- with_args(
		cfg,
		x ~ list(label = label, max = max(a_very_very_long_name) * 10)
	)
	label <- "Second"
	expect_identical(
		set$x,
		shiny::sliderInput("x", "First", min = 2L, max = 35, value = 10L)
	)
})

test_that("with_args() passes a `NULL` value", {
	cfg <- shinyfilters(df_config)
	expect_identical(
		with_args(cfg, letters ~ list(selected = NULL))$letters,
		shiny::selectizeInput(
			"letters",
			"letters",
			choices = c("a", "b", "c"),
			selected = NULL,
			multiple = TRUE
		)
	)
})

test_that("a value can use shiny::req()", {
	cfg <- shinyfilters(df_config)
	expect_error(
		with_args(cfg, x ~ list(label = shiny::req(FALSE))),
		class = "shiny.silent.error"
	)
	expect_error(
		filterInput(with_args(cfg, x ~ list(value = shiny::req(FALSE, .x)))),
		class = "shiny.silent.error"
	)
})

test_that("print() shows what each way of writing with_args() sets", {
	cfg <- shinyfilters(df_config)
	expect_snapshot(variant = snapshot_variant(), {
		with_args(cfg, x ~ list(value = range(.x)))
		with_args(cfg, x ~ list(value = range(.x), step = 2))
		with_args(
			cfg,
			x ~ list(value = range(.x)),
			letters ~ list(label = "Letters")
		)
	})
})

test_that("print() shows what each way of writing with_filters() sets", {
	cfg <- shinyfilters(df_config, slider = FALSE)
	expect_snapshot(variant = snapshot_variant(), {
		with_filters(cfg, x ~ list(step = 2))
		with_filters(cfg, x ~ list(step = 2, width = "50%"))

		with_filters(cfg, x = "slider" ~ list(value = range(.x)))
		with_filters(cfg, x = "slider" ~ list(value = range(.x), step = 2))
		with_filters(cfg, x = shiny::sliderInput ~ list(value = range(.x)))

		with_filters(
			cfg,
			letters = shiny::checkboxGroupInput ~
				list(inline = TRUE, .update_fn = shiny::updateCheckboxGroupInput)
		)
	})
})

test_that("print() shows what each way of writing with_filters() sets (tidyselect)", {
	skip_if_not_installed('tidyselect')
	cfg <- shinyfilters(df_config, slider = FALSE)
	expect_snapshot(variant = snapshot_variant(), {
		with_filters(
			cfg,
			tidyselect::where(is.numeric) ~ "slider" ~ list(value = range(.x))
		)
		with_filters(
			cfg,
			tidyselect::where(is.numeric) ~ "slider" ~ list(
				value = range(.x),
				step = 2
			)
		)
	})
})

test_that("print() shortens a long argument", {
	cfg <- with_args(
		shinyfilters(df_config),
		letters ~ list(label = "A label that runs past thirty characters")
	)
	expect_snapshot(print(cfg), variant = snapshot_variant())
})

test_that("print() shows `.update_fn`", {
	checkbox <- shiny::checkboxGroupInput
	update_checkbox <- shiny::updateCheckboxGroupInput
	div_input <- function(inputId, label, ...) shiny::tags$div()
	cfg <- with_filters(
		shinyfilters(df_config),
		letters = shiny::checkboxGroupInput ~
			list(inline = TRUE, .update_fn = shiny::updateCheckboxGroupInput),
		factors = checkbox ~ list(.update_fn = update_checkbox),
		x = div_input ~ list(.update_fn = function(session, inputId, ...) NULL)
	)
	expect_snapshot(print(cfg), variant = snapshot_variant())
})

test_that("with_filters() sets arguments like with_args()", {
	cfg <- shinyfilters(df_config)
	expect_identical(
		filterInput(with_filters(cfg, x ~ list(value = range(.x)))),
		filterInput(with_args(cfg, x ~ list(value = range(.x))))
	)
	expect_identical(
		filterInput(with_filters(cfg, x, list(value = range(.x)))),
		filterInput(with_args(cfg, x ~ list(value = range(.x))))
	)
})

test_that("with_filters() sets arguments like with_args() (tidyselect)", {
	skip_if_not_installed("tidyselect")
	cfg <- shinyfilters(df_config)
	expect_identical(
		filterInput(with_filters(
			cfg,
			tidyselect::where(is.numeric) ~ list(value = range(.x), step = 2)
		)),
		filterInput(with_args(
			cfg,
			tidyselect::where(is.numeric) ~ list(value = range(.x), step = 2)
		))
	)
})

test_that("with_filters() takes `input ~ arguments`", {
	cfg <- shinyfilters(df_config, slider = FALSE)
	expected <- shiny::sliderInput(
		"x",
		"x",
		min = 2L,
		max = 10L,
		value = c(2L, 10L)
	)
	expect_identical(
		with_filters(cfg, x = "slider" ~ list(value = range(.x)))$x,
		expected
	)
	expect_identical(
		with_filters(cfg, x ~ "slider" ~ list(value = range(.x)))$x,
		expected
	)
	expect_identical(
		with_filters(cfg, x = shiny::sliderInput ~ list(value = range(.x)))$x,
		expected
	)
	expect_identical(
		with_filters(cfg, x, "slider" ~ list(value = range(.x)))$x,
		expected
	)
})

test_that("list() is a named column's data", {
	cfg <- shinyfilters(df_config)
	expect_identical(
		as.data.frame(with_filters(cfg, y = list(1, "a", TRUE)))$y,
		list(1, "a", TRUE)
	)
})

test_that("`.update_fn` names the function that updates an input", {
	cfg <- shinyfilters(df_config)
	checkbox <- with_filters(cfg, letters = shiny::checkboxGroupInput)
	set <- with_filters(
		cfg,
		letters = shiny::checkboxGroupInput ~
			list(.update_fn = shiny::updateCheckboxGroupInput)
	)
	expect_identical(
		with_filters(
			checkbox,
			letters ~ list(.update_fn = shiny::updateCheckboxGroupInput)
		),
		set
	)
	expect_identical(
		with_args(
			checkbox,
			letters ~ list(.update_fn = shiny::updateCheckboxGroupInput)
		),
		set
	)
})

test_that("`.update_fn` stays with the input it updates", {
	cfg <- shinyfilters(df_config)
	set <- with_filters(
		cfg,
		letters = shiny::checkboxGroupInput ~
			list(.update_fn = shiny::updateCheckboxGroupInput)
	)
	expect_identical(
		with_args(set, letters ~ list(inline = TRUE)),
		with_filters(
			cfg,
			letters = shiny::checkboxGroupInput ~
				list(inline = TRUE, .update_fn = shiny::updateCheckboxGroupInput)
		)
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

test_that("an argument an input can't take errors when the input is created", {
	cfg <- shinyfilters(df_config)
	expect_snapshot(error = TRUE, variant = snapshot_variant(), {
		filterInput(with_args(cfg, x ~ list(value = nope(.x))))
		filterInput(with_args(cfg, x ~ list(valeu = 1)))
		filterInput(with_args(cfg, letters ~ list(valeu = 1)))
		filterInput(with_filters(cfg, letters = "slider" ~ list(value = 1)))

		with_filters(cfg, x = "sldier" ~ list(step = 2))
	})
})

test_that("with_filters() errors for an input's arguments", {
	cfg <- shinyfilters(df_config)
	expect_snapshot(error = TRUE, variant = snapshot_variant(), {
		with_filters(cfg, nope = "slider" ~ list(value = 1))

		with_filters(cfg, x = "slider" ~ list(value = 1, 5))
		with_filters(cfg, x ~ list(inputId = "y"))
		with_filters(cfg, x = "slider" ~ list(.update_fn = "updateSliderInput"))
		with_filters(cfg, x ~ list(max = nope * 2))
		with_filters(cfg, x = "slider" ~ "radio")
		with_filters(cfg, x, letters ~ "radio")
	})
})

test_that("with_args() errors", {
	cfg <- shinyfilters(df_config)
	expect_snapshot(error = TRUE, variant = snapshot_variant(), {
		with_args(df_config, x ~ list(step = 2))
		with_args(cfg)
		with_args(cfg, x = list(step = 2))
		with_args(cfg, x ~ "slider")
		with_args(cfg, x ~ "slider" ~ list(value = 1))
		with_args(cfg, x ~ list())

		with_args(cfg, x ~ list(step = 2, 5))
		# jarl-ignore-start duplicated_arguments: test
		with_args(cfg, x ~ list(step = 2, step = 4))
		# jarl-ignore-end duplicated_arguments
		with_args(cfg, x ~ list(inputId = "y"))

		with_args(cfg, nope ~ list(step = 2))
		with_args(cfg, x ~ list(max = nope * 2))
	})
})

test_that("with_args() errors (tidyselect)", {
	skip_if_not_installed("tidyselect")
	cfg <- shinyfilters(df_config)
	expect_snapshot(error = TRUE, variant = snapshot_variant(), {
		with_args(cfg, tidyselect::where(is.logical) ~ list(step = 2))
	})
})
