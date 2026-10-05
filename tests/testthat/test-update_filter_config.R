test_that("updateFilterInput() updates the input a configuration creates", {
	cfg <- shinyfilters(df_config)
	expect_identical(
		update_messages(updateFilterInput(cfg["x"])),
		update_messages(
			shiny::updateNumericInput(inputId = "x", min = 2L, max = 10L)
		)
	)
	expect_identical(
		update_messages(
			updateFilterInput(shinyfilters(df_config, slider = TRUE)["x"])
		),
		update_messages(
			shiny::updateSliderInput(inputId = "x", min = 2L, max = 10L)
		)
	)
	expect_identical(
		update_messages(updateFilterInput(with_filter(cfg, x = "slider")["x"])),
		update_messages(
			shiny::updateSliderInput(inputId = "x", min = 2L, max = 10L)
		)
	)
	expect_identical(
		update_messages(
			updateFilterInput(with_filter(cfg, letters = "radio")["letters"])
		),
		update_messages(shiny::updateRadioButtons(
			inputId = "letters",
			choices = c("a", "b", "c")
		))
	)
})

test_that("updateFilterInput() updates every column of a configuration", {
	cfg <- with_filter(shinyfilters(df_config), x = "slider")
	expect_identical(
		update_messages(updateFilterInput(cfg)),
		update_messages({
			shiny::updateSelectInput(inputId = "letters", choices = c("a", "b", "c"))
			shiny::updateSelectInput(
				inputId = "factors",
				choices = factor(c("lo", "hi"), levels = c("lo", "hi"))
			)
			shiny::updateSliderInput(inputId = "x", min = 2L, max = 10L)
			shiny::updateNumericInput(
				inputId = "a_very_very_long_name",
				min = 1.5,
				max = 3.5
			)
		})
	)
})

test_that("an input chosen with with_filter() wins over a default", {
	cfg <- shinyfilters(df_config, selectize = TRUE, slider = TRUE)
	expect_identical(
		update_messages(
			updateFilterInput(with_filter(cfg, letters = "radio")["letters"])
		),
		update_messages(shiny::updateRadioButtons(
			inputId = "letters",
			choices = c("a", "b", "c")
		))
	)
	expect_identical(
		update_messages(
			updateFilterInput(with_filter(cfg, x = shiny::numericInput)["x"])
		),
		update_messages(
			shiny::updateNumericInput(inputId = "x", min = 2L, max = 10L)
		)
	)
})

test_that("numeric + radio / selectize -> choices are updated", {
	cfg <- shinyfilters(df_config)
	expect_identical(
		update_messages(updateFilterInput(with_filter(cfg, x = "radio")["x"])),
		update_messages(shiny::updateRadioButtons(
			inputId = "x",
			choices = c(2L, 9L, 10L)
		))
	)
	expect_identical(
		update_messages(updateFilterInput(with_filter(cfg, x = "selectize")["x"])),
		update_messages(shiny::updateSelectizeInput(
			inputId = "x",
			choices = c(2L, 9L, 10L)
		))
	)
})

test_that("updateFilterInput() passes the as_filter() arguments an update takes", {
	cfg <- shinyfilters(df_config)
	slider <- as_filter("slider", value = range(.x), step = 2, width = "50%")
	expect_identical(
		update_messages(updateFilterInput(with_filter(cfg, x = slider)["x"])),
		update_messages(
			shiny::updateSliderInput(inputId = "x", min = 2L, max = 10L, step = 2)
		)
	)
	radio <- as_filter("radio", label = "Letters", inline = TRUE)
	expect_identical(
		update_messages(
			updateFilterInput(with_filter(cfg, letters = radio)["letters"])
		),
		update_messages(shiny::updateRadioButtons(
			inputId = "letters",
			label = "Letters",
			choices = c("a", "b", "c"),
			inline = TRUE
		))
	)
	expect_identical(
		update_messages(updateFilterInput(
			with_filter(
				shinyfilters(df_config, slider = TRUE),
				x = as_filter(step = 2)
			)["x"]
		)),
		update_messages(
			shiny::updateSliderInput(inputId = "x", min = 2L, max = 10L, step = 2)
		)
	)
})

