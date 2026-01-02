# Basic functionality ####

## character ####
test_that("args_update_filter_input() returns choices without selected for character", {
	result <- args_update_filter_input(choices_chr_with_na)
	expected <- list(choices = unique(sort(choices_chr_with_na)))
	expect_identical(result, expected)
})

test_that("args_update_filter_input() with textbox = FALSE returns choices without selected for character", {
	result <- args_update_filter_input(choices_chr_with_na, textbox = FALSE)
	expected <- list(choices = unique(sort(choices_chr_with_na)))
	expect_identical(result, expected)
})

test_that("args_update_filter_input() with textbox = TRUE returns NULL for character", {
	result <- args_update_filter_input(choices_chr_with_na, textbox = TRUE)
	expect_null(result)
})

## factor ####
test_that("args_update_filter_input() returns choices without selected for factor", {
	result <- args_update_filter_input(choices_fct_with_na)
	expected <- list(choices = unique(sort(choices_fct_with_na)))
	expect_identical(result, expected)
})

## logical ####
test_that("args_update_filter_input() returns choices without selected for logical", {
	result <- args_update_filter_input(choices_log_with_na)
	expected <- list(choices = unique(sort(choices_log_with_na)))
	expect_identical(result, expected)
})

## list ####
test_that("args_update_filter_input() returns choices without selected for list", {
	result <- args_update_filter_input(choices_lst_with_na)
	expected <- list(choices = choices_lst_with_na)
	expect_identical(result, expected)
})

## numeric ####
test_that("args_update_filter_input() returns min/max without value for numeric", {
	result <- args_update_filter_input(choices_num_with_na)
	expected <- list(
		min = min(choices_num_with_na, na.rm = TRUE),
		max = max(choices_num_with_na, na.rm = TRUE)
	)
	expect_identical(result, expected)
})

## Date ####
test_that("args_update_filter_input() returns min/max without value for Date", {
	result <- args_update_filter_input(choices_dte_with_na)
	expected <- list(
		min = min(choices_dte_with_na, na.rm = TRUE),
		max = max(choices_dte_with_na, na.rm = TRUE)
	)
	expect_identical(result, expected)
})

test_that("args_update_filter_input() with range = TRUE returns min/max with start/end for Date", {
	result <- args_update_filter_input(choices_dte_with_na, range = TRUE)
	expected <- list(
		min = min(choices_dte_with_na, na.rm = TRUE),
		max = max(choices_dte_with_na, na.rm = TRUE),
		start = min(choices_dte_with_na, na.rm = TRUE),
		end = max(choices_dte_with_na, na.rm = TRUE)
	)
	expect_identical(result, expected)
})

## POSIXct ####
test_that("args_update_filter_input() returns min/max Dates without value for POSIXct", {
	result <- args_update_filter_input(choices_psc_with_na)
	expected <- list(
		min = min(as.Date(choices_psc_with_na), na.rm = TRUE),
		max = max(as.Date(choices_psc_with_na), na.rm = TRUE)
	)
	expect_identical(result, expected)
})

test_that("args_update_filter_input() with range = TRUE returns min/max with start/end for POSIXct", {
	result <- args_update_filter_input(choices_psc_with_na, range = TRUE)
	expected <- list(
		min = min(as.Date(choices_psc_with_na), na.rm = TRUE),
		max = max(as.Date(choices_psc_with_na), na.rm = TRUE),
		start = min(as.Date(choices_psc_with_na), na.rm = TRUE),
		end = max(as.Date(choices_psc_with_na), na.rm = TRUE)
	)
	expect_identical(result, expected)
})

## POSIXlt ####
test_that("args_update_filter_input() returns min/max Dates without value for POSIXlt", {
	result <- args_update_filter_input(choices_psl_with_na)
	expected <- list(
		min = min(as.Date(choices_psl_with_na), na.rm = TRUE),
		max = max(as.Date(choices_psl_with_na), na.rm = TRUE)
	)
	expect_identical(result, expected)
})

