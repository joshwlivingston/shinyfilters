# tests/testthat/test-updateFilterInput.R

test_that("updateFilterInput works with character vectors", {
	n <- 0L
	testServer(app_shiny(), {
		chr_col <- test_df[, "chr_col", drop = FALSE]
		chr_col_vec <- test_df[, "chr_col"]
		idx_selected <- 1L
		chr_col_filt <- chr_col[idx_selected, , drop = FALSE]
		chr_col_id <- get_input_ids(chr_col)

		# Update filterInput choices to filtered vector
		expect_no_error(updateFilterInput(chr_col_filt, session = session))

		# Selecting a valid choice should change the input
		expect_no_error(updateFilterInput(
			chr_col_filt,
			selected = chr_col_filt[idx_selected, ],
			session = session
		))
	})
})

test_that("updateFilterInput works with character textbox", {
	testServer(
		shinyApp(
			fluidPage(
				sidebarLayout(
					sidebarPanel(
						filterInput(
							letters,
							inputId = "letters",
							label = "",
							textbox = TRUE
						)
					),
					mainPanel()
				)
			),
			function(input, output, session) {}
		),
		{
			# Update text input
			expect_no_error(updateFilterInput(
				letters[1:3],
				textbox = TRUE,
				session = session
			))
		}
	)
})

test_that("updateFilterInput works with character textarea", {
	testServer(
		shinyApp(
			fluidPage(
				sidebarLayout(
					sidebarPanel(
						filterInput(
							letters,
							inputId = "letters",
							label = "",
							textbox = TRUE,
							area = TRUE
						)
					),
					mainPanel()
				)
			),
			function(input, output, session) {}
		),
		{
			# Update textarea input
			expect_no_error(updateFilterInput(
				letters[1:3],
				textbox = TRUE,
				area = TRUE,
				session = session
			))
		}
	)
})

test_that("updateFilterInput works with radio buttons", {
	testServer(app_shiny(), {
		chr_col <- test_df[, "chr_col", drop = FALSE]

		# Update radio buttons
		expect_no_error(updateFilterInput(
			chr_col,
			radio = TRUE,
			session = session
		))
	})
})

test_that("updateFilterInput works with selectize input", {
	testServer(app_shiny(), {
		chr_col <- test_df[, "chr_col", drop = FALSE]

		# Update selectize input
		expect_no_error(updateFilterInput(
			chr_col,
			selectize = TRUE,
			session = session
		))
	})
})

test_that("updateFilterInput works with numeric vectors", {
	testServer(app_shiny(), {
		num_col <- test_df[, "num_col", drop = FALSE]

		# Update numeric input (default)
		expect_no_error(updateFilterInput(
			num_col,
			session = session
		))
	})
})

test_that("updateFilterInput works with slider input", {
	testServer(app_shiny(), {
		num_col <- test_df[, "num_col", drop = FALSE]

		# Update slider input
		expect_no_error(updateFilterInput(
			num_col,
			slider = TRUE,
			session = session
		))
	})
})

test_that("updateFilterInput works with Date vectors", {
	testServer(app_shiny(), {
		date_col <- test_df[, "dte_col", drop = FALSE]

		# Update date input (default)
		expect_no_error(updateFilterInput(
			date_col,
			session = session
		))
	})
})

test_that("updateFilterInput works with date range input", {
	testServer(app_shiny(), {
		date_col <- test_df[, "dte_col", drop = FALSE]

		# Update date range input
		expect_no_error(updateFilterInput(
			date_col,
			range = TRUE,
			session = session
		))
	})
})

test_that("updateFilterInput works with POSIXt vectors", {
	testServer(app_shiny(), {
		posix_col <- test_df[, "psl_col", drop = FALSE]
		# Update POSIXt input (converts to Date)
		expect_no_error(updateFilterInput(
			posix_col,
			session = session
		))
	})
})

test_that("updateFilterInput works with factor vectors", {
	testServer(app_shiny(), {
		factor_col <- test_df[, "fct_col", drop = FALSE]

		# Update factor input (default select)
		expect_no_error(updateFilterInput(
			factor_col,
			session = session
		))
	})
})

test_that("updateFilterInput works with factor radio buttons", {
	testServer(app_shiny(), {
		factor_col <- test_df[, "fct_col", drop = FALSE]

		# Update factor radio buttons
		expect_no_error(updateFilterInput(
			factor_col,
			radio = TRUE,
			session = session
		))
	})
})

test_that("updateFilterInput works with lists", {
	testServer(
		shinyApp(
			fluidPage(
				sidebarLayout(
					sidebarPanel(
						filterInput(as.list(letters), inputId = "letters", label = "")
					),
					mainPanel()
				)
			),
			function(input, output, session) {}
		),
		{
			list_filt <- as.list(letters[1:10])
			# Update logical input
			expect_no_error(updateFilterInput(
				list_filt,
				session = session
			))
		}
	)
})

test_that("updateFilterInput works with logical vectors", {
	testServer(app_shiny(), {
		logical_col <- test_df[, "log_col", drop = FALSE]

		# Update logical input
		expect_no_error(updateFilterInput(
			logical_col,
			session = session
		))
	})
})

test_that("updateFilterInput works with data.frame", {
	testServer(app_shiny(), {
		# Update all inputs for a data.frame
		expect_no_error(updateFilterInput(
			test_df,
			session = session
		))
	})
})

# Errors ####
## call_update_filter_input ####
test_that("call_update_filter_input errors for data.frames", {
	expect_snapshot(error = TRUE, variant = snapshot_variant(), {
		call_update_filter_input(test_df, shiny::updateSelectInput)
	})
})

test_that("updateFilterInput: radio and selectize cannot both be TRUE", {
	expect_snapshot(error = TRUE, variant = snapshot_variant(), {
		updateFilterInput(
			choices_chr,
			inputId = "test",
			radio = TRUE,
			selectize = TRUE
		)
	})
})

test_that("updateFilterInput: method not found for S7 object passed as list", {
	obj <- ClassList(as.list(letters))
	expect_snapshot(error = TRUE, variant = snapshot_variant(), {
		updateFilterInput(obj, inputId = "x")
	})
})
