#' Fetch VALD ForceDecks Data in Batches
#'
#' @title Robust Batch Extraction of VALD Trials
#'
#' @description
#' Implements chunked trial extraction from VALD ForceDecks API with fault-tolerant
#' error handling. This function prevents timeout errors and memory issues when
#' working with large datasets by processing data in manageable chunks.
#'
#' @param start_date Character string in ISO 8601 format (e.g., "2020-01-01T00:00:00Z").
#'   The starting date for data extraction.
#' @param chunk_size Integer. Number of tests to process per batch. Default is 100.
#'   Reduce this value if you experience timeout errors.
#' @param verbose Logical. If TRUE, prints progress messages. Default is TRUE.
#'
#' @return A list containing two data frames:
#'   \describe{
#'     \item{tests}{Data frame of all tests metadata}
#'     \item{trials}{Data frame of all trials (individual repetitions) data}
#'   }
#'
#' @details
#' This function first retrieves all test metadata, then iterates through tests
#' in chunks to fetch associated trial data. Each chunk is wrapped in a tryCatch
#' block to ensure that errors in one chunk do not halt the entire extraction process.
#'
#' The chunking strategy is essential for large organizations with thousands of tests,
#' as it prevents API timeout errors and reduces memory pressure.
#'
#' @export
#'
#' @importFrom dplyr bind_rows
#'
#' @examples
#' \donttest{
#' if (FALSE) {
#'   # Set VALD credentials first
#'   valdr::set_credentials(
#'     client_id = "your_client_id",
#'     client_secret = "your_client_secret",
#'     tenant_id = "your_tenant_id",
#'     region = "aue"
#'   )
#'
#'   # Fetch data from 2020 onwards in chunks of 100
#'   vald_data <- fetch_vald_batch(
#'     start_date = "2020-01-01T00:00:00Z",
#'     chunk_size = 100
#'   )
#'
#'   # Access tests and trials
#'   tests_df <- vald_data$tests
#'   trials_df <- vald_data$trials
#' }
#' }
fetch_vald_batch <- function(start_date, chunk_size = 100, verbose = TRUE) {

  if (!requireNamespace("valdr", quietly = TRUE)) {
    stop("Package 'valdr' is required but not installed. Install it with: install.packages('valdr')")
  }

  old_timeout <- getOption("timeout")
  on.exit(options(timeout = old_timeout), add = TRUE)
  options(timeout = 18000)

  valdr::set_start_date(start_date)
  if (verbose) message("Data pull start date set to: ", start_date)

  if (verbose) message("--- Starting data pull for TESTS... ---")

  all_tests_data <- tryCatch({
    valdr::get_forcedecks_tests_only()
  }, error = function(e) {
    stop("TEST DATA PULL FAILED: ", e$message)
  })

  if (verbose) {
    message("TEST data pull complete!")
    message("Total test rows fetched: ", nrow(all_tests_data))
  }

  total_tests <- nrow(all_tests_data)
  chunk_starts <- seq(1, total_tests, by = chunk_size)
  all_trial_chunks <- list()

  if (verbose) {
    message("--- Starting data pull for TRIALS (in chunks)... ---")
    message("Splitting ", total_tests, " tests into ", length(chunk_starts), " chunks of ", chunk_size)
  }

  for (i in seq_along(chunk_starts)) {

    start_row <- chunk_starts[i]
    end_row <- min(start_row + chunk_size - 1, total_tests)

    if (verbose) message("... Fetching trials for test rows ", start_row, " to ", end_row)

    tryCatch({
      current_test_chunk <- all_tests_data[start_row:end_row, ]
      current_trial_chunk <- valdr::get_forcedecks_trials_only(current_test_chunk)

      if (nrow(current_trial_chunk) > 0) {
        all_trial_chunks[[i]] <- current_trial_chunk
      }

    }, error = function(e) {
      if (verbose) {
        message("ERROR on chunk ", i, " (rows ", start_row, "-", end_row, "): ", e$message)
        message("Continuing to next chunk...")
      }
    })
  }

  if (verbose) message("TRIAL data pull complete!")

  if (length(all_trial_chunks) == 0) {
    stop("No trial data was successfully fetched.")
  }

  all_trials_data <- dplyr::bind_rows(all_trial_chunks)

  if (verbose) message("Total trial rows fetched: ", nrow(all_trials_data))

  valdr::set_start_date(NULL)
  if (verbose) message("valdr start date has been reset.")

  return(list(
    tests = all_tests_data,
    trials = all_trials_data
  ))
}
