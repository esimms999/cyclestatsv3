# Mutable environment for app-wide data populated by cyclestats_init().
# Using an environment avoids <<- assignments to the global env.
.cyclestats_data <- new.env(parent = emptyenv())

# Suppress R CMD check notes for bare column names used in dplyr pipelines.
utils::globalVariables(c(
  "activity_type", "activity_id", "activity_datetime", "activity_name",
  "activity_distance", "activity_moving_time", "activity_date",
  "activity_month", "activity_avg_speed",
  "activity_year", "activity_year_month",
  "ride_count", "total_distance", "total_rides"
))

#' Prepare data for use within the app
#'
#' Loads the pre-downloaded Ride with GPS activities (.rds) and builds
#' the objects used by the UI and server.
#'
#' @export
cyclestats_init <- function() {
  # Load the pre-processed Ride with GPS data
  .cyclestats_data$activities <- readRDS(app_sys("extdata/activities.rds"))

  # Years available for the filter widget
  .cyclestats_data$available_years <- as.list(unique(.cyclestats_data$activities$activity_year))

  # Template of every year-month with zero values so months with no rides
  # still appear on the chart.
  activity_year <- c()
  activity_year_month <- c()
  for (year in .cyclestats_data$available_years) {
    for (month in 1:12) {
      year_month <- paste(year, formatC(month, width = 2, flag = "0"), sep = "-")
      activity_year_month <- c(activity_year_month, year_month)
      activity_year <- c(activity_year, year)
    }
  }

  .cyclestats_data$activity_year_month_zero <- data.frame(
    activity_year = activity_year,
    activity_year_month = activity_year_month
  ) |>
    dplyr::arrange(activity_year_month)
}
