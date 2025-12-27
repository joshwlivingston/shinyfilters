# defaults ####
## list ####
test_that("args_filter_input() returns provided list as choices argument", {
	expect_identical(
		args_filter_input(choices_lst_with_na),
		list(choices = choices_lst_with_na)
	)
})

## factor, logical ####
test_that("args_filter_input() (factor, logical) returns sorted, unique values as choices argument", {
	expect_identical(
		args_filter_input(choices_fct_with_na),
		list(choices = unique(sort(choices_fct_with_na)))
	)
	expect_identical(
		args_filter_input(choices_log_with_na),
		list(choices = unique(sort(choices_log_with_na)))
	)
})


## character ####
test_that("args_filter_input() default returns sorted, unique values as choices argument", {
	expect_identical(
		args_filter_input(choices_chr_with_na),
		list(choices = unique(sort(choices_chr_with_na)))
	)
})

test_that("args_filter_input() (character) with textbox = FALSE returns sorted, unique values as choices argument", {
	expect_identical(
		args_filter_input(choices_chr_with_na, textbox = FALSE),
		list(choices = unique(sort(choices_chr_with_na)))
	)
})

test_that("args_filter_input() with textbox = TRUE returns NULL for character vectors", {
	expect_null(
		args_filter_input(choices_chr_with_na, textbox = TRUE)
	)
})

## numeric ####
test_that("args_filter_input() returns min, max, and max for numeric vectors", {
	expect_identical(
		args_filter_input(choices_num_with_na),
		list(
			min = min(choices_num_with_na, na.rm = TRUE),
			max = max(choices_num_with_na, na.rm = TRUE),
			value = max(choices_num_with_na, na.rm = TRUE)
		)
	)
})

## Date ####
test_that("args_filter_input() returns min, max, max for Date vectors", {
	expect_identical(
		args_filter_input(choices_dte_with_na),
		list(
			min = min(choices_dte_with_na, na.rm = TRUE),
			max = max(choices_dte_with_na, na.rm = TRUE),
			value = max(choices_dte_with_na, na.rm = TRUE)
		)
	)
})

## POSIXt ####
### POSIXct ####
test_that("args_filter_input() returns min and max Dates for POSIXct vectors", {
	expect_identical(
		args_filter_input(choices_psc_with_na),
		list(
			min = min(as.Date(choices_psc_with_na), na.rm = TRUE),
			max = max(as.Date(choices_psc_with_na), na.rm = TRUE),
			value = max(as.Date(choices_psc_with_na), na.rm = TRUE)
		)
	)
})

### POSIXlt ####
test_that("args_filter_input() returns min and max Dates for POSIXlt vectors", {
	expect_identical(
		args_filter_input(choices_psl_with_na),
		list(
			min = min(as.Date(choices_psl_with_na), na.rm = TRUE),
			max = max(as.Date(choices_psl_with_na), na.rm = TRUE),
			value = max(as.Date(choices_psl_with_na), na.rm = TRUE)
		)
	)
})
