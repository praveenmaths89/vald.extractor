# R Journal Submission Build Instructions

This directory contains all files needed to build and submit the R Journal article for the vald.extractor package.

## Prerequisites

Before building the article, ensure you have R installed with the following packages:

```r
install.packages(c(
  "rjtools",    # R Journal article template
  "knitr",      # Document generation
  "rmarkdown",  # R Markdown processing
  "dplyr",      # Data manipulation
  "ggplot2",    # Visualization
  "tidyr",      # Data tidying
  "data.table", # Fast data operations
  "stringr"     # String operations
))
```

## Files Included

- `valdextractor.Rmd` - Main article source (R Markdown format)
- `valdextractor.R` - Figure generation script with simulated data
- `references.bib` - Bibliography file with citations
- `cover_letter.txt` - Cover letter for submission
- `_Rpackages.txt` - List of required packages
- `BUILD_INSTRUCTIONS.md` - This file
- `scripts/build_article.R` - Automated build script
- `figures/` - Directory containing generated PDF figures (created during build)

## Building the Article

### Method 1: Automated Build (Recommended)

Run the automated build script in R:

```r
source("scripts/build_article.R")
```

This script will:
1. Install required packages if missing
2. Check that all files are present
3. Generate figures using simulated data (runs valdextractor.R)
4. Build the PDF and HTML versions
5. Run rjtools validation checks
6. Create a submission-ready ZIP file

**Note**: All figures use simulated data (`set.seed(42)`) to ensure reproducibility and protect privacy.

### Method 2: Manual Build

If you prefer to build manually:

```r
library(rmarkdown)

# Build HTML version
rmarkdown::render("valdextractor.Rmd", output_format = "rjtools::rjournal_web_article")

# Build PDF version
rmarkdown::render("valdextractor.Rmd", output_format = "rjtools::rjournal_pdf_article")
```

## Validation

Before submitting, run the rjtools validation checks:

```r
library(rjtools)

# Run all checks
initial_check_article(getwd())

# Or run individual checks
check_filenames(getwd())
check_title(getwd())
check_section(getwd())
check_spelling(getwd())
```

## Expected Output

After successful build, you should have:

- `valdextractor.html` - Web version of the article
- `valdextractor.pdf` - PDF version for submission
- `RJwrapper.tex` - LaTeX wrapper (auto-generated)
- `RJwrapper.pdf` - Final submission PDF

## Submitting to R Journal

1. Review the generated PDF to ensure all content is correct

2. Create a ZIP file containing:
   - valdextractor.pdf (or RJwrapper.pdf)
   - valdextractor.Rmd (source file)
   - references.bib
   - cover_letter.txt
   - _Rpackages.txt
   - Any supporting R scripts

3. Submit via the R Journal submission form:
   https://journal.r-project.org/submit.html

4. In the submission form, provide:
   - Article title
   - Authors and contact information
   - Abstract (from the YAML header)
   - Paste the cover letter content

## Troubleshooting

### Issue: rjtools not found
**Solution**: Install rjtools: `install.packages("rjtools")`

### Issue: LaTeX compilation errors
**Solution**: Ensure you have a LaTeX distribution installed (TinyTeX recommended):
```r
install.packages("tinytex")
tinytex::install_tinytex()
```

### Issue: Missing bibliography entries
**Solution**: Ensure all citations in the .Rmd file have corresponding entries in references.bib

### Issue: Code chunks fail to execute
**Solution**: This article uses `eval=FALSE` for code examples since they require VALD API credentials. This is intentional and acceptable for R Journal submissions demonstrating package workflows.

## Contact

For questions about the submission:
- Praveen D Chougale: praveenmaths89@gmail.com
- Usha Anathakumar: usha@som.iitb.ac.in

For questions about R Journal submission process:
- R Journal Editor: r-journal@r-project.org
- R Journal website: https://journal.r-project.org/
