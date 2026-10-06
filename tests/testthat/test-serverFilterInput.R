# tests/testthat/test-serverFilterInput.R

test_that("serverFilterInput works with data.frames", {
	testServer(app_shiny(), {
		res <- serverFilterInput(test_df)
		session$flushReact()
		expect_named(res$input_values, get_input_ids(test_df))
		expect_identical(nrow(res$filtered), nrow(test_df))

		session$setInputs(chr_col = test_df$chr_col[[1]])
		expect_identical(
			res$filtered,
			rows_with_classes(test_df, test_df$chr_col == test_df$chr_col[[1]])
		)
	})
})

test_that("serverFilterInput() updates a column of a custom class with its method", {
	df <- data.frame(
		stringsAsFactors = FALSE,
		color = c("red", "green", "blue"),
		group = c("a", "a", "b")
	)
	df$color <- use_radio(df$color)
	testServer(function(input, output, session) {}, {
		sent <- record_messages(session)
		serverFilterInput(df)
		session$setInputs(group = "a")
		expect_identical(
			sent(),
			update_messages(shiny::updateRadioButtons(
				inputId = "color",
				choices = c("green", "red"),
				selected = character(0)
			))
		)
	})
})

test_that("serverFilterInput() still takes `input`, with a warning", {
	withr::local_options(rlib_warning_verbosity = "verbose")
	testServer(app_shiny(), {
		res <- serverFilterInput(test_df, input)
		expect_snapshot(session$flushReact(), variant = snapshot_variant())
		expect_named(res$input_values, get_input_ids(test_df))

		res <- serverFilterInput(test_df, input = input)
		expect_snapshot(session$flushReact(), variant = snapshot_variant())
		expect_named(res$input_values, get_input_ids(test_df))
	})
})

test_that("serverFilterInput() leaves an empty input empty", {
	testServer(function(input, output, session) {}, {
		sent <- record_messages(session)
		serverFilterInput(df_config, radio = TRUE)
		session$setInputs(x = 9L)
		expect_identical(
			sent(),
			update_messages({
				shiny::updateRadioButtons(
					inputId = "letters",
					choices = c("a", "c"),
					selected = character(0)
				)
				shiny::updateRadioButtons(
					inputId = "factors",
					choices = factor("lo", levels = c("lo", "hi")),
					selected = character(0)
				)
				shiny::updateNumericInput(
					inputId = "a_very_very_long_name",
					min = 2.5,
					max = 3.5
				)
			})
		)
	})
})

test_that("serverFilterInput() passes on a `selected` it is given", {
	testServer(function(input, output, session) {}, {
		sent <- record_messages(session)
		serverFilterInput(df_config["letters"], selected = "a")
		session$flushReact()
		expect_identical(
			sent(),
			update_messages(shiny::updateSelectInput(
				inputId = "letters",
				choices = c("a", "b", "c"),
				selected = "a"
			))
		)
	})
})

test_that("shinyfilters_server() updates a configuration's empty inputs", {
	cfg <- with_filters(
		shinyfilters(df_config),
		letters = as_filter(
			"radio",
			choices = toupper(sort(unique(.x))),
			inline = TRUE
		),
		factors = as_filter(
			shiny::checkboxGroupInput,
			.update_fn = shiny::updateCheckboxGroupInput
		),
		a_very_very_long_name = "slider"
	)
	testServer(function(input, output, session) {}, {
		sent <- record_messages(session)
		res <- shinyfilters_server(cfg)
		session$setInputs(x = 9L)
		expect_identical(res$filtered, df_config[2:3, ])
		expect_identical(
			sent(),
			update_messages({
				shiny::updateRadioButtons(
					inputId = "letters",
					choices = c("A", "C"),
					selected = character(0),
					inline = TRUE
				)
				shiny::updateCheckboxGroupInput(
					inputId = "factors",
					choices = factor("lo", levels = c("lo", "hi")),
					selected = character(0)
				)
				shiny::updateSliderInput(
					inputId = "a_very_very_long_name",
					min = 2.5,
					max = 3.5
				)
			})
		)
	})
})

