# data-raw

Scripts here are **not** run automatically by the package, app build,
`pkgload::load_all()`, or Build -> Install. Anything in `data-raw/` is
excluded from the package (see `.Rbuildignore`).

## get_data.R

Downloads cycling activity data from the Ride with GPS API and writes
`activities.rds`.

Run manually, only when you want to refresh the data:

    source("data-raw/get_data.R")

After running, copy the resulting `activities.rds` into
`inst/extdata/activities.rds` so the app picks up the refreshed data.
