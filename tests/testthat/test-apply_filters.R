# apply_filters() ####

# Basic functionality ####
test_that("apply_filters() returns unmodified object when filter_list is NULL", {
	result <- apply_filters(test_df, filter_list = NULL)
	expect_identical(result, test_df)
})

test_that("apply_filters() filters data.frame with single column filter", {
	filter_list <- list(chr_col = "a")
	result <- apply_filters(test_df, filter_list)
	expected <- rows_with_classes(test_df, test_df$chr_col == "a")
	expect_identical(result, expected)
})

test_that("apply_filters() filters data.frame with multiple values in single column", {
	filter_list <- list(chr_col = c("a", "b"))
	result <- apply_filters(test_df, filter_list)
	expected <- rows_with_classes(test_df, test_df$chr_col %in% c("a", "b"))
	expect_identical(result, expected)
})

test_that("apply_filters() filters with logical AND (default)", {
	filter_list <- list(
		chr_col = "a",
		num_col = c(1, 2)
	)
	result <- apply_filters(test_df, filter_list, filter_combine_method = "and")
	expected <- rows_with_classes(
		test_df,
		test_df$chr_col == "a" & test_df$num_col %in% c(1, 2)
	)
	expect_identical(result, expected)
})

test_that("apply_filters() filters with logical OR", {
	filter_list <- list(
		chr_col = "a",
		num_col = c(1, 2)
	)
	result <- apply_filters(test_df, filter_list, filter_combine_method = "or")
	expected <- rows_with_classes(
		test_df,
		test_df$chr_col == "a" | test_df$num_col %in% c(1, 2)
	)
	expect_identical(result, expected)
})

test_that("apply_filters() filters with string shortcuts for AND", {
	filter_list <- list(chr_col = "a")
	result_and <- apply_filters(
		test_df,
		filter_list,
		filter_combine_method = "and"
	)
	result_ampersand <- apply_filters(
		test_df,
		filter_list,
		filter_combine_method = "&"
	)
	expect_identical(result_and, result_ampersand)
})

test_that("apply_filters() filters with string shortcuts for OR", {
	filter_list <- list(chr_col = "a")
	result_or <- apply_filters(test_df, filter_list, filter_combine_method = "or")
	result_pipe <- apply_filters(
		test_df,
		filter_list,
		filter_combine_method = "|"
	)
	expect_identical(result_or, result_pipe)
})

# Custom combine function ####
test_that("apply_filters() works with custom combine function", {
	# XOR function that combines with exclusive or
	xor_fn <- function(a, b) {
		xor(a, b)
	}
	filter_list <- list(
		chr_col = "a",
		num_col = c(1, 2)
	)
	result <- apply_filters(test_df, filter_list, filter_combine_method = xor_fn)
	expected_logical <- xor(
		test_df$chr_col == "a",
		test_df$num_col %in% c(1, 2)
	)
	expected <- rows_with_classes(test_df, expected_logical)
	expect_identical(result, expected)
})

# cols argument ####
test_that("apply_filters() returns specified columns when cols is provided", {
	filter_list <- list(chr_col = "a")
	result <- apply_filters(test_df, filter_list, cols = "num_col")
	expected <- test_df[test_df$chr_col == "a", "num_col", drop = FALSE]
	expect_identical(result, expected)
})

test_that("apply_filters() returns multiple columns when cols contains multiple columns", {
	filter_list <- list(chr_col = "a")
	result <- apply_filters(test_df, filter_list, cols = c("num_col", "chr_col"))
	expected <- test_df[
		test_df$chr_col == "a",
		c("num_col", "chr_col"),
		drop = FALSE
	]
	expect_identical(result, expected)
})

# expanded argument ####
test_that("apply_filters() returns expanded list with expanded = TRUE", {
	filter_list <- list(
		chr_col = "a",
		num_col = c(1, 2)
	)
	result <- apply_filters(test_df, filter_list, expanded = TRUE)
	expect_type(result, "list")
	expect_true("chr_col" %in% names(result))
	expect_true("num_col" %in% names(result))
})

test_that("apply_filters() expanded filters other columns", {
	filter_list <- list(
		chr_col = "a",
		num_col = c(1, 2)
	)
	result <- apply_filters(test_df, filter_list, expanded = TRUE)
	# chr_col should be filtered by num_col only
	chr_result <- result$chr_col
	num_result <- result$num_col
	expect_identical(
		chr_result,
		test_df[test_df$num_col %in% c(1, 2), "chr_col", drop = FALSE]
	)
	expect_identical(
		num_result,
		test_df[test_df$chr_col == "a", "num_col", drop = FALSE]
	)
})

