test_that("nyc_flights gets an input for every column", {
	expect_snapshot(as_filters(nyc_flights))
})
