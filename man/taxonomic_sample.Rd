% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/taxonomic_sample.R
\name{taxonomic_sample}
\alias{taxonomic_sample}
\title{Recursivly sample a set of taxonomic assignments}
\usage{
taxonomic_sample(taxmap_data, max_counts = c(), min_counts = c(),
  max_children = c(), min_children = c(), obs_filters = list(),
  subtaxa_filters = list(), stop_conditions = list(), ...)
}
\arguments{
\item{taxmap_data}{(An object of type \link{taxmap})}

\item{max_counts}{(\code{numeric}) A named vector that defines that maximum number of
observations in for each level specified. The names of the vector specifies that level each number
applies to. If more than the maximum number of observations exist for a given taxon, it is randomly
subsampled to this number.}

\item{min_counts}{(\code{numeric}) A named vector that defines that minimum number of
observations in for each level specified. The names of the vector specifies that level each number
applies to.}

\item{max_children}{(\code{numeric}) A named vector that defines that maximum number of
subtaxa per taxon for each level specified. The names of the vector specifies that level each
number applies to. If more than the maximum number of subtaxa exist for a given taxon, they
are randomly subsampled to this number of subtaxa.}

\item{min_children}{(\code{numeric}) A named vector that defines that minimum number of
subtaxa in for each level specified. The names of the vector specifies that level each number
applies to.}

\item{obs_filters}{(\code{list} of \code{function(observations, id)}) A list of functions that take a data
structure containing the information of multiple observations and a taxon id.
Returns a object of the same type with some of the observations potentially removed.}

\item{subtaxa_filters}{(\code{list} of \code{function(observations, id)}) A list of functions that take a data
structure containing the information of multiple subtaxa IDs and the current taxon id.
Returns a object of the same type with some of the subtaxa potentially removed. If a function returns
\code{NULL}, then no observations for the current taxon are returned.}

\item{stop_conditions}{(\code{list} of \code{function(id)}) A list of functions that take the
current taxon id. If any of the functions return \code{TRUE}, the observations for the current taxon are 
returned rather than looking for observations of subtaxa, stopping the recursion.}

\item{...}{Additional parameters are passed to all of the function options.}
}
\value{
Returns an object of type \code{taxmap}
}
\description{
Recursivly sample a set of observations with taxonomic assignments and an associated taxonomy.
}
\examples{

\dontrun{
#Plot data before subsampling
heat_tree(unite_ex_data_3,
          node_size = n_obs,
          node_color = n_obs,
          node_label = n_obs)
     
# Subsampling
subsampled <- taxonomic_sample(unite_ex_data_3,
                               max_counts = c("4" = 20, "7" = 5),
                               min_counts = c("7" = 3))
     
# Remove unobserved taxa and plot
heat_tree(subset(subsampled, n_obs > 0, unobserved = FALSE),
          node_size = n_obs,
          node_color = n_obs,
          node_label = n_obs)
}

}

