% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plot_alignment.R
\name{plot_alignment}
\alias{plot_alignment}
\title{Display sequence alignment}
\usage{
plot_alignment(alignment)
}
\arguments{
\item{alignment}{(\code{DNAbin}) A matrix representing a sequence alignment.}
}
\value{
A \code{\link[ggplot2]{ggplot}} object
}
\description{
Make a plot af a sequence alignment for an overview of alignment structure.
}
\examples{
\dontrun{
library(ape)
data(woodmouse)
plot_alignment(woodmouse)}

}
\references{
ColorBrewer2 was used for the color palette
}
\keyword{internal}

