test_that("as_filters() applies `ns` to input ids", {
	res <- filterInput(as_filters(data.frame(a = letters), ns = shiny::NS("m")))
	expect_match(as.character(res), 'id="m-a"', fixed = TRUE)
})

test_that("as_filters(): `ns` must be result of shiny::NS()", {
	expect_snapshot(error = TRUE, {
		as_filters(data.frame(a = letters), ns = function(x) x)
	})
})