test_that("updateFilterInput() leaves out a default that sets a value", {
	cfg <- shinyfilters(df_config, selected = "a")["letters"]
	expect_identical(
		update_messages(updateFilterInput(cfg)),
		update_messages(shiny::updateSelectInput(
			inputId = "letters",
			choices = c("a", "b", "c")
		))
	)
	expect_identical(
		update_messages(updateFilterInput(cfg, selected = "b")),
		update_messages(shiny::updateSelectInput(
			inputId = "letters",
			choices = c("a", "b", "c"),
			selected = "b"
		))
	)
})

test_that("as_filter() arguments are computed from the data being updated", {
	cfg <- with_filter(
		shinyfilters(df_config),
		letters = as_filter(choices = toupper(sort(unique(.x))))
	)
	expect_identical(
		update_messages(updateFilterInput(cfg["letters"])),
		update_messages(shiny::updateSelectInput(
			inputId = "letters",
			choices = c("A", "B", "C")
		))
	)
})

test_that("updateFilterInput() calls `.update_fn`", {
	cfg <- with_filter(
		shinyfilters(df_config),
		letters = as_filter(
			shiny::checkboxGroupInput,
			inline = TRUE,
			.update_fn = shiny::updateCheckboxGroupInput
		)
	)
	expect_identical(
		update_messages(updateFilterInput(cfg["letters"])),
		update_messages(shiny::updateCheckboxGroupInput(
			inputId = "letters",
			choices = c("a", "b", "c"),
			inline = TRUE
		))
	)
})

test_that("updateFilterInput() calls a shinyWidgets update function", {
	skip_if_not_installed("shinyWidgets")
	cfg <- with_filter(
		shinyfilters(df_config),
		letters = as_filter(
			shinyWidgets::pickerInput,
			.update_fn = shinyWidgets::updatePickerInput
		)
	)
	expect_identical(
		update_messages(updateFilterInput(cfg["letters"])),
		update_messages(shinyWidgets::updatePickerInput(
			inputId = "letters",
			choices = c("a", "b", "c")
		))
	)
})

test_that("updateFilterInput() updates the inputs of a namespace", {
	cfg <- with_ns(shinyfilters(df_config), "m")
	# Radio buttons carry the session's namespace in their options, so the
	# messages differ if the module's session sends them.
	cfg <- with_filter(cfg, letters = "radio")["letters"]
	expected <- update_messages(shiny::updateRadioButtons(
		inputId = "m-letters",
		choices = c("a", "b", "c")
	))
	expect_identical(update_messages(updateFilterInput(cfg)), expected)

	session <- shiny::MockShinySession$new()
	expect_identical(
		update_messages(
			updateFilterInput(cfg, session = session$makeScope("m")),
			session
		),
		expected
	)
})

test_that("arguments passed to updateFilterInput() win over a default", {
	cfg <- shinyfilters(df_config, slider = TRUE)["x"]
	expect_identical(
		update_messages(updateFilterInput(cfg, slider = FALSE)),
		update_messages(
			shiny::updateNumericInput(inputId = "x", min = 2L, max = 10L)
		)
	)
})

test_that("updateFilterInput() follows the range and textbox keywords", {
	df <- data.frame(
		stringsAsFactors = FALSE,
		day = as.Date("2024-01-01") + 0:2,
		name = c("a", "b", "c")
	)
	cfg <- with_filter(shinyfilters(df), day = "range", name = "textbox")
	expect_identical(
		update_messages(updateFilterInput(cfg)),
		update_messages({
			shiny::updateDateRangeInput(
				inputId = "day",
				min = df$day[[1]],
				max = df$day[[3]]
			)
			shiny::updateTextInput(inputId = "name")
		})
	)
})

test_that("updateFilterInput() errors for an input it can't update", {
	cfg <- shinyfilters(df_config)
	expect_snapshot(error = TRUE, variant = snapshot_variant(), {
		updateFilterInput(with_filter(cfg, letters = shiny::checkboxGroupInput))
		updateFilterInput(
			with_filter(cfg, c(letters, factors), shiny::checkboxGroupInput)
		)

		update_messages(updateFilterInput(with_filter(
			cfg,
			letters = as_filter(
				shiny::checkboxGroupInput,
				.update_fn = shiny::updateNumericInput
			)
		)))
	})
})
