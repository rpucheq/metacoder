#| ## Testing utility methods for `taxmap` objects
#|
library(metacoder)
context("Utility methods for `taxmap` objects")
#|
#| ### Getting supertaxa
#|
#| ####  Code shared by tests
obj <- taxmap(taxon_ids = LETTERS[1:5], supertaxon_ids = c(NA, 1, 2, 2, 1), 
                  obs_taxon_ids = c(2, 2, 1, 1, 3, 4, 5, 3, 3, 4),
                  taxon_data = data.frame(name = letters[1:5],  stringsAsFactors = FALSE),
                  obs_data = data.frame(obs_attr = letters[1:10],  stringsAsFactors = FALSE))
original_plot <- heat_tree(obj, node_label = paste(name, n_obs), node_color = n_obs, layout = "fr")
#|
#| ####  Immediate supertaxa
test_that("Getting immediate supertaxa works", {
  result <- supertaxa(obj, recursive = FALSE, simplify = FALSE, include_input = FALSE, index = FALSE, na = FALSE)
  expect_equal(class(result), "list")
  expect_equal(names(result), obj$taxon_data$taxon_ids)
  expect_equal(result$A, character(0))
  expect_equal(result$B, "A")
  result <- supertaxa(obj, recursive = FALSE, simplify = FALSE, include_input = TRUE, index = FALSE, na = FALSE)
  expect_true(all(sapply(result, function(x) x[1]) ==  names(result)))
  result <- supertaxa(obj, recursive = FALSE, simplify = TRUE, include_input = FALSE, index = FALSE, na = FALSE)
  expect_equal(class(result), "character")
  result <- supertaxa(obj, recursive = FALSE, simplify = TRUE, include_input = TRUE, index = FALSE, na = FALSE)
  expect_true(all(result %in% obj$taxon_data$taxon_ids))
})
#|
#| ####  All supertaxa
test_that("Getting all supertaxa works", {
  result <- supertaxa(obj, recursive = TRUE, simplify = FALSE, include_input = FALSE, index = FALSE, na = FALSE)
  expect_equal(class(result), "list")
  expect_equal(names(result), obj$taxon_data$taxon_ids)
  expect_equal(result$A, character(0))
  expect_equal(result$B, "A")
  result <- supertaxa(obj, recursive = TRUE, simplify = FALSE, include_input = TRUE, index = FALSE, na = FALSE)
  expect_true(all(sapply(result, function(x) x[1]) ==  names(result)))
  result <- supertaxa(obj, recursive = TRUE, simplify = TRUE, include_input = FALSE, index = FALSE, na = FALSE)
  expect_equal(class(result), "character")
  result <- supertaxa(obj, recursive = TRUE, simplify = TRUE, include_input = TRUE, index = FALSE, na = FALSE)
  expect_true(all(result %in% obj$taxon_data$taxon_ids))
})
#|
#| ### Getting subtaxa
#|
#| ####  Code shared by tests
test_that("Getting immediate subtaxa works", {
  result <- subtaxa(obj, recursive = FALSE, simplify = FALSE, include_input = FALSE, index = FALSE)
  expect_equal(class(result), "list")
  expect_equal(names(result), obj$taxon_data$taxon_ids)
  expect_equal(result$E, character(0))
  expect_equal(result$B, c("C", "D"))
  result <- subtaxa(obj, recursive = FALSE, simplify = FALSE, include_input = TRUE, index = FALSE)
  expect_true(all(sapply(result, function(x) x[1]) ==  names(result)))
  result <- subtaxa(obj, recursive = FALSE, simplify = TRUE, include_input = FALSE, index = FALSE)
  expect_equal(class(result), "character")
  result <- subtaxa(obj, recursive = FALSE, simplify = TRUE, include_input = TRUE, index = FALSE)
  expect_true(all(result %in% obj$taxon_data$taxon_ids))
})
test_that("Getting all subtaxa works", {
  result <- subtaxa(obj, recursive = TRUE, simplify = FALSE, include_input = FALSE, index = FALSE)
  expect_equal(class(result), "list")
  expect_equal(names(result), obj$taxon_data$taxon_ids)
  expect_equal(result$A, LETTERS[2:5])
  expect_equal(result$E, character(0))
  result <- subtaxa(obj, recursive = TRUE, simplify = FALSE, include_input = TRUE, index = FALSE)
  expect_true(all(sapply(result, function(x) x[1]) ==  names(result)))
  result <- subtaxa(obj, recursive = TRUE, simplify = TRUE, include_input = FALSE, index = FALSE)
  expect_equal(class(result), "character")
  result <- subtaxa(obj, recursive = TRUE, simplify = TRUE, include_input = TRUE, index = FALSE)
  expect_true(all(result %in% obj$taxon_data$taxon_ids))
})
