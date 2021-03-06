#' @title Make `sf` from filtered data
#' @description TODO
#' @param indata TODO
#' @param outcrs `CRS` output CRS
#' @param all logical (TRUE for all points, FALSE for only filtered ones)
#' @param sid character: name of the ID field to be used (`"uid"`, `"sid1"`, `"sid2"`, `"sid3"` or `"sid4"`)
#' @importFrom sf st_as_sf st_crs st_transform
#' @import data.table
#' @author Luigi Ranghetti, phD (2019) \email{ranghetti.l@@irea.cnr.it}
#' @note License: GPL 3.0

inputpts_to_sf <- function(indata, outcrs = 3857, all = FALSE, sid = "sid3") {
  # to avoid NOTE on check
  uid <- idfield <- selvar <- lon <- lat <- NULL
  if (!is(outcrs,"crs")) {
    outcrs <- st_crs2(outcrs)
  }
  indata_sf <- st_as_sf(
    indata[if (!all) {filter==FALSE} else {TRUE}, list(uid,sid=get(sid),idfield,selvar,lon,lat)],
    coords = c("lon","lat"),
    crs = 4326
  )
  indata_sf$sid <- rank(indata_sf$sid)
  if (outcrs != st_crs(indata_sf)) {
    indata_sf <- st_transform(indata_sf,outcrs)
  }
  return(indata_sf)
}
