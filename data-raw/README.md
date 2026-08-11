# data-raw

Scripts here are **not** run automatically by the package, app build,
`pkgload::load_all()`, or Build -> Install. Anything in `data-raw/` is
excluded from the package (see `.Rbuildignore`).

## get_data.R

Downloads cycling activity data from the Ride with GPS API and writes
`activities.rds` directly to `inst/extdata/activities.rds`, which is
what the app reads at runtime.

Run manually, only when you want to refresh the data:

    source("data-raw/get_data.R")

No copying is required — the script writes straight to
`inst/extdata/activities.rds`, overwriting the existing file.