test_that("apply_filters() expanded returns single column data.frames", {
	filter_list <- list(
		chr_col = "a",
		num_col = c(1, 2)
	)
	result <- apply_filters(test_df, filter_list, expanded = TRUE)
	expect_equal(ncol(result$chr_col), 1)
	expect_equal(ncol(result$num_col), 1)
})

# Vector filtering ####
test_that("apply_filters() filters vectors", {
	x <- 1:10
	filter_list <- list(x = c(1, 2, 3))
	result <- apply_filters(x, filter_list)
	expected <- x[x %in% c(1, 2, 3)]
	expect_identical(result, expected)
})

# Column attributes ####
test_that("apply_filters() keeps the column attributes row subsetting drops", {
	df <- data.frame(stringsAsFactors = FALSE, chr = c("x", "y", "z"), num = 1:3)
	df$chr <- use_radio(df$chr)
	attr(df$num, "label") <- "Number"
	result <- apply_filters(df, list(num = c(2, 3)))
	expect_identical(result$chr, use_radio(c("y", "z")))
	expect_identical(attr(result$num, "label"), "Number")
	expect_identical(
		apply_filters(df, list(num = c(2, 3)), cols = "chr")$chr,
		use_radio(c("y", "z"))
	)
})

# Missing values ####
test_that("apply_filters() drops rows with a missing value in a filtered column", {
	df <- data.frame(
		stringsAsFactors = FALSE,
		num = c(1, NA, 3),
		chr = c("x", NA, "z")
	)
	expect_identical(apply_filters(df, list(num = c(0, 5))), df[c(1, 3), ])
	expect_identical(apply_filters(df, list(chr = "x")), df[1, ])
	expect_identical(apply_filters(c(1, NA, 3), list(x = c(0, 5))), c(1, 3))
})

test_that("apply_filters() combines filters after a missing value fails its own", {
	df <- data.frame(
		stringsAsFactors = FALSE,
		num = c(1, NA, 3),
		chr = c("x", "x", "z")
	)
	filter_list <- list(num = c(0, 5), chr = "z")
	expect_identical(
		apply_filters(df, filter_list, filter_combine_method = "or"),
		df[c(1, 3), ]
	)
	expect_identical(
		apply_filters(df, filter_list, filter_combine_method = xor),
		df[1, ]
	)
	expect_identical(
		apply_filters(
			df,
			list(num = c(0, 5), chr = "x"),
			filter_combine_method = xor
		),
		df[2:3, ]
	)
})

test_that("apply_filters() keeps a missing value when NA is a filter value", {
	df <- data.frame(stringsAsFactors = FALSE, num = c(1, NA, 3))
	expect_identical(
		apply_filters(df, list(num = c(1, NA))),
		df[1:2, , drop = FALSE]
	)
})

# Combination tests ####
test_that("apply_filters() with expanded and cols works together", {
	filter_list <- list(
		chr_col = "a",
		num_col = c(1, 2)
	)
	result <- apply_filters(
		test_df,
		filter_list,
		expanded = TRUE,
		cols = "chr_col"
	)
	expect_type(result, "list")
	expect_true("chr_col" %in% names(result))
	expect_equal(ncol(result$chr_col), 1)
})

test_that("apply_filters() preserves data.frame class", {
	filter_list <- list(chr_col = "a")
	result <- apply_filters(test_df, filter_list)
	expect_true(is.data.frame(result))
})

test_that("apply_filters() preserves row names when filtering", {
	df <- test_df
	rownames(df) <- paste0("row_", seq_len(nrow(df)))
	filter_list <- list(chr_col = "a")
	result <- apply_filters(df, filter_list)
	expect_true(all(grepl("row_", rownames(result), fixed = TRUE)))
})

# Errors ####
test_that("apply_filters: unknown filter_combine_method", {
	expect_snapshot(error = TRUE, variant = snapshot_variant(), {
		apply_filters(
			test_df,
			list(chr_col = "i"),
			filter_combine_method = "unk"
		)
	})
})

test_that("apply_filters: filter_combine_method must be function", {
	expect_snapshot(error = TRUE, variant = snapshot_variant(), {
		apply_filters(
			test_df,
			list(chr_col = "i"),
			filter_combine_method = 123
		)
	})
})