test_that("args_update_filter_input() with range = TRUE returns min/max without start/end for POSIXlt", {
	result <- args_update_filter_input(choices_psl_with_na, range = TRUE)
	expected <- list(
		min = min(as.Date(choices_psl_with_na), na.rm = TRUE),
		max = max(as.Date(choices_psl_with_na), na.rm = TRUE),
		start = min(as.Date(choices_psl_with_na), na.rm = TRUE),
		end = max(as.Date(choices_psl_with_na), na.rm = TRUE)
	)
	expect_identical(result, expected)
})

# Additional arguments ####

## choices_asis ####
test_that("args_update_filter_input() respects choices_asis = TRUE for character", {
	duplicated_chr <- c("a", "b", "a", "c", "b")
	result <- args_update_filter_input(duplicated_chr, choices_asis = TRUE)
	expected <- list(choices = duplicated_chr)
	expect_identical(result, expected)
})

test_that("args_update_filter_input() respects choices_asis = FALSE for character", {
	duplicated_chr <- c("a", "b", "a", "c", "b")
	result <- args_update_filter_input(duplicated_chr, choices_asis = FALSE)
	expected <- list(choices = unique(sort(duplicated_chr)))
	expect_identical(result, expected)
})

## args_sort ####
test_that("args_update_filter_input() passes decreasing to sort for character", {
	result <- args_update_filter_input(
		choices_chr_with_na,
		args_sort = list(decreasing = TRUE)
	)
	expected <- list(
		choices = unique(sort(choices_chr_with_na, decreasing = TRUE))
	)
	expect_identical(result, expected)
})

test_that("args_update_filter_input() passes na.last to sort for character", {
	result <- args_update_filter_input(
		choices_chr_with_na,
		args_sort = list(na.last = TRUE)
	)
	expected <- list(
		choices = unique(sort(choices_chr_with_na, na.last = TRUE))
	)
	expect_identical(result, expected)
})

test_that("args_update_filter_input() passes multiple sort args for factor", {
	result <- args_update_filter_input(
		choices_fct_with_na,
		args_sort = list(
			decreasing = TRUE,
			na.last = FALSE
		)
	)
	expected <- list(
		choices = unique(sort(
			choices_fct_with_na,
			decreasing = TRUE,
			na.last = FALSE
		))
	)
	expect_identical(result, expected)
})

## args_unique ####
test_that("args_update_filter_input() passes args to unique for character", {
	result <- args_update_filter_input(
		choices_chr_with_na,
		args_unique = list(incomparables = FALSE)
	)
	expected <- list(
		choices = sort(unique(choices_chr_with_na, incomparables = FALSE))
	)
	expect_identical(result, expected)
})

# server argument handling ####
test_that("args_update_filter_input() ignores server = TRUE for character", {
	result <- args_update_filter_input(choices_chr_with_na, server = TRUE)
	expected <- list(choices = unique(sort(choices_chr_with_na)))
	expect_identical(result, expected)
})

test_that("args_update_filter_input() ignores server = TRUE for factor", {
	result <- args_update_filter_input(choices_fct_with_na, server = TRUE)
	expected <- list(choices = unique(sort(choices_fct_with_na)))
	expect_identical(result, expected)
})

test_that("args_update_filter_input() ignores server = TRUE for logical", {
	result <- args_update_filter_input(choices_log_with_na, server = TRUE)
	expected <- list(choices = unique(sort(choices_log_with_na)))
	expect_identical(result, expected)
})

test_that("args_update_filter_input() ignores server = TRUE for list", {
	result <- args_update_filter_input(choices_lst_with_na, server = TRUE)
	expected <- list(choices = choices_lst_with_na)
	expect_identical(result, expected)
})

test_that("args_update_filter_input() ignores server = FALSE for character", {
	result <- args_update_filter_input(choices_chr_with_na, server = FALSE)
	expected <- list(choices = unique(sort(choices_chr_with_na)))
	expect_identical(result, expected)
})

# Custom methods with different arg names ####
test_that("args_update_filter_input() removes value arguments when present", {
	# Test with textarea which returns NULL from args_filter_input
	method(args_filter_input, ClassCharacter) <- function(x, ...) {
		list(selected = "a")
	}
	result <- args_update_filter_input(ClassCharacter(letters))
	expect_null(result)
})

test_that("args_update_filter_input() removes value arguments when present (text)", {
	# Test with text which returns NULL from args_filter_input
	result <- args_update_filter_input(use_text(choices_chr_with_na))
	expect_null(result)
})
