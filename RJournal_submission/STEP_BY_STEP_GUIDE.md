# Step-by-Step Guide to Building and Submitting Your R Journal Article

Follow these steps exactly to build your article and submit it to The R Journal.

---

## STEP 1: Install Required Packages

Open R or RStudio and run:

```r
# Install essential packages
install.packages(c(
  "rjtools",    # R Journal template
  "knitr",      # For knitting documents
  "rmarkdown",  # For R Markdown
  "tinytex"     # For PDF generation
))

# Install TinyTeX (LaTeX distribution)
tinytex::install_tinytex()

# Install package dependencies
install.packages(c(
  "dplyr",
  "ggplot2",
  "tidyr",
  "data.table",
  "stringr",
  "lubridate",
  "readxl",
  "httr",
  "jsonlite"
))
```

**Wait for all installations to complete before proceeding.**

---

## STEP 2: Navigate to Submission Directory

In R or RStudio:

```r
# Set working directory to the submission folder
setwd("path/to/vald.extractor/RJournal_submission")

# Verify you're in the right place
list.files()
# You should see: valdextractor.Rmd, references.bib, build_article.R, etc.
```

---

## STEP 3: Build the Article (Automated)

Run the automated build script:

```r
source("scripts/build_article.R")
```

This script will:
- ✓ Check all required packages
- ✓ Verify all files are present
- ✓ Build HTML version
- ✓ Build PDF version
- ✓ Run validation checks
- ✓ Create submission ZIP file

**Expected output:**
- `valdextractor.pdf` - Your submission PDF
- `valdextractor.html` - Web version
- `valdextractor_RJournal_submission.zip` - Complete submission package

---

## STEP 4: Review the Generated PDF

Open the PDF and verify:

```r
# Open the PDF for review
system("open valdextractor.pdf")  # Mac
# OR
system("start valdextractor.pdf") # Windows
# OR
browseURL("valdextractor.pdf")    # Cross-platform
```

**Check for:**
- [ ] Title and authors are correct
- [ ] All sections are present and well-formatted
- [ ] Code examples render properly
- [ ] References appear at the end
- [ ] No LaTeX errors or warnings in the output

---

## STEP 5: Alternative - Build Manually (If Automated Build Fails)

If the automated build script has issues, build manually:

```r
library(rmarkdown)

# Build PDF version
render(
  "valdextractor.Rmd",
  output_format = "rjtools::rjournal_pdf_article"
)

# Build HTML version
render(
  "valdextractor.Rmd",
  output_format = "rjtools::rjournal_web_article"
)
```

---

## STEP 6: Run Validation Checks

Before submitting, run quality checks:

```r
library(rjtools)

# Run all checks
results <- initial_check_article(getwd())
print(results)

# Review any warnings or errors
# Common issues:
# - Spelling: Add technical terms to personal dictionary
# - Package availability: Ensure vald.extractor is on CRAN
# - File naming: Ensure files follow conventions
```

---

## STEP 7: Create Submission Package

If the automated script didn't create the ZIP:

```r
# List of files to include
submission_files <- c(
  "valdextractor.pdf",      # Main PDF
  "valdextractor.Rmd",      # Source file
  "references.bib",         # Bibliography
  "cover_letter.txt",       # Cover letter
  "_Rpackages.txt",         # Package list
  "BUILD_INSTRUCTIONS.md",  # Build guide
  "scripts/build_article.R" # Build script
)

# Create ZIP file
zip(
  zipfile = "../valdextractor_RJournal_submission.zip",
  files = submission_files
)
```

---

## STEP 8: Submit to The R Journal

### 8.1: Go to Submission Portal

Visit: https://journal.r-project.org/submit.html

### 8.2: Complete Submission Form

Fill in the form with:

- **Article Title**: "vald.extractor: A Robust Pipeline for VALD ForceDecks Data Extraction and Analysis"

- **Authors**:
  - Praveen D Chougale (praveenmaths89@gmail.com)
  - Usha Anathakumar (usha@som.iitb.ac.in)

- **Abstract** (copy from cover letter or Rmd YAML):
  ```
  Sports organizations using VALD ForceDecks systems face challenges in
  extracting large datasets from APIs, standardizing inconsistent metadata
  across teams, and maintaining code reusability across different test types.
  The vald.extractor package addresses these challenges through fault-tolerant
  batch processing, automated sports taxonomy classification, and generic
  programming patterns that enable analysis code to work across multiple test
  types without modification...
  ```

- **Keywords**: R package, sports science, force plate, data pipeline, batch processing

- **Cover Letter**: Copy the content from `cover_letter.txt`

### 8.3: Upload Files

Upload the ZIP file OR upload individual files:
- valdextractor.pdf
- valdextractor.Rmd
- references.bib
- cover_letter.txt
- _Rpackages.txt

### 8.4: Submit

Click "Submit" and wait for confirmation email.

---

## STEP 9: After Submission

### What to Expect

1. **Immediate**: You'll receive an email confirming receipt
2. **1-2 weeks**: Editorial board reviews for technical format
3. **2-4 months**: Peer review process
4. **After review**: One of four verdicts:
   - Accepted
   - Minor revisions
   - Major revisions
   - Reject

### Responding to Reviewers

If you receive "Minor revisions" or "Major revisions":

1. Read all reviewer comments carefully
2. Make requested changes to `valdextractor.Rmd`
3. Rebuild the article: `source("scripts/build_article.R")`
4. Write a point-by-point response letter
5. Resubmit via the same portal (use your original submission ID)

---

## Troubleshooting Common Issues

### Issue 1: "rjtools not found"
```r
install.packages("rjtools")
```

### Issue 2: "LaTeX Error" or "pdflatex not found"
```r
install.packages("tinytex")
tinytex::install_tinytex()
```

### Issue 3: "Object not found" errors in code chunks
This is expected! Code chunks use `eval=FALSE` because they require VALD API credentials. The R Journal accepts this for package demonstration papers.

### Issue 4: Bibliography not rendering
Check that all citations in the Rmd have entries in references.bib:
```r
# Find all citations in Rmd
readLines("valdextractor.Rmd") |>
  grep("@\\w+", x = _, value = TRUE)

# Compare to entries in references.bib
readLines("references.bib") |>
  grep("^@", x = _, value = TRUE)
```

### Issue 5: "File size too large" on submission
The article should be ~2-3 MB. If larger, check for embedded images and compress them.

---

## Additional Resources

- **R Journal Submission Guidelines**: https://journal.r-project.org/submit.html
- **R Journal Author Guide**: https://journal.r-project.org/
- **rjtools Documentation**: https://rjournal.github.io/rjtools/
- **TinyTeX Help**: https://yihui.org/tinytex/

---

## Contact for Help

**Package Authors:**
- Praveen D Chougale: praveenmaths89@gmail.com
- Usha Anathakumar: usha@som.iitb.ac.in

**R Journal Editors:**
- Email: r-journal@r-project.org

---

## Success Criteria

You're ready to submit when:
- [x] Article builds to PDF without errors
- [x] All validation checks pass (or only minor warnings)
- [x] PDF is < 20 pages
- [x] References are complete
- [x] Cover letter is compelling
- [x] Package is on CRAN
- [x] All code is reproducible (or explicitly marked `eval=FALSE` with explanation)

**Good luck with your submission!**
