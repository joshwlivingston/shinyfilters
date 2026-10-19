# testthat < 3.2.0 shows conditions in snapshots the way current testthat
# does only for packages whose rlang dependency has a version. The package's
# own DESCRIPTION leaves rlang unversioned, so CI versions it here.

desc <- readLines("DESCRIPTION")
i <- grep("^[[:space:]]+rlang,$", desc)
if (length(i) != 1) {
  stop("Can't find the rlang dependency in DESCRIPTION")
}
desc[i] <- sub("rlang,", "rlang (>= 1.0.0),", desc[i], fixed = TRUE)
writeLines(desc, "DESCRIPTION")
