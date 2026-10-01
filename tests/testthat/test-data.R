test_that("nyc_flights gets an input for every column", {
	expect_snapshot(shinyfilters(nyc_flights), variant = snapshot_variant())
})
