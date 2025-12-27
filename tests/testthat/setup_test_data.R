# Setup ####
letters_shuffled <- sample(letters)
choices_fct <- as.factor(letters_shuffled)
choices_fct_with_na <- choices_fct
choices_fct_with_na[
	sample.int(length(choices_fct), sample.int((length(choices_fct) - 1), 1))
] <- NA

choices_lst <- as.list(letters_shuffled)
choices_lst_with_na <- choices_lst
choices_lst_with_na[
	sample.int(length(choices_lst), sample.int((length(choices_lst) - 1), 1))
] <- NA

choices_chr <- letters_shuffled
choices_chr_with_na <- choices_chr
choices_chr_with_na[
	sample.int(length(choices_chr), sample.int((length(choices_chr) - 1), 1))
] <- NA

choices_log <- c(TRUE, FALSE)
choices_log_with_na <- choices_log
choices_log_with_na[sample.int(2, 1)] <- NA

choices_num <- 1:10
choices_num_with_na <- choices_num
choices_num_with_na[
	sample.int(length(choices_num), sample.int((length(choices_num) - 1), 1))
] <- NA

choices_dte <- sample(Sys.Date() + 0:9)
choices_dte_with_na <- choices_dte
choices_dte_with_na[
	sample.int(length(choices_dte), sample.int((length(choices_dte) - 1), 1))
] <- NA

choices_psc <- sample(Sys.time() + as.difftime(0:9, units = "days"))
choices_psc_with_na <- choices_psc
choices_psc_with_na[
	sample.int(length(choices_psc), sample.int((length(choices_psc) - 1), 1))
] <- NA

choices_psl <- sample(as.POSIXlt(Sys.time() + as.difftime(0:9, units = "days")))
choices_psl_with_na <- choices_psl
choices_psl_with_na[
	sample.int(length(choices_psl), sample.int((length(choices_psl) - 1), 1))
] <- NA

choices_chr_na <- rep(NA_character_, 10)
choices_cpx_na <- rep(NA_complex_, 10)
choices_rel_na <- rep(NA_real_, 10)
choices_int_na <- rep(NA_integer_, 10)

# Create test lists for unique.default testing
test_lst_with_duplicates <- list(a = 1, b = 2, c = 1, d = 3, e = 2)
test_lst_with_na <- list(a = 1, b = NA, c = 1, d = 3, e = NA)
