#' Retrieve classifications from observation IDs
#' 
#' Retrieve taxonomic classifications from observation (e.g. sequence) IDs using a specified database.
#' 
#' @param obs_id (\code{character})
#' An unique observation (e.g. sequence) identifier for a particular \code{database}.
#' Requires an internet connection. 
#' @param database (\code{character} of length 1)
#' The name of the database that patterns given in  \code{parser} will apply to.
#' Valid databases include "ncbi", "itis", "eol", "col", "tropicos",
#' "nbn", and "none". \code{"none"} will cause no database to be quired; use this if you want to not use the
#' internet. NOTE: Only \code{"ncbi"} has been tested so far.
#' @param ... Not used
#' 
#' @return \code{list} of \code{data.frame}
#' 
#' @keywords internal
class_from_obs_id <- function(obs_id, database = c("ncbi", "none"), ...) {
  
  using_ncbi <- function(obs_id) {
    taxize::classification(taxize::genbank2uid(obs_id))
  }
  
  using_none <- function(obs_id) {
    rep(NA, length(obs_id))
  }
  
  # Look up classifications
  database <- match.arg(database)
  result <- suppressWarnings(map_unique(obs_id, get(paste0("using_", database))))
  # Check for errors
  error_indexes <- is.na(result)
  if (sum(error_indexes) > 0) {
    invalid_list <- paste("   ", which(error_indexes), ": ", obs_id[error_indexes], "\n")
    if (length(invalid_list) > 10) { invalid_list <- c(invalid_list[1:10], "    ...") }
    vigilant_report(paste0(collapse = "",
                           c("The queries to '", database, "' for the following ", sum(error_indexes),
                             " of ", length(obs_id), " observation IDs failed to return classifications:\n",
                             invalid_list,
                             "NOTE: The function that get classifications from IDs works in batches. ",
                             "If any of the IDs in a batch is invalid, the whole batch fails. ",
                             "Therefore, not all the IDs listed are necessarily invalid.")))
  }
  # Format result
  result[!error_indexes] <- lapply(result[!error_indexes],
                                   function(x) stats::setNames(x, c("name", "rank", paste0(database, "_id"))))
  return(result)
}


#' Parse embedded classifications
#' 
#' Parse embedded classifications, optionally checking the results via a database.
#' 
#' @param class (\code{character})
#' The unparsed class information.
#' @param class_key (\code{character} of length 1)
#' The identity of the capturing groups defined using \code{class_iregex}.
#' The length of \code{class_key} must be equal to the number of capturing groups specified in \code{class_regex}.
#' Any names added to the terms will be used as column names in the output.
#' At least \code{"taxon_id"} or \code{"name"} must be specified.
#' Only \code{"taxon_info"} can be used multiple times.
#' Each term must be one of those decribed below:
#'  \describe{
#'    \item{\code{taxon_id}}{A unique numeric id for a taxon for a particular \code{database} (e.g. ncbi accession number).
#'          Requires an internet connection.}
#'    \item{\code{name}}{The name of a taxon. Not necessarily unique, but are interpretable
#'          by a particular \code{database}. Requires an internet connection.}
#'    \item{\code{taxon_info}}{Arbitrary taxon info you want included in the output. Can be used more than once.}
#'  }
#' @param class_regex (\code{character} of length 1)
#' A regular expression with capturing groups indicating the locations of data for each taxon in the \code{class} term in the \code{key} argument.
#' The identity of the information must be specified using the \code{class_key} argument.
#' @param class_sep (\code{character} of length 1)
#' Used with the \code{class} term in the \code{key} argument.
#' The character(s) used to separate individual taxa within a classification.
#' @param class_rev (\code{logical} of length 1)
#' Used with the \code{class} term in the \code{key} argument.
#' If \code{TRUE}, the order of taxon data in a classfication is reversed to be specific to broad.
#' @param database (\code{character} of length 1) The name of the database that patterns given in 
#'  \code{parser} will apply to. Valid databases include "ncbi", "itis", "eol", "col", "tropicos",
#'  "nbn", and "none". \code{"none"} will cause no database to be quired; use this if you want to not use the
#'  internet. NOTE: Only \code{"ncbi"} has been tested so far.
#' @param ... Not used
#' 
#' @return \code{list} of \code{data.frame}
#' 
#' @keywords internal
class_from_class <- function(class, class_key, class_regex, class_sep, class_rev, database, ...) {
  # Check input
  if (all(class == "")) {
    stop("All classifications are empty strings. Check that the regex supplied matches the entire classification.")
  }
  
  # Extract each capture group 
  if (! is.null(class_sep)) {
    split_input <- strsplit(class, class_sep, fixed = FALSE)
    result <- lapply(split_input,
                     function(x) data.frame(stringr::str_match(x, class_regex), stringsAsFactors = FALSE)[, -1, drop = FALSE])
  } else {
    result <- lapply(stringr::str_match_all(class, class_regex), function(x) data.frame(x[, -1, drop = FALSE], stringsAsFactors = FALSE))
  }
  
  # Reverse the order if needed
  if (class_rev) {
    result <- lapply(result, function(x) {
      x <- x[rev(1:nrow(x)), ]
      row.names(x) <- NULL
      x
    })
  }
  
  # Name columns in each classification according to the key
  result <- lapply(result, function(x) stats::setNames(x, names(class_key)))
  
  # Add taxon_id column if missing
  if (! "taxon_id" %in% class_key && "name" %in% class_key && database != "none") {
    unique_taxon_names <- unique(unlist(lapply(result, function(x) x$name)))
    name_id_key <- get_id_from_name(unique_taxon_names, database)
    col_name <- paste0(database, "_id")
    result <- lapply(result, function(x) {x[col_name] = name_id_key[x$name]; x})
  }
  
  # Add name column if missing
  if (! "name" %in% class_key && "taxon_id" %in% class_key && database != "none") {
    unique_taxon_ids <- unique(unlist(lapply(result, function(x) x$taxon_id)))
    id_name_key <- get_name_from_id(unique_taxon_ids, database)
    result <- lapply(result, function(x) {x$name = id_name_key[x$taxon_id]; x})
  }
  
  return(result)
}




