#' Split Wide-Format Data by Test Type
#'
#' @title Generic Test-Type Splitting with Suffix Removal
#'
#' @description
#' Takes a master wide-format dataset and returns a named list of data frames,
#' one per test type (e.g., CMJ, DJ, ISO). Crucially, this function automatically
#' strips the test-type suffix from column names within each sub-dataframe,
#' enabling generic analysis code that works across all test types.
#'
#' This implements the "DRY" (Don't Repeat Yourself) principle by allowing
#' users to write one analysis function that works for any test type.
#'
#' @param data Data frame. Wide-format test data with columns ending in test
#'   type suffixes (e.g., "PEAK_FORCE_Both_CMJ").
#' @param metadata_cols Character vector. Column names to retain as metadata
#'   in each split dataset. Default includes common identifiers and demographics.
#' @param verbose Logical. If TRUE, prints progress messages. Default is TRUE.
#'
#' @return Named list of data frames, one per test type. Each data frame contains:
#'   \itemize{
#'     \item All metadata columns
#'     \item Test-specific metrics with suffixes removed (e.g., "PEAK_FORCE_Both")
#'   }
#'
#' @export
#'
#' @importFrom dplyr select filter rename_with
#' @importFrom dplyr %>%
#' @importFrom stringr str_ends str_remove
#'
#' @examples
#' \donttest{
#' if (FALSE) {
#'   # After joining tests, trials, and metadata into wide format
#'   test_datasets <- split_by_test(
#'     data = final_analysis_data,
#'     metadata_cols = c("profileId", "sex", "Testdate", "age", "sports")
#'   )
#'
#'   # Access individual test datasets
#'   cmj_data <- test_datasets$CMJ
#'   dj_data <- test_datasets$DJ
#'
#'   # Note: Column names are now generic (e.g., "PEAK_FORCE_Both" not "PEAK_FORCE_Both_CMJ")
#'   # This allows you to write one function that works for all test types
#' }
#' }
split_by_test <- function(data, metadata_cols = NULL, verbose = TRUE) {

  if (is.null(metadata_cols)) {
    metadata_cols <- c(
      "profileId", "athleteId", "sex", "Testdate", "dateofbirth",
      "age", "testId", "Weight_on_Test_Day", "sports"
    )
  }

  metadata_cols <- intersect(metadata_cols, names(data))

  all_cols <- names(data)
  suffix_pattern <- "_([A-Z]{2,}[A-Z0-9]*)$"
  test_cols <- grep(suffix_pattern, all_cols, value = TRUE)

  if (length(test_cols) == 0) {
    stop("No test-type suffixed columns found in data")
  }

  test_types <- unique(gsub(".*_([A-Z]{2,}[A-Z0-9]*)$", "\\1", test_cols))

  if (verbose) message("Discovered test types: ", paste(test_types, collapse = ", "))

  clean_datasets <- list()

  for (current_test in test_types) {

    test_cols_for_this <- all_cols[stringr::str_ends(all_cols, paste0("_", current_test))]

    if (length(test_cols_for_this) == 0) next

    df_test <- data %>%
      dplyr::select(dplyr::all_of(metadata_cols), dplyr::all_of(test_cols_for_this))

    filter_col <- test_cols_for_this[1]
    df_test <- df_test %>%
      dplyr::filter(!is.na(.data[[filter_col]]))

    df_test <- df_test %>%
      dplyr::rename_with(
        ~ stringr::str_remove(., paste0("_", current_test, "$")),
        dplyr::all_of(test_cols_for_this)
      )

    clean_datasets[[current_test]] <- df_test

    if (verbose) message("Created dataset for ", current_test, ": ", nrow(df_test), " rows")
  }

  if (verbose) message("Split complete. ", length(clean_datasets), " test types extracted.")

  return(clean_datasets)
}


#' Patch Missing Metadata from External File
#'
#' @title Fix Missing or Incorrect Athlete Demographics
#'
#' @description
#' Allows users to provide an external Excel or CSV file containing corrected
#' demographic information (e.g., sex, date of birth) for athletes with missing
#' or incorrect data in the VALD system. This function merges the corrections
#' and updates the master metadata.
#'
#' @param data Data frame. Master metadata or analysis dataset.
#' @param patch_file Character. Path to Excel (.xlsx) or CSV (.csv) file
#'   containing corrections.
#' @param patch_sheet Character or integer. For Excel files, which sheet to read.
#'   Default is 1 (first sheet).
#' @param id_col Character. Name of the ID column in both \code{data} and
#'   \code{patch_file}. Default is "profileId".
#' @param fields_to_patch Character vector. Column names to update from the
#'   patch file. Default is c("sex", "dateOfBirth").
#' @param verbose Logical. If TRUE, prints progress messages. Default is TRUE.
#'
#' @return Data frame with patched metadata.
#'
#' @export
#'
#' @importFrom dplyr left_join mutate case_when
#' @importFrom dplyr %>%
#' @importFrom readxl read_excel
#' @importFrom utils read.csv
#' @importFrom stats setNames
#'
#' @examples
#' \donttest{
#' if (FALSE) {
#'   # Create an Excel file with columns: profileId, sex, dateOfBirth
#'   # Then patch the metadata
#'   patched_data <- patch_metadata(
#'     data = athlete_metadata,
#'     patch_file = "corrections.xlsx",
#'     fields_to_patch = c("sex", "dateOfBirth")
#'   )
#'
#'   # Check results
#'   table(patched_data$sex)
#' }
#' }
patch_metadata <- function(data, patch_file, patch_sheet = 1,
                          id_col = "profileId",
                          fields_to_patch = c("sex", "dateOfBirth"),
                          verbose = TRUE) {

  if (!file.exists(patch_file)) {
    stop("Patch file not found: ", patch_file)
  }

  file_ext <- tolower(tools::file_ext(patch_file))

  if (verbose) message("Reading patch file: ", patch_file)

  if (file_ext == "xlsx" || file_ext == "xls") {
    if (!requireNamespace("readxl", quietly = TRUE)) {
      stop("Package 'readxl' is required for Excel files. Install it with: install.packages('readxl')")
    }
    patch_df <- readxl::read_excel(patch_file, sheet = patch_sheet)
  } else if (file_ext == "csv") {
    patch_df <- utils::read.csv(patch_file, stringsAsFactors = FALSE)
  } else {
    stop("Unsupported file format. Use .xlsx, .xls, or .csv")
  }

  if (!id_col %in% names(patch_df)) {
    stop("ID column '", id_col, "' not found in patch file")
  }

  missing_fields <- setdiff(fields_to_patch, names(patch_df))
  if (length(missing_fields) > 0) {
    warning("Fields not found in patch file and will be skipped: ",
            paste(missing_fields, collapse = ", "))
    fields_to_patch <- intersect(fields_to_patch, names(patch_df))
  }

  patch_df[[id_col]] <- as.character(patch_df[[id_col]])
  data[[id_col]] <- as.character(data[[id_col]])

  suffix <- "_patched"
  rename_map <- setNames(
    paste0(fields_to_patch, suffix),
    fields_to_patch
  )

  patch_df_renamed <- patch_df %>%
    dplyr::select(dplyr::all_of(c(id_col, fields_to_patch)))

  names(patch_df_renamed)[names(patch_df_renamed) %in% fields_to_patch] <-
    rename_map[names(patch_df_renamed)[names(patch_df_renamed) %in% fields_to_patch]]

  data_patched <- data %>%
    dplyr::left_join(patch_df_renamed, by = id_col)

  for (field in fields_to_patch) {
    original_col <- field
    patched_col <- paste0(field, suffix)

    if (patched_col %in% names(data_patched)) {
      data_patched <- data_patched %>%
        dplyr::mutate(
          !!original_col := dplyr::case_when(
            is.na(.data[[original_col]]) | .data[[original_col]] %in% c("Unknown", "NotApplicable", "") ~ .data[[patched_col]],
            TRUE ~ .data[[original_col]]
          )
        )

      data_patched[[patched_col]] <- NULL
    }
  }

  if (verbose) {
    message("Patching complete. Updated ", nrow(data_patched), " rows.")
    for (field in fields_to_patch) {
      if (field %in% names(data_patched)) {
        message("  ", field, ": ", sum(!is.na(data_patched[[field]])), " non-missing values")
      }
    }
  }

  return(data_patched)
}
