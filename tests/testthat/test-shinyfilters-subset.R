test_that("`[` returns a config with the selected columns", {
	cfg <- with_filters(shinyfilters(df_config, slider = TRUE), x = "radio")
	sub <- cfg[c("x", "letters")]
	expect_identical(names(sub), c("x", "letters"))
	expect_identical(filterInput(sub)[[1]], filterInput(cfg)[[3]])
	expect_identical(filterInput(sub)[[2]], filterInput(cfg)[[1]])
	expect_identical(names(cfg[3:4]), c("x", "a_very_very_long_name"))
	expect_identical(cfg[], cfg)
	expect_identical(names(cfg[-1]), names(df_config)[-1])
	expect_identical(names(cfg[c("x", "x")]), "x")
	expect_identical(names(cfg[c(x, letters)]), c("x", "letters"))
	cols <- c("factors", "x")
	x <- "letters"
	expect_identical(names(cfg[x]), "x")
	expect_snapshot(
		print(cfg[c("letters", "x")])
	)
})

test_that("`[` errors on unknown columns", {
	cfg <- shinyfilters(df_config)
	expect_snapshot(error = TRUE, {
		cfg["nope"]
		cfg[9]
		cfg[TRUE]
		cfg[0]
		cfg[character(0)]
		cfg[, "x"]
		cfg[1, 2]
		cfg[[1, 2]]
		cfg[factros]
		cfg[t]
	})
})

test_that("`[` errors on a malformed `any_of()`", {
	cfg <- shinyfilters(df_config)
	expect_snapshot(error = TRUE, {
		cfg[tidyselect::any_of()]
		cfg[tidyselect::any_of("x", "letters")]
		cfg[tidyselect::any_of(TRUE)]
	})
})

test_that("`[[` returns the inputs of the selected columns", {
	cfg <- with_filters(shinyfilters(df_config, ns = shiny::NS("m")), x = "radio")
	res <- filterInput(cfg)
	expect_identical(cfg[["letters"]], res[[1]])
	expect_identical(cfg[[4]], res[[4]])
	expect_identical(
		cfg[[c("letters", "x")]],
		filterInput(cfg[c("letters", "x")])
	)
})

test_that("`[[` errors on unknown columns", {
	cfg <- shinyfilters(df_config)
	expect_snapshot(error = TRUE, {
		cfg[["nope"]]
		cfg[[9]]
		cfg[[c("x", "nope")]]
	})
})

test_that("double bracket with no arguments supplied returns the object", {
	cfg <- shinyfilters(df_config)
	expect_identical(cfg[[]], cfg)
})