#' Get taxon ID from name
#' 
#' Get a taxon's ID from its name
#' 
#' @param name (\code{character})
#' Names to look up IDs for
#' @param database (\code{character} of length 1)
#' Database to use to look up id.
#' 
#' @keywords internal 
get_id_from_name <- function(name, database) {
  id_from_name_funcs <- list(ncbi = taxize::get_uid,
                             itis = taxize::get_tsn,
                             eol = taxize::get_eolid,
                             col = taxize::get_colid,
                             tropicos = taxize::get_tpsid,
                             nbn = taxize::get_nbnid, 
                             none = NA)
  ids <- map_unique(name, id_from_name_funcs[[database]], ask = FALSE, rows = 1)
  names(ids) <- name
  return(ids)
}

#' Get taxon name from ID
#' 
#' Get a taxon's name from its ID
#' 
#' @param id (\code{character})
#' Id to look up names for
#' @param database (\code{character} of length 1)
#' Database to use to look up id.
#' 
#' @keywords internal 
get_name_from_id <- function(id, database) {
  classifications <- map_unique(id, taxize::classification, db = database)
  name_key <- unlist(lapply(classifications, function(x) x[nrow(x), "name"]))
  names(name_key) <- id
  return(name_key)
}


#' Retrieve classifications from taxon names
#' 
#' Retrieve taxonomic classifications from taxon names using a specified database.
#' 
#' @param name (\code{character})
#' The name of a taxon. Not necessarily unique, but are interpretable by a particular \code{database}.
#' Requires an internet connection.
#' @param database (\code{character} of length 1)
#' The name of the database that patterns given in  \code{parser} will apply to.
#' Valid databases include "ncbi", "itis", "eol", "col", "tropicos",
#' "nbn", and "none". \code{"none"} will cause no database to be quired; use this if you want to not use the
#' internet. NOTE: Only \code{"ncbi"} has been tested so far.
#' @param ... Not used
#' 
#' @return \code{list} of \code{data.frame}
#' 
#' @keywords internal
class_from_name <- function(name, database, ...) {
  # Look up classifications
  result <- map_unique(name, taxize::classification, ask = FALSE, rows = 1, db = database)
  # Complain about failed queries
  failed_queries <- is.na(result)
  max_print <- 10
  if (sum(failed_queries) > 0) {
    invalid_list <- paste("   ", which(failed_queries), ": ", names(which(failed_queries)), "\n")
    if (length(invalid_list) > max_print) {
      invalid_list <- c(invalid_list[1:max_print], "    ...")
    }
    vigilant_report(paste0(collapse = "",
                           c("The following ", sum(failed_queries), " of ", length(failed_queries),
                             " taxon name(s) could not be looked up using the database '", database, "':\n",
                             invalid_list)))
  }
#   # Remove failed queries
#   result <- result[! failed_queries]
  # Rename columns of result
  result[! failed_queries] <- lapply(result[! failed_queries],
                                     function(x) stats::setNames(x, c("name", "rank", paste0(database, "_id"))))
  return(result)
}


#' Retrieve classifications from taxon IDs
#' 
#' Retrieve taxonomic classifications from taxon IDs using a specified database.
#' 
#' @param name (\code{character})
#' The name of a taxon. Not necessarily unique, but are interpretable by a particular \code{database}.
#' Requires an internet connection.
#' @param database (\code{character} of length 1)
#' The name of the database that patterns given in  \code{parser} will apply to.
#' Valid databases include "ncbi", "itis", "eol", "col", "tropicos",
#' "nbn", and "none". \code{"none"} will cause no database to be quired; use this if you want to not use the
#' internet. NOTE: Only \code{"ncbi"} has been tested so far.
#' @param ... Not used
#' 
#' @return \code{list} of \code{data.frame}
#' 
#' @keywords internal
class_from_taxon_id <- function(taxon_id, database, ...) {
  result <- map_unique(taxon_id, taxize::classification, ask = FALSE, rows = 1, db = database)
  result <- lapply(result, function(x) stats::setNames(x, c("name", "rank", paste0(database, "_id"))))
  return(result)
}


