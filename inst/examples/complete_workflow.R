#' Complete Workflow Example for vald.extractor Package
#'
#' This script demonstrates the full pipeline from API extraction to
#' publication-ready visualizations.
#'
#' IMPORTANT: Replace credentials with your actual VALD API credentials
#' before running this script.

library(vald.extractor)
library(dplyr)
library(tidyr)

# ==============================================================================
# CONFIGURATION
# ==============================================================================

# Set up temporary directory for outputs (CRAN compliance)
output_dir <- tempdir()
cat("Output files will be saved to:", output_dir, "\n\n")

# Replace with your actual credentials
MY_CLIENT_ID     <- "your_client_id_here"
MY_CLIENT_SECRET <- "your_client_secret_here"
MY_TENANT_ID     <- "your_tenant_id_here"
MY_REGION        <- "aue"  # or your region code

START_DATE <- "2020-01-01T00:00:00Z"  # Adjust as needed
CHUNK_SIZE <- 100  # Reduce if experiencing timeout errors

# ==============================================================================
# STEP 1: EXTRACT TEST AND TRIAL DATA
# ==============================================================================

cat("=== STEP 1: EXTRACTING TEST AND TRIAL DATA ===\n")

# Set VALD credentials for valdr package
valdr::set_credentials(
  client_id     = MY_CLIENT_ID,
  client_secret = MY_CLIENT_SECRET,
  tenant_id     = MY_TENANT_ID,
  region        = MY_REGION
)

# Fetch data in chunks (prevents timeout errors)
vald_data <- fetch_vald_batch(
  start_date = START_DATE,
  chunk_size = CHUNK_SIZE,
  verbose = TRUE
)

tests_df  <- vald_data$tests
trials_df <- vald_data$trials

cat("Extracted", nrow(tests_df), "tests and", nrow(trials_df), "trials\n\n")

# ==============================================================================
# STEP 2: FETCH AND STANDARDIZE METADATA
# ==============================================================================

cat("=== STEP 2: FETCHING ATHLETE METADATA ===\n")

# Fetch profiles and groups via OAuth2
metadata <- fetch_vald_metadata(
  client_id     = MY_CLIENT_ID,
  client_secret = MY_CLIENT_SECRET,
  tenant_id     = MY_TENANT_ID,
  region        = MY_REGION,
  verbose = TRUE
)

# Standardize: unnest groups and create unified athlete records
athlete_metadata <- standardize_vald_metadata(
  profiles = metadata$profiles,
  groups   = metadata$groups,
  verbose = TRUE
)

cat("\n")

# ==============================================================================
# STEP 3: CLASSIFY SPORTS
# ==============================================================================

cat("=== STEP 3: APPLYING SPORTS TAXONOMY ===\n")

athlete_metadata <- classify_sports(
  data = athlete_metadata,
  group_col = "all_group_names",
  output_col = "sports_clean"
)

cat("Sports distribution:\n")
print(table(athlete_metadata$sports_clean))
cat("\n")

# ==============================================================================
# STEP 4: TRANSFORM TO WIDE FORMAT
# ==============================================================================

cat("=== STEP 4: TRANSFORMING TO WIDE FORMAT ===\n")

# Join trials and tests
all_data <- left_join(
  trials_df,
  tests_df,
  by = c("testId", "athleteId")
)

