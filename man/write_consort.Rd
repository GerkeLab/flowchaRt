% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/output.R
\name{write_consort}
\alias{write_consort}
\title{Write CONSORT Diagram}
\usage{
write_consort(study_data, path, ..., density = 72)
}
\arguments{
\item{study_data}{Study data data frame (see \link{study_data} for information)}

\item{path}{<chr> File name for drawing output}

\item{density}{resolution to render raster image output via
\link[magick:image_write]{magick::image_write}}
}
\description{
Write CONSORT Diagram
}
\references{
\url{http://www.consort-statement.org/},
\url{http://www.consort-statement.org/consort-statement/flow-diagram}
}
