test_that("sports classification works correctly", {
  test_data <- data.frame(
    profileId = c("1", "2", "3"),
    all_group_names = c("Football Team A", "Basketball Squad", "Cricket Academy"),
    stringsAsFactors = FALSE
  )

  result <- classify_sports(test_data)

  expect_true("sports_clean" %in% names(result))
  expect_equal(result$sports_clean[1], "Football")
  expect_equal(result$sports_clean[2], "Basketball")
  expect_equal(result$sports_clean[3], "Cricket")
})

test_that("split_by_test creates separate data frames", {
  test_data <- data.frame(
    profileId = c("P1", "P1", "P2", "P2"),
    Testdate = as.Date(c("2020-01-01", "2020-01-01", "2020-01-02", "2020-01-02")),
    PEAK_FORCE_Both_CMJ = c(1000, 1100, 1200, 1300),
    PEAK_FORCE_Both_DJ = c(900, 950, 1000, 1050),
    stringsAsFactors = FALSE
  )

  result <- split_by_test(test_data, verbose = FALSE)

  expect_type(result, "list")
  expect_equal(length(result), 2)
  expect_true("CMJ" %in% names(result))
  expect_true("DJ" %in% names(result))
})

test_that("patch_metadata handles missing values", {
  test_data <- data.frame(
    profileId = c("P1", "P2"),
    sex = c(NA, "Male"),
    dateOfBirth = c(NA, "1990-01-01"),
    stringsAsFactors = FALSE
  )

  temp_file <- tempfile(fileext = ".csv")
  patch_data <- data.frame(
    profileId = c("P1"),
    sex = c("Female"),
    dateOfBirth = c("1995-05-05"),
    stringsAsFactors = FALSE
  )
  write.csv(patch_data, temp_file, row.names = FALSE)

  result <- patch_metadata(test_data, temp_file, verbose = FALSE)

  expect_equal(result$sex[result$profileId == "P1"], "Female")
  expect_equal(nrow(result), 2)

  unlink(temp_file)
})