# Aggregate trials (reps) and pivot to wide format
structured_test_data <- all_data %>%
  group_by(
    athleteId, testId, testType, recordedUTC,
    recordedDateOffset, trialLimb, definition_name
  ) %>%
  summarise(
    mean_result = mean(as.numeric(value), na.rm = TRUE),
    mean_weight = mean(as.numeric(weight), na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    TestTimestampUTC = lubridate::ymd_hms(recordedUTC),
    TestTimestampLocal = TestTimestampUTC + lubridate::minutes(recordedDateOffset),
    Testdate = as.Date(TestTimestampLocal)
  ) %>%
  select(athleteId, Testdate, testId, testType, trialLimb,
         definition_name, mean_result, mean_weight) %>%
  pivot_wider(
    id_cols = c(athleteId, Testdate, testId, mean_weight),
    names_from = c(definition_name, trialLimb, testType),
    values_from = mean_result,
    names_glue = "{definition_name}_{trialLimb}_{testType}"
  ) %>%
  rename(Weight_on_Test_Day = mean_weight)

cat("Wide format data created:", nrow(structured_test_data), "rows\n\n")

# ==============================================================================
# STEP 5: JOIN WITH METADATA
# ==============================================================================

cat("=== STEP 5: JOINING WITH METADATA ===\n")

final_analysis_data <- structured_test_data %>%
  mutate(profileId = as.character(athleteId)) %>%
  left_join(
    athlete_metadata %>%
      mutate(profileId = as.character(profileId)),
    by = "profileId"
  ) %>%
  mutate(
    Testdate = as.Date(Testdate),
    dateofbirth = as.Date(dateOfBirth),
    age = as.numeric((Testdate - dateofbirth) / 365.25),
    sports = sports_clean
  )

cat("Final dataset:", nrow(final_analysis_data), "rows with",
    ncol(final_analysis_data), "columns\n\n")

# ==============================================================================
# STEP 6: SPLIT BY TEST TYPE
# ==============================================================================

cat("=== STEP 6: SPLITTING BY TEST TYPE ===\n")

test_datasets <- split_by_test(
  data = final_analysis_data,
  metadata_cols = c("profileId", "sex", "Testdate", "dateofbirth",
                    "age", "testId", "Weight_on_Test_Day", "sports"),
  verbose = TRUE
)

cat("\nAvailable test types:", paste(names(test_datasets), collapse = ", "), "\n\n")

# ==============================================================================
# STEP 7: OPTIONAL - PATCH MISSING METADATA
# ==============================================================================

# Uncomment and modify if you have a corrections file
# cat("=== STEP 7: PATCHING METADATA (OPTIONAL) ===\n")
#
# if (file.exists("corrections.xlsx")) {
#   test_datasets$CMJ <- patch_metadata(
#     data = test_datasets$CMJ,
#     patch_file = "corrections.xlsx",
#     fields_to_patch = c("sex", "dateOfBirth")
#   )
# }

# ==============================================================================
# STEP 8: GENERATE SUMMARY STATISTICS
# ==============================================================================

cat("=== STEP 8: GENERATING SUMMARY STATISTICS ===\n")

# Example: CMJ summary by sex and sport
if ("CMJ" %in% names(test_datasets)) {
  cmj_summary <- summary_vald_metrics(
    data = test_datasets$CMJ,
    group_vars = c("sex", "sports")
  )

  cat("CMJ Summary (first 10 rows):\n")
  print(head(cmj_summary, 10))

  # Save to CSV
  output_file <- file.path(output_dir, "cmj_summary.csv")
  write.csv(cmj_summary, output_file, row.names = FALSE)
  cat("\nSaved to:", output_file, "\n\n")
}

# ==============================================================================
# STEP 9: VISUALIZATIONS
# ==============================================================================

cat("=== STEP 9: CREATING VISUALIZATIONS ===\n")

if ("CMJ" %in% names(test_datasets)) {

  # Plot 1: Longitudinal trends
  cat("Creating longitudinal trend plot...\n")
  p1 <- plot_vald_trends(
    data = test_datasets$CMJ,
    date_col = "Testdate",
    metric_col = "PEAK_FORCE_Both",
    group_col = "profileId",
    facet_col = "sex",
    title = "CMJ Peak Force Trends by Athlete"
  )
  output_file <- file.path(output_dir, "cmj_trends.png")
  ggsave(output_file, p1, width = 10, height = 6, dpi = 300)
  cat("Saved to:", output_file, "\n")

  # Plot 2: Cross-sectional comparison
  cat("Creating cross-sectional comparison plot...\n")
  p2 <- plot_vald_compare(
    data = test_datasets$CMJ,
    metric_col = "PEAK_FORCE_Both",
    group_col = "sports",
    fill_col = "sex",
    title = "CMJ Peak Force by Sport and Sex"
  )
  output_file <- file.path(output_dir, "cmj_comparison.png")
  ggsave(output_file, p2, width = 10, height = 6, dpi = 300)
  cat("Saved to:", output_file, "\n")

  # Plot 3: Jump height comparison
  if ("JUMP_HEIGHT_Both" %in% names(test_datasets$CMJ)) {
    cat("Creating jump height comparison plot...\n")
    p3 <- plot_vald_compare(
      data = test_datasets$CMJ,
      metric_col = "JUMP_HEIGHT_Both",
      group_col = "sports",
      fill_col = "sex",
      title = "CMJ Jump Height by Sport and Sex"
    )
    output_file <- file.path(output_dir, "cmj_jumpheight.png")
    ggsave(output_file, p3, width = 10, height = 6, dpi = 300)
    cat("Saved to:", output_file, "\n")
  }
}

cat("\n=== WORKFLOW COMPLETE ===\n")
cat("All generated files are in:", output_dir, "\n")
cat("Generated files:\n")
cat("  - cmj_summary.csv\n")
cat("  - cmj_trends.png\n")
cat("  - cmj_comparison.png\n")
cat("  - cmj_jumpheight.png\n")
cat("  - vald_analysis_workspace.RData\n\n")

# ==============================================================================
# STEP 10: SAVE WORKSPACE FOR FUTURE ANALYSIS
# ==============================================================================

cat("=== STEP 10: SAVING WORKSPACE ===\n")

output_file <- file.path(output_dir, "vald_analysis_workspace.RData")
save(
  test_datasets,
  athlete_metadata,
  final_analysis_data,
  file = output_file
)

cat("Workspace saved to:", output_file, "\n")
cat("Load it in future sessions with: load('", output_file, "')\n\n", sep = "")

# ==============================================================================
# ADVANCED EXAMPLE: GENERIC ANALYSIS ACROSS TEST TYPES
# ==============================================================================

cat("=== ADVANCED EXAMPLE: GENERIC ANALYSIS ===\n")

# Define a function that works for ANY test type (thanks to suffix removal)
calculate_bilateral_asymmetry <- function(test_data) {
  if (all(c("PEAK_FORCE_Left", "PEAK_FORCE_Right") %in% names(test_data))) {
    test_data %>%
      mutate(
        asymmetry_percent = (PEAK_FORCE_Left - PEAK_FORCE_Right) /
                            ((PEAK_FORCE_Left + PEAK_FORCE_Right) / 2) * 100
      )
  } else {
    test_data
  }
}

# Apply to all test types with one line of code
test_datasets_with_asymmetry <- lapply(test_datasets, calculate_bilateral_asymmetry)

cat("Bilateral asymmetry calculated for all test types\n")
cat("Example (CMJ):\n")
if ("CMJ" %in% names(test_datasets_with_asymmetry) &&
    "asymmetry_percent" %in% names(test_datasets_with_asymmetry$CMJ)) {
  cat("  Mean asymmetry:",
      round(mean(test_datasets_with_asymmetry$CMJ$asymmetry_percent, na.rm = TRUE), 2),
      "%\n")
}

cat("\n=== ALL DONE! ===\n")