test_that("shinyfilters_server() reads and updates the inputs of a namespace", {
	cfg <- with_ns(shinyfilters(df_config), "m")
	# Radio buttons carry the session's namespace in their options, so the
	# messages differ if the module's session sends them.
	cfg <- with_filters(cfg, letters = "radio")
	expected <- update_messages({
		shiny::updateRadioButtons(
			inputId = "m-letters",
			choices = c("a", "c"),
			selected = character(0)
		)
		shiny::updateSelectInput(
			inputId = "m-factors",
			choices = factor("lo", levels = c("lo", "hi")),
			selected = character(0)
		)
		shiny::updateNumericInput(
			inputId = "m-a_very_very_long_name",
			min = 2.5,
			max = 3.5
		)
	})
	testServer(function(input, output, session) {}, {
		sent <- record_messages(session)
		res <- shinyfilters_server(cfg)
		session$setInputs(`m-x` = 9L)
		expect_identical(res$filtered, df_config[2:3, ])
		expect_identical(sent(), expected)
	})
	testServer(function(input, output, session) {}, {
		sent <- record_messages(session)
		res <- shiny::withReactiveDomain(
			session$makeScope("m"),
			shinyfilters_server(cfg)
		)
		session$setInputs(`m-x` = 9L)
		expect_identical(res$filtered, df_config[2:3, ])
		expect_identical(sent(), expected)
	})
})

test_that("shinyfilters_server() errors when called, for an input it can't update", {
	cfg <- with_filters(
		shinyfilters(df_config),
		letters = shiny::checkboxGroupInput
	)
	expect_snapshot(error = TRUE, variant = snapshot_variant(), {
		shinyfilters_server(cfg)
	})
})

test_that("._prepare_input() with reactiveExpr returns valid list for all test_df columns", {
	testServer(app_shiny(), {
		# Create reactive with all required columns from test_df
		input_list <- reactive({
			set_names(
				lapply(get_input_ids(test_df), function(x) NULL),
				get_input_ids(test_df)
			)
		})

		res <- serverFilterInput(test_df, input = input_list)
		suppressWarnings(session$flushReact())
		expect_s3_class(res, "reactivevalues")
		expect_named(res$input_values, get_input_ids(test_df))
	})
})

test_that("._prepare_input() with reactiveExpr filters out unsupported columns", {
	testServer(app_shiny(), {
		# Provide all required columns plus extras
		input_list <- reactive({
			c(
				set_names(
					lapply(get_input_ids(test_df), function(x) NULL),
					get_input_ids(test_df)
				),
				list(unsupported_col = "extra")
			)
		})

		res <- serverFilterInput(test_df, input = input_list)
		suppressWarnings(session$flushReact())

		# Verify unsupported column was filtered out
		expect_named(res$input_values, get_input_ids(test_df))
	})
})

test_that("._prepare_input() with reactivevalues extracts values correctly", {
	testServer(app_shiny(), {
		# Using default input (reactivevalues)
		res <- serverFilterInput(test_df)
		session$flushReact()

		expect_s3_class(res, "reactivevalues")
		expect_named(res$input_values, get_input_ids(test_df))
	})
})

# Errors ####
test_that("serverFilterInput() with reactive() throws error when missing required columns", {
	testServer(app_shiny(), {
		input_list <- reactive(list(chr_col = "a", num_col = 5))
		expect_snapshot(error = TRUE, variant = snapshot_variant(), {
			._prepare_input(input_list, x = test_df)
		})
	})
})

test_that("serverFilterInput() with reactive() warns when extra columns provided", {
	testServer(app_shiny(), {
		input_list <- reactive({
			out <- vector("list", ncol(test_df))
			names(out) <- get_input_ids(test_df)
			c(out, list(unsupported = "x"))
		})
		expect_snapshot(
			invisible(._prepare_input(input_list, x = test_df)),
			variant = snapshot_variant()
		)
	})
})
