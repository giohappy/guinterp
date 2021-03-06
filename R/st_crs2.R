#' @title Retrieve coordinate reference system from `sf` or `sfc` object
#' @name st_crs2
#' @description This function, forked from `sen2r::st_crs2()`,
#'  is a wrapper for `sf::st_crs()`, unless
#'  treating numeric `character` strings as integers, and
#'  accepting also UTM time zones, paths of spatial files and paths of
#'  text files containing WKT like `.prj` (see details) .
#' @param x numeric, character, or object of class `sf` or `sfc`, being:
#'  - EPSG code: numeric (e.g. `32632`) or character (in the form
#'      `"32632"` or `"EPSG:32632"`);
#'  - UTM zone: numeric (e.g. `32`, interpreted as 32 North) or character
#'      (e.g. `"32"` or `"32N"` for zone 32 North, `"32S"` for 32 South);
#'  - WKT test: passed as character string or as path of a text file
#'      containing it (e.g. the path of a `.prj` file);
#'  - PROJ.4 string, passed as character (e.g.
#'      `"+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs"`
#'      (**NOTE**: this representation is deprecated with PROJ >= 6
#'      -- see \url{http://rgdal.r-forge.r-project.org/articles/PROJ6_GDAL3.html} --
#'      so a warning is returned using it, unless the string contains only
#'      the EPSG code -- e.g. `"+init=epsg:32632"`, in which case the EPSG
#'      code is taken);
#'  - path of a spatial file (managed by `sf::st_read()` or `stars::read_stars()`),
#'      passed as character string of length 1;
#'  - spatial file of class `sf` or `sfc`.
#' @param ... other parameters passed to `sf::st_crs()`.
#' @return An object of class `crs` of length 2.
#' @details See `sf::st_crs()` for details.
#' @importFrom sf gdal_crs st_crs
#' @author Luigi Ranghetti, phD (2019) \email{luigi@@ranghetti.info}
#' @references L. Ranghetti, M. Boschetti, F. Nutini, L. Busetto (2020).
#'  "sen2r": An R toolbox for automatically downloading and preprocessing
#'  Sentinel-2 satellite data. _Computers & Geosciences_, 139, 104473. DOI:
#'  \url{https://doi.org/10.1016/j.cageo.2020.104473},
#'  URL: \url{http://sen2r.ranghetti.info/}.
#' @note License: GPL 3.0


st_crs2 <- function(x, ...) {

  ## integer or numeric (EPGS / UTM zone): treat as character
  if (inherits(x, c("integer", "numeric"))) {
    x <- as.character(x)
  }

  ## character: several cases (see)
  if (inherits(x, "character")) {

    ## case 1: EPSG code / UTM zone
    x_epsg <- if (grepl("^(([0-5]?[0-9])|60)[Nn]?$", x)) {
      # x: UTM zone North -> integer EPSG
      as.integer(paste0(
        "326",
        str_pad2(
          gsub("^(([0-5]?[0-9])|60)[Nn]?$", "\\1", x),
          2, "left", "0"
        )
      ))
    } else if (grepl("^(([0-5]?[0-9])|60)[Ss]$", x)) {
      # x: UTM zone South -> integer EPSG
      as.integer(paste0(
        "327",
        str_pad2(
          gsub("^(([0-5]?[0-9])|60)[Ss]$", "\\1", x),
          2, "left", "0"
        )
      ))
    } else if (grepl("^[0-9]+$", x)) {
      # x: EPSG (integer, numeric or character) -> integer EPSG
      as.integer(x)
    } else if (grepl("^[Ee][Pp][Ss][Gg]\\:[0-9]+$", x)) {
      # x: EPSG (in the form "EPSG:xxx") -> integer EPSG
      as.integer(gsub("^[Ee][Pp][Ss][Gg]\\:([0-9]+)$", "\\1", x))
    } else if (grepl("^\\+init\\=epsg:[0-9]+$", tolower(x))) {
      # x: PROJ.4 with only EPSG -> integer EPSG
      as.integer(gsub("^\\+init\\=epsg:([0-9]+)$", "\\1", tolower(x)))
    } else {
      NULL
    }
    if (!is.null(x_epsg)) {
      return(sf::st_crs(x_epsg, ...))
    }

    ## case 2: PROJ.4
    if (grepl("^\\+[a-z]+\\=", x)) {
      # x: PROJ.4 -> character PROJ.4 with warning
      warning(paste0(
        "Using PROJ.4 strings is deprecated with PROJ >= 6 ",
        "(see https://www.r-spatial.org/r/2020/03/17/wkt.html)."
      ))
      return(sf::st_crs(x, ...))
    }

    ## case 3: file path
    if (file.exists(as.character(x))) {
      # x: file path -> spatial file or WKT
      x2 <- tryCatch(
        # x: path of a vector file -> sf
        st_read(x, quiet = TRUE),
        warning = function(w) {
          if (grepl("no simple feature geometries present\\: returning a data\\.frame", w)) {
            # x: path of a tabular file -> x (st_crs will return the proper error)
            x
          } else {st_read(x, quiet = TRUE)}
        },
        error = function(e) {tryCatch(
          # x: path of a text file with WKT -> crs
          suppressWarnings(sf::st_crs(readLines(x))),
          error = function(e) {tryCatch(
            # x: path of a raster file -> stars proxy
            gdal_crs(x),
            error = function(e) {
              # x: path of a non supported file -> x (st_crs will return the proper error)
              x
            }
          )}
        )}
      )
      return(sf::st_crs(x2, ...))
    }

    ## case 4: WKT and other characters
    if (grepl("^((PROJCR?S)|(GEOGCR?S))\\[.+\\]$", x)) {
      # x: WKT string -> crs
      return(sf::st_crs(x, ...))
    }

    ## any other case: pass to st_crs as is
    sf::st_crs(x, ...)

  } else {

    ## classes already managed by st_crs()
    if (missing(x)) {sf::st_crs(NA)} else {sf::st_crs(x, ...)}

  }

}
