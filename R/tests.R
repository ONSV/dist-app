library(tidyverse)
library(sf)

df <- st_read("R/ndsbr_data.gpkg")

linestringer <- function(data) {
  res <- bind_cols(data, st_coordinates(data)) |> 
    st_drop_geometry() |> 
    drop_na(X, Y) |> 
    arrange(DRIVER, ID, TIME_ACUM) |> 
    mutate(
      lagX = lag(X),
      lagY = lag(Y),
      geom = if_else(
        ID == lag(ID) & (TIME_ACUM - lag(TIME_ACUM)) == 1,
        paste0("LINESTRING (", X, " ", Y, ", ", lagX, " ", lagY, ")"),
        NA, missing = NA
      )
    ) |> 
    select(-c(lagX, lagY)) |> 
    drop_na(geom) |> 
    st_as_sf(wkt = "geom", crs = 4674)
  
  return(res)
}

calc_dist <- function(sf) {
  res <- sf |> 
    mutate(DIST = as.numeric(st_length(geom)))
  
  return(res)
}

sf_to_csv <- function(sf) {
  res <- st_drop_geometry(sf)
  
  return(res)
}

# linestringer <- function(data) {
#   res <- bind_cols(data, st_coordinates(data)) |> 
#     drop_na(geom, X, Y) |>
#     arrange(DRIVER, ID, TIME_ACUM) |> 
#     mutate(
#       geometry = if_else(
#         ID == lag(ID) & (TIME_ACUM - lag(TIME_ACUM)) == 1,
#         paste0("LINESTRING (", lag(X), " ", lag(Y), ", ", X, " ", Y,")"),
#         NA, missing = NA
#       )
#     ) |>
#     drop_na(geometry) |> 
#     select(-c(X, Y))
#   
#   res$geometry <- st_as_sfc(res$geometry, crs = 4674)
#   
#   res <- st_drop_geometry(res)
#   
#   return(res)
# }

test <- linestringer(df)

test_dist <- calc_dist(test)

csv <- sf_to_csv(test_dist)