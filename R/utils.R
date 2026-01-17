#' Global Imports
#'
#' @name global_imports
#' @description
#' This file handles global imports for the package.
#'
#' @importFrom dplyr %>%
#' @keywords internal
NULL

utils::globalVariables(c(
  ".data", ":=", "athleteId", "testId", "testType", "recordedUTC",
  "recordedDateOffset", "trialLimb", "definition_name", "value", "weight",
  "TestTimestampUTC", "TestTimestampLocal", "Testdate", "mean_result",
  "mean_weight", "id", "groupIds", "groupId", "name"
))

#' Pipe operator
#'
#' @name %>%
#' @rdname pipe
#' @keywords internal
#' @export
#' @importFrom dplyr %>%
#' @usage lhs \%>\% rhs
#' @param lhs A value or the magrittr placeholder.
#' @param rhs A function call using the magrittr semantics.
#' @return The result of calling \code{rhs(lhs)}.
NULL


#' Transform Trials and Tests to Wide Format
#'
#' @title Create Analysis-Ready Wide-Format Dataset
#'
#' @description
#' Internal utility function that combines trials and tests data, aggregates
#' multiple repetitions (trials) per test, and pivots to wide format where
#' each metric-limb-test combination becomes a separate column.
#'
#' @param trials Data frame. Trial-level data from \code{fetch_vald_batch()$trials}.
#' @param tests Data frame. Test-level data from \code{fetch_vald_batch()$tests}.
#' @param aggregate_fun Function to use for aggregating trials. Default is mean.
#'
#' @return Wide-format data frame with one row per test.
#'
#' @keywords internal
#'
#' @importFrom dplyr left_join group_by summarise mutate select
#' @importFrom dplyr %>%
#' @importFrom tidyr pivot_wider
#' @importFrom lubridate ymd_hms minutes
transform_to_wide <- function(trials, tests, aggregate_fun = mean) {

  all_data <- dplyr::left_join(trials, tests, by = c("testId", "athleteId"))

  test_data_agg <- all_data %>%
    dplyr::group_by(
      athleteId,
      testId,
      testType,
      recordedUTC,
      recordedDateOffset,
      trialLimb,
      definition_name
    ) %>%
    dplyr::summarise(
      mean_result = aggregate_fun(as.numeric(value), na.rm = TRUE),
      mean_weight = aggregate_fun(as.numeric(weight), na.rm = TRUE),
      .groups = "drop"
    )

  test_data_with_date <- test_data_agg %>%
    dplyr::mutate(
      TestTimestampUTC = lubridate::ymd_hms(recordedUTC),
      TestTimestampLocal = TestTimestampUTC + lubridate::minutes(recordedDateOffset),
      Testdate = as.Date(TestTimestampLocal)
    )

  structured_test_data <- test_data_with_date %>%
    dplyr::select(athleteId, Testdate, testId, testType, trialLimb, definition_name, mean_result, mean_weight) %>%
    tidyr::pivot_wider(
      id_cols = c(athleteId, Testdate, testId, mean_weight),
      names_from = c(definition_name, trialLimb, testType),
      values_from = mean_result,
      names_glue = "{definition_name}_{trialLimb}_{testType}"
    ) %>%
    dplyr::rename(Weight_on_Test_Day = mean_weight)

  return(structured_test_data)
}


#' Calculate Age from Date of Birth and Test Date
#'
#' @title Add Age Variable to Dataset
#'
#' @description
#' Calculates age in years based on date of birth and test date.
#' Handles missing dates gracefully.
#'
#' @param data Data frame containing date columns.
#' @param dob_col Character. Name of date of birth column. Default is "dateOfBirth".
#' @param test_date_col Character. Name of test date column. Default is "Testdate".
#' @param output_col Character. Name for the new age column. Default is "age".
#'
#' @return Data frame with added age column.
#'
#' @keywords internal
#'
#' @importFrom dplyr mutate
#' @importFrom dplyr %>%
calculate_age <- function(data, dob_col = "dateOfBirth",
                         test_date_col = "Testdate",
                         output_col = "age") {

  data %>%
    dplyr::mutate(
      !!output_col := as.numeric(
        (.data[[test_date_col]] - as.Date(.data[[dob_col]])) / 365.25
      )
    )
}
