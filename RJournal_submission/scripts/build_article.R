# Automated Build Script for R Journal Submission
# This script builds the article and prepares it for submission

cat("========================================\n")
cat("R Journal Article Build Script\n")
cat("vald.extractor package\n")
cat("========================================\n\n")

# Set working directory to parent (article root) if currently in scripts/
if (basename(getwd()) == "scripts") {
  setwd("..")
  cat("Changed to article directory:", getwd(), "\n\n")
}

# Step 1: Check and install required packages
cat("Step 1: Checking required packages...\n")

required_packages <- c(
  "rjtools", "knitr", "rmarkdown",
  "dplyr", "ggplot2", "tidyr", "data.table", "stringr"
)

missing_packages <- required_packages[!sapply(required_packages, requireNamespace, quietly = TRUE)]

if (length(missing_packages) > 0) {
  cat("Installing missing packages:", paste(missing_packages, collapse = ", "), "\n")
  install.packages(missing_packages)
} else {
  cat("All required packages are installed.\n")
}

# Step 2: Check file existence
cat("\nStep 2: Checking required files...\n")

required_files <- c(
  "valdextractor.Rmd",
  "valdextractor.R",
  "references.bib",
  "cover_letter.txt",
  "_Rpackages.txt"
)

files_exist <- file.exists(required_files)

if (all(files_exist)) {
  cat("All required files present.\n")
} else {
  cat("ERROR: Missing files:\n")
  print(required_files[!files_exist])
  stop("Cannot proceed without all required files.")
}

# Step 3: Generate figures
cat("\nStep 3: Generating figures...\n")

if (file.exists("valdextractor.R")) {
  tryCatch({
    source("valdextractor.R")
    cat("Figures generated successfully.\n")
  }, error = function(e) {
    cat("Warning: Figure generation failed:", e$message, "\n")
    cat("Continuing with build...\n")
  })
} else {
  cat("Warning: valdextractor.R not found. Skipping figure generation.\n")
}

# Step 4: Build the article
cat("\nStep 4: Building article...\n")

# Build HTML version
cat("Building HTML version...\n")
tryCatch({
  rmarkdown::render(
    "valdextractor.Rmd",
    output_format = "rjtools::rjournal_web_article",
    quiet = FALSE
  )
  cat("HTML version created successfully.\n")
}, error = function(e) {
  cat("Warning: HTML build failed:", e$message, "\n")
})

# Build PDF version
cat("\nBuilding PDF version...\n")
tryCatch({
  rmarkdown::render(
    "valdextractor.Rmd",
    output_format = "rjtools::rjournal_pdf_article",
    quiet = FALSE
  )
  cat("PDF version created successfully.\n")
}, error = function(e) {
  cat("ERROR: PDF build failed:", e$message, "\n")
  cat("You may need to install TinyTeX:\n")
  cat("  install.packages('tinytex')\n")
  cat("  tinytex::install_tinytex()\n")
  stop("PDF build failed.")
})

# Step 5: Run validation checks
cat("\nStep 5: Running rjtools validation checks...\n")

if (requireNamespace("rjtools", quietly = TRUE)) {
  tryCatch({
    check_results <- rjtools::initial_check_article(getwd())
    cat("\nValidation checks completed.\n")
    print(check_results)
  }, error = function(e) {
    cat("Warning: Some checks failed:", e$message, "\n")
    cat("Review the output above for details.\n")
  })
} else {
  cat("Warning: rjtools not available for validation checks.\n")
}

# Step 6: Create submission ZIP
cat("\nStep 6: Creating submission ZIP file...\n")

submission_files <- c(
  "valdextractor.pdf",
  "valdextractor.Rmd",
  "valdextractor.R",
  "references.bib",
  "cover_letter.txt",
  "_Rpackages.txt",
  "BUILD_INSTRUCTIONS.md",
  "scripts/build_article.R",
  "figures/"
)

# Check which files exist
existing_files <- submission_files[file.exists(submission_files)]

if (length(existing_files) > 0) {
  zip_file <- "../valdextractor_RJournal_submission.zip"
  zip(zip_file, files = existing_files)
  cat("Submission ZIP created:", zip_file, "\n")
} else {
  cat("Warning: No files available for ZIP creation.\n")
}

# Step 7: Summary
cat("\n========================================\n")
cat("BUILD COMPLETE\n")
cat("========================================\n\n")

cat("Generated files:\n")
if (file.exists("valdextractor.html")) cat("  ✓ valdextractor.html\n")
if (file.exists("valdextractor.pdf")) cat("  ✓ valdextractor.pdf\n")
if (file.exists("RJwrapper.pdf")) cat("  ✓ RJwrapper.pdf\n")
if (dir.exists("figures")) {
  fig_files <- list.files("figures", pattern = "\\.pdf$")
  if (length(fig_files) > 0) {
    cat("  ✓ figures/ (", length(fig_files), " PDFs)\n", sep = "")
  }
}

cat("\nNext steps:\n")
cat("1. Review the generated PDF file\n")
cat("2. Submit via: https://journal.r-project.org/submit.html\n")
cat("3. Include the cover letter content in your submission\n")
cat("4. Upload the ZIP file or individual files as requested\n")

cat("\nFor questions:\n")
cat("  - Package: praveenmaths89@gmail.com\n")
cat("  - R Journal: r-journal@r-project.org\n")
cat("\n")
