# tests/testthat/test-serverFilterInput.R

test_that("serverFilterInput works with data.frames", {
	testServer(app_shiny(), {
		res <- serverFilterInput(test_df, input)
		test_df_filt <- apply_filters(test_df, res$input_values)
		expect_s3_class(test_df_filt, "data.frame")
		expect_lte(nrow(test_df_filt), nrow(test_df))
	})
})

test_that("._prepare_input() with reactiveExpr returns valid list for all test_df columns", {
	testServer(app_shiny(), {
		# Create reactive with all required columns from test_df
		input_list <- reactive({
			setNames(
				lapply(get_input_ids(test_df), function(x) NULL),
				get_input_ids(test_df)
			)
		})

		res <- serverFilterInput(test_df, input = input_list)
		expect_s3_class(res, "reactivevalues")
		expect_named(res$input_values, names(input_list))
	})
})

test_that("._prepare_input() with reactiveExpr filters out unsupported columns", {
	testServer(app_shiny(), {
		# Provide all required columns plus extras
		input_list <- reactive({
			c(
				setNames(
					lapply(get_input_ids(test_df), function(x) NULL),
					get_input_ids(test_df)
				),
				list(unsupported_col = "extra")
			)
		})

		suppressWarnings({
			res <- serverFilterInput(test_df, input = input_list)
		})

		# Verify unsupported column was filtered out
		expect_false("unsupported_col" %in% names(res$input_values))
		expect_true(all(names(res$input_values) %in% get_input_ids(test_df)))
	})
})

test_that("._prepare_input() with reactivevalues extracts values correctly", {
	testServer(app_shiny(), {
		# Using default input (reactivevalues)
		res <- serverFilterInput(test_df, input)

		expect_s3_class(res, "reactivevalues")
		expect_true(all(names(res$input_values) %in% get_input_ids(test_df)))
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
