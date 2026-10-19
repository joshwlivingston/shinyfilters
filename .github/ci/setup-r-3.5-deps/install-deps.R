# Installs the packages in DESCRIPTION's FIELDS, plus EXTRA_PACKAGES, from
# the Posit Package Manager SNAPSHOT, and checks that S7 is 0.1.0.

split <- function(x) trimws(strsplit(x, ",")[[1]])

options(
  repos = c(
    CRAN = paste0("https://packagemanager.posit.co/cran/", Sys.getenv("SNAPSHOT"))
  ),
  Ncpus = 4
)

fields <- read.dcf("DESCRIPTION", split(Sys.getenv("FIELDS")))
pkgs <- split(paste(fields[!is.na(fields)], collapse = ","))
pkgs <- sub("[ (].*", "", pkgs)
pkgs <- setdiff(pkgs, c("", rownames(installed.packages(priority = "base"))))
pkgs <- c(pkgs, split(Sys.getenv("EXTRA_PACKAGES")))

needed <- setdiff(pkgs, rownames(installed.packages()))
if (length(needed) > 0) {
  install.packages(needed)
}
missing <- setdiff(pkgs, rownames(installed.packages()))
if (length(missing) > 0) {
  stop("Failed to install: ", paste(missing, collapse = ", "))
}

if (packageVersion("S7") != "0.1.0") {
  stop("Expected S7 0.1.0, got ", packageVersion("S7"))
}
sessionInfo()
