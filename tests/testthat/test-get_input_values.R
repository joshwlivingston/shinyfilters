# tests/testthat/test-get_input_values.R

test_that("get_input_values works with data.frame", {
	testServer(app_shiny(), {
		# Get input values using data.frame
		result <- get_input_values(input, test_df)

		# Should return a list
		expect_type(result, "list")

		# Should have names matching column names
		expect_named(result, names(test_df))

		# Each element should correspond to an input value
		expect_length(result, ncol(test_df))
	})
})

test_that("get_input_values works with character vector", {
	testServer(app_shiny(), {
		# Select specific columns
		cols_to_get <- c("chr_col", "num_col", "log_col")
		result <- get_input_values(input, cols_to_get)

		# Should return a list
		expect_type(result, "list")

		# Should have names matching requested columns
		expect_named(result, cols_to_get)

		# Should have correct length
		expect_length(result, length(cols_to_get))
	})
})

test_that("get_input_values handles single column", {
	testServer(app_shiny(), {
		# Get single column
		result <- get_input_values(input, "chr_col")

		# Should return a list with one element
		expect_type(result, "list")
		expect_length(result, 1)
		expect_named(result, "chr_col")
	})
})

test_that("get_input_values returns NULL for unset inputs", {
	testServer(app_shiny(), {
		# Get values before any user interaction
		result <- get_input_values(input, test_df)

		# All values should be NULL initially (no user input yet)
		all_null <- all(vapply(result, is.null, logical(1)))
		expect_true(all_null)
	})
})

test_that("get_input_values preserves input structure", {
	testServer(app_shiny(), {
		# Simulate setting some input values
		session$setInputs(chr_col = c("a", "b"))
		session$setInputs(num_col = c(1, 2, 3))
		session$setInputs(log_col = TRUE)

		result <- get_input_values(input, c("chr_col", "num_col", "log_col"))

		# Check that values match what was set
		expect_equal(result$chr_col, c("a", "b"))
		expect_equal(result$num_col, c(1, 2, 3))
		expect_equal(result$log_col, TRUE)
	})
})

test_that("get_input_values works with subset of columns", {
	testServer(app_shiny(), {
		# Get only specific columns
		subset_cols <- c("chr_col", "dte_col", "fct_col")
		result <- get_input_values(input, subset_cols)

		# Should only return requested columns
		expect_length(result, length(subset_cols))
		expect_true(all(names(result) %in% subset_cols))
		expect_false(any(c("num_col", "log_col") %in% names(result)))
	})
})

test_that("get_input_values with empty character vector", {
	testServer(app_shiny(), {
		# Get empty set of columns
		result <- get_input_values(input, character(0))

		# Should return an empty list
		expect_type(result, "list")
		expect_length(result, 0)
	})
})

test_that("get_input_values method dispatch works correctly", {
	testServer(app_shiny(), {
		# Test with data.frame (should call data.frame method)
		result_df <- get_input_values(input, test_df)

		# Test with character vector (should call character method)
		result_chr <- get_input_values(input, names(test_df))

		# Both should produce equivalent results
		expect_equal(names(result_df), names(result_chr))
		expect_equal(result_df, result_chr)
	})
})
