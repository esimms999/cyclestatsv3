# download_rwgps_data.R
# Run this script whenever you want to refresh your cycling data from Ride with GPS.
# It produces a ready-to-use activities.rds file.

library(httr2)
library(dplyr)
library(purrr)
library(lubridate)
library(stringr)

# ---------- credentials ----------
# Set RWGPS_API_KEY and RWGPS_AUTH_TOKEN in a project-level .Renviron file
# (run usethis::edit_r_environ("project"), then restart R). .Renviron is
# gitignored and must never be committed.
api_key <- Sys.getenv("RWGPS_API_KEY")
auth_token <- Sys.getenv("RWGPS_AUTH_TOKEN")

if (api_key == "" || auth_token == "") {
  stop(
    "RWGPS_API_KEY and/or RWGPS_AUTH_TOKEN are not set.\n",
    "Run usethis::edit_r_environ(\"project\") to add them to a local, ",
    "gitignored .Renviron file, then restart R."
  )
}

# ---------- fetch all trips (robust automatic pagination) ----------
fetch_all_trips <- function(api_key, auth_token, page_size = 100) {
  all_trips <- list()
  page <- 1

  repeat {
    message("Fetching page ", page, " ...")

    resp <- request("https://ridewithgps.com/api/v1/trips.json") |>
      req_headers(
        "x-rwgps-api-key" = api_key,
        "x-rwgps-auth-token" = auth_token,
        "Accept" = "application/json"
      ) |>
      req_url_query(page = page, page_size = page_size) |>
      req_perform()

    body <- resp_body_json(resp)
    trips <- body$trips

    if (length(trips) == 0L) {
      message("Empty page – stopping.")
      break
    }

    all_trips <- c(all_trips, trips)
    meta <- body$meta$pagination

    message(
      "  Got ", length(trips), " trips | collected so far: ", length(all_trips),
      " / ", meta$record_count
    )

    # Reliable stop conditions
    if (is.null(meta$next_page_url) || page >= meta$page_count) {
      break
    }

    page <- page + 1
    Sys.sleep(0.3) # polite pause
  }

  message("Finished. Total trips retrieved: ", length(all_trips))
  all_trips
}

# ---------- transform into the exact structure the app expects ----------
process_trips <- function(trips) {
  get <- function(x, field, default = NA) {
    val <- x[[field]]
    if (is.null(val)) default else val
  }

  map_dfr(trips, function(t) {
    tibble(
      id            = get(t, "id"),
      name          = get(t, "name", ""),
      departed_at   = get(t, "departed_at"),
      distance_m    = get(t, "distance", 0),
      moving_time_s = get(t, "moving_time", NA_real_),
      avg_speed_kmh = get(t, "avg_speed", NA_real_),
      activity_type = get(t, "activity_type", "")
    )
  }) |>
    filter(
      str_starts(activity_type, "cycling") | activity_type == "unknown:generic"
    ) |>
    mutate(
      activity_id = as.character(id),
      activity_name = name,
      activity_datetime = departed_at,
      activity_date = as_date(ymd_hms(departed_at, quiet = TRUE)),
      activity_year = format(activity_date, "%Y"),
      activity_month = format(activity_date, "%m"),
      activity_year_month = format(activity_date, "%Y-%m"),
      activity_distance = round(distance_m / 1609.344, 2), # meters → miles
      activity_avg_speed = if_else(
        is.na(avg_speed_kmh) | avg_speed_kmh == 0,
        round(activity_distance / (moving_time_s / 3600), 2),
        round(avg_speed_kmh * 0.621371, 2) # km/h → mph
      )
    ) |>
    select(
      activity_id, activity_name, activity_datetime, activity_date,
      activity_year, activity_month, activity_year_month,
      activity_distance, activity_avg_speed
    ) |>
    arrange(activity_date) |>
    filter(!is.na(activity_date))
}

# ---------- main execution ----------
message("Starting Ride with GPS download...")
trips_raw <- fetch_all_trips(api_key, auth_token)
activities <- process_trips(trips_raw)

# Write the .rds file (this is what the package will use)
saveRDS(activities, "inst/extdata/activities.rds")
message("Wrote inst/extdata/activities.rds with ", nrow(activities), " cycling rides.")
message("Date range: ", min(activities$activity_date), " to ", max(activities$activity_date))
