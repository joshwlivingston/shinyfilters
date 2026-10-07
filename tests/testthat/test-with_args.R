test_that("with_args() sets an argument with `cols ~ arg := value`", {
	cfg <- shinyfilters(df_config)
	expect_identical(
		with_args(cfg, x ~ value := range(.x))$x,
		shiny::sliderInput("x", "x", min = 2L, max = 10L, value = c(2L, 10L))
	)
	expect_identical(
		with_args(cfg, letters ~ label := "Letters")$letters,
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
	expected <- shiny::sliderInput(
		"x",
		"x",
		min = 2L,
		max = 10L,
		value = c(2L, 10L),
		step = 2
	)
	expect_identical(
		with_args(cfg, x ~ list(value := range(.x), step := 2))$x,
		expected
	)
	expect_identical(
		with_args(cfg, x ~ list(value := range(.x), step = 2))$x,
		expected
	)
	expect_identical(
		with_args(cfg, x ~ list(value = range(.x), step = 2))$x,
		expected
	)
})

test_that("with_args() sets arguments for the columns across() selects", {
	cfg <- shinyfilters(df_config)
	expect_identical(
		filterInput(with_args(cfg, across(where(is.numeric), value := range(.x)))),
		filterInput(with_args(cfg, where(is.numeric) ~ value := range(.x)))
	)
	expect_identical(
		filterInput(with_args(
			cfg,
			across(c(x, a_very_very_long_name), list(value := range(.x), step = 2))
		)),
		filterInput(with_args(
			cfg,
			where(is.numeric) ~ list(value := range(.x), step = 2)
		))
	)
	expect_identical(
		with_args(cfg, dplyr::across(x, step := 2))$x,
		with_args(cfg, x ~ step := 2)$x
	)
})

test_that("with_args() leaves another function named across() alone", {
	cfg <- shinyfilters(df_config)
	across <- function(x) x * 2L
	expect_snapshot(error = TRUE, variant = snapshot_variant(), {
		with_args(cfg, across(x, step := 2))
	})
})

test_that("with_args() applies its arguments in order", {
	cfg <- shinyfilters(df_config)
	expect_identical(
		filterInput(with_args(
			cfg,
			x ~ value := range(.x),
			a_very_very_long_name ~ step := 0.5
		)),
		filterInput(with_args(
			with_args(cfg, x ~ value := range(.x)),
			a_very_very_long_name ~ step := 0.5
		))
	)
	expect_identical(
		with_args(cfg, where(is.numeric) ~ step := 2, x ~ step := 4)$x,
		shiny::sliderInput("x", "x", min = 2L, max = 10L, value = 10L, step = 4)
	)
})

test_that("with_args() keeps the column's input and its earlier arguments", {
	cfg <- shinyfilters(df_config)
	expect_identical(
		with_args(with_args(cfg, x ~ step := 2), x ~ value := range(.x))$x,
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
		with_args(radio, letters ~ inline := TRUE)$letters,
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
		x ~ list(step := 2, ticks := FALSE)
	)
	expect_identical(
		with_filters(cfg, x = "numeric")$x,
		shiny::numericInput("x", "x", value = 10L, min = 2L, max = 10L, step = 2)
	)
})

test_that("a value that uses `.x` is computed when the input is created", {
	cfg <- with_args(shinyfilters(df_config), x ~ value := range(.x))
	expect_identical(
		with_filters(cfg, x = x * 2L)$x,
		shiny::sliderInput("x", "x", min = 4L, max = 20L, value = c(4L, 20L))
	)

	df <- data.frame(a = c(NA, 3L, 1L))
	expect_identical(
		with_args(shinyfilters(df), a ~ value := range(.x))$a,
		shiny::sliderInput("a", "a", min = 1L, max = 3L, value = c(1L, 3L))
	)
})

test_that("other values are evaluated right away and can use the columns", {
	cfg <- shinyfilters(df_config)
	label <- "First"
	set <- with_args(
		cfg,
		x ~ list(label := label, max := max(a_very_very_long_name) * 10)
	)
	label <- "Second"
	expect_identical(
		set$x,
		shiny::sliderInput("x", "First", min = 2L, max = 35, value = 10L)
	)
})

test_that("with_args() passes a `NULL` value", {
	cfg <- shinyfilters(df_config)
	expected <- shiny::selectizeInput(
		"letters",
		"letters",
		choices = c("a", "b", "c"),
		selected = NULL,
		multiple = TRUE
	)
	expect_identical(
		with_args(cfg, letters ~ selected := NULL)$letters,
		expected
	)
	expect_identical(
		with_args(cfg, letters ~ list(selected = NULL))$letters,
		expected
	)
})

test_that("with_args() reads `:=` without calling it", {
	`:=` <- function(...) stop("`:=` was called")
	cfg <- shinyfilters(df_config)
	expect_identical(
		with_args(cfg, x ~ step := 2)$x,
		shiny::sliderInput("x", "x", min = 2L, max = 10L, value = 10L, step = 2)
	)
})

test_that("a value can use shiny::req()", {
	cfg <- shinyfilters(df_config)
	expect_error(
		with_args(cfg, x ~ label := shiny::req(FALSE)),
		class = "shiny.silent.error"
	)
})

test_that("print() shows with_args() arguments", {
	cfg <- with_args(
		shinyfilters(df_config),
		x ~ list(value := range(.x), step = 2),
		letters ~ label := "Letters"
	)
	expect_snapshot(print(cfg), variant = snapshot_variant())
})

test_that("with_filters() sets arguments like with_args()", {
	cfg <- shinyfilters(df_config)
	expect_identical(
		filterInput(with_filters(cfg, x ~ value := range(.x))),
		filterInput(with_args(cfg, x ~ value := range(.x)))
	)
	expect_identical(
		filterInput(with_filters(
			cfg,
			where(is.numeric) ~ list(value := range(.x), step = 2)
		)),
		filterInput(with_args(
			cfg,
			where(is.numeric) ~ list(value := range(.x), step = 2)
		))
	)
	expect_identical(
		filterInput(with_filters(
			cfg,
			across(where(is.numeric), value := range(.x))
		)),
		filterInput(with_args(cfg, across(where(is.numeric), value := range(.x))))
	)
})

test_that("with_filters() takes an input called with `:=` arguments", {
	cfg <- shinyfilters(df_config, slider = FALSE)
	expected <- shiny::sliderInput(
		"x",
		"x",
		min = 2L,
		max = 10L,
		value = c(2L, 10L),
		step = 2
	)
	expect_identical(
		with_filters(cfg, x = shiny::sliderInput(value := range(.x), step := 2))$x,
		expected
	)
	expect_identical(
		with_filters(cfg, x = shiny::sliderInput(value := range(.x), step = 2))$x,
		expected
	)
	expect_identical(
		with_filters(cfg, x ~ shiny::sliderInput(value := range(.x), step = 2))$x,
		expected
	)
	expect_identical(
		with_filters(
			cfg,
			across(x, shiny::sliderInput(value := range(.x), step = 2))
		)$x,
		expected
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
		with_filters(cfg, x = "slider" ~ value := range(.x))$x,
		expected
	)
	expect_identical(
		with_filters(cfg, x = "slider" ~ list(value := range(.x)))$x,
		expected
	)
	expect_identical(
		with_filters(cfg, x ~ "slider" ~ value := range(.x))$x,
		expected
	)
	expect_identical(
		with_filters(cfg, x ~ "slider" ~ list(value = range(.x)))$x,
		expected
	)
	expect_identical(
		with_filters(cfg, across(x, "slider" ~ value := range(.x)))$x,
		expected
	)
	expect_identical(
		with_filters(cfg, x = shiny::sliderInput ~ value := range(.x))$x,
		expected
	)
})

test_that("`.update_fn :=` names the function that updates an input", {
	cfg <- shinyfilters(df_config)
	checkbox <- with_filters(cfg, letters = shiny::checkboxGroupInput)
	set <- with_filters(
		cfg,
		letters = shiny::checkboxGroupInput(
			.update_fn := shiny::updateCheckboxGroupInput
		)
	)
	expect_identical(
		with_filters(
			checkbox,
			letters ~ .update_fn := shiny::updateCheckboxGroupInput
		),
		set
	)
	expect_identical(
		with_args(
			checkbox,
			letters ~ .update_fn := shiny::updateCheckboxGroupInput
		),
		set
	)
	expect_snapshot(print(set), variant = snapshot_variant())
})

test_that("`col := value` is `col = value` for a column the configuration has", {
	cfg <- shinyfilters(df_config)
	col <- "x"
	expect_identical(
		with_filters(cfg, x := "radio"),
		with_filters(cfg, x = "radio")
	)
	expect_identical(
		with_filters(cfg, !!col := "radio"),
		with_filters(cfg, x = "radio")
	)
})

test_that("with_filters() errors with `:=`", {
	cfg <- shinyfilters(df_config)
	expect_snapshot(error = TRUE, variant = snapshot_variant(), {
		with_filters(cfg, value := 1)
		with_filters(cfg, nope = shiny::sliderInput(value := 1))
		with_filters(cfg, nope = step := 2)

		with_filters(cfg, x = shiny::sliderInput(value := 1, 5))
		with_filters(cfg, x ~ inputId := "y")
		with_filters(
			cfg,
			x = shiny::sliderInput(.update_fn := "updateSliderInput")
		)
		with_filters(cfg, x ~ max := nope * 2)
		with_filters(cfg, x = "slider" ~ "radio")
	})
})

test_that("with_args() errors", {
	cfg <- shinyfilters(df_config)
	expect_snapshot(error = TRUE, variant = snapshot_variant(), {
		with_args(df_config, x ~ step := 2)
		with_args(cfg)
		with_args(cfg, x = list(step = 2))
		with_args(cfg, value := 1)
		with_args(cfg, x ~ "slider")
		with_args(cfg, x ~ shiny::sliderInput(value := 1))
		with_args(cfg, x ~ "slider" ~ value := 1)
		with_args(cfg, x ~ list())

		with_args(cfg, x ~ list(step := 2, 5))
		with_args(cfg, x ~ list(step := 2, step = 4))
		with_args(cfg, x ~ inputId := "y")

		with_args(cfg, nope ~ step := 2)
		with_args(cfg, where(is.logical) ~ step := 2)
		with_args(cfg, x ~ max := nope * 2)

		with_args(cfg, across(x))
		with_args(cfg, across(x, step := 2, min := 0))
		with_args(cfg, across(x, step := 2, .names = "a"))
		with_args(cfg, x = across(x, step := 2))
	})
})
