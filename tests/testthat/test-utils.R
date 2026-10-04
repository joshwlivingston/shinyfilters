test_that("._s3_register() registers a method for a loaded package's generic", {
	x <- structure(1, class = "shinyfilters_test")
	res <- with_s3_register(
		"utils::head",
		"shinyfilters_test",
		function(x, ...) "registered",
		utils::head(x)
	)
	expect_identical(res, "registered")
})

test_that("._s3_register() waits for a package that isn't loaded", {
	event <- packageEvent("shinyfiltersNotAPackage", "onLoad")
	hooks <- with_s3_register(
		"shinyfiltersNotAPackage::generic",
		"shinyfilters_test",
		function(x, ...) "registered",
		getHook(event)
	)
	expect_length(hooks, 1)
})

test_that("._s3_register()'s load hook registers the method", {
	x <- structure(1, class = "shinyfilters_test")
	event <- packageEvent("utils", "onLoad")
	res <- with_s3_register(
		"utils::head",
		"shinyfilters_test",
		function(x, ...) "registered",
		{
			s3_unregister("utils::head", "shinyfilters_test")
			before <- unclass(utils::head(x))
			hooks <- getHook(event)
			hooks[[length(hooks)]]()
			list(before = before, after = utils::head(x))
		}
	)
	expect_identical(res$before, 1)
	expect_identical(res$after, "registered")
})
