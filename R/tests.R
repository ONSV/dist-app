library(tidyverse)
library(sf)

df <- st_read("R/ndsbr_data.gpkg")

linestringer <- function(data) {
  res <- bind_cols(data, st_coordinates(data)) |> 
    drop_na(geom, X, Y) |>
    arrange(DRIVER, ID, TIME_ACUM) |> 
    mutate(
      geometry = if_else(
        ID == lag(ID) & (TIME_ACUM - lag(TIME_ACUM)) == 1,
        paste0("LINESTRING (", lag(X), " ", lag(Y), ", ", X, " ", Y,")"),
        NA, missing = NA
      )
    ) |>
    drop_na(geometry) |> 
    select(-c(X, Y))
  
  res$geometry <- st_as_sfc(res$geometry, crs = 4674)
  
  return(res)
}

test <- linestringer(df)
test |> view()
test$geometry |> class()
test$geometry |> plot()