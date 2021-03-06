% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/str_pad2.R
\name{str_pad2}
\alias{str_pad2}
\title{Pad a string.}
\usage{
str_pad2(string, width, side = c("left", "right", "both"), pad = " ")
}
\arguments{
\item{string}{A character vector.}

\item{width}{Minimum width of padded strings.}

\item{side}{Side on which padding character is added (left, right or both).}

\item{pad}{Single padding character (default is a space).}
}
\value{
A character vector.
}
\description{
Forked from \code{sen2r::str_pad2()}.
Vectorised over \code{string}, \code{width} and \code{pad}.
This is an internal function doing the same thing of \link[stringr:str_pad]{stringr::str_pad}
(except for parameters \code{'width'} and \code{'length'} which must be of length 1),
but without depending on package \code{stringi}.
}
\note{
License: GPL 3.0
}
\references{
L. Ranghetti, M. Boschetti, F. Nutini, L. Busetto (2020).
"sen2r": An R toolbox for automatically downloading and preprocessing
Sentinel-2 satellite data. \emph{Computers & Geosciences}, 139, 104473. DOI:
\url{https://doi.org/10.1016/j.cageo.2020.104473},
URL: \url{http://sen2r.ranghetti.info/}.
}
\author{
Luigi Ranghetti, phD (2019) \email{luigi@ranghetti.info}
}
