# Complete Submission Package for vald.extractor

This package is now ready for two submissions:

## 1. CRAN Submission (UPDATED)

Your CRAN feedback has been addressed:

### ✅ Fixed Issues:
- **Misspelled words**: Added single quotes around 'VALD' and 'ForceDecks' in DESCRIPTION Title and Description fields
- **Invalid URL**: Removed the non-existent pkgdown site URL from README.md

### Files Modified:
- `DESCRIPTION` - Title and Description now have properly quoted software names
- `README.md` - Replaced invalid pkgdown URL with GitHub repository link

### Next Steps for CRAN:
1. Test the package: `R CMD check --as-cran`
2. Build tarball: `R CMD build .`
3. Resubmit to CRAN with the fixed files

**Reply to Uwe Ligges:**
```
Dear Uwe Ligges,

Thank you for the feedback. I have addressed both issues:

1. Software names 'VALD' and 'ForceDecks' are now single-quoted in both
   Title and Description fields of the DESCRIPTION file.

2. The invalid pkgdown URL has been removed from README.md and replaced
   with the GitHub repository link.

The package is ready for resubmission.

Best regards,
Praveen D Chougale
```

---

## 2. R Journal Submission (NEW)

A complete R Journal article has been prepared in the `RJournal_submission/` directory.

### What's Included:

The `RJournal_submission/` folder contains:

```
RJournal_submission/
├── valdextractor.Rmd          # Main article (16-18 pages)
├── references.bib             # Bibliography
├── cover_letter.txt           # Submission cover letter
├── _Rpackages.txt             # Required packages
├── build_article.R            # Automated build script
├── BUILD_INSTRUCTIONS.md      # Detailed build guide
├── STEP_BY_STEP_GUIDE.md      # Simple step-by-step instructions
└── README.md                  # Submission overview
```

### Quick Start - Build the Article:

**Option 1: Automated (Recommended)**
```r
setwd("RJournal_submission")
source("scripts/build_article.R")
```

**Option 2: Manual**
```r
setwd("RJournal_submission")
library(rmarkdown)
render("valdextractor.Rmd", output_format = "rjtools::rjournal_pdf_article")
```

### Article Highlights:

The article focuses on software design and implementation:

1. **Fault-Tolerant Batch Processing** - Chunked API extraction preventing timeouts
2. **Automated Sports Taxonomy** - Regex-based classification reducing manual work
3. **Generic Test-Type Programming** - Code reuse across different test types
4. **Production-Ready Design** - Error handling, sensible defaults, comprehensive documentation

### Requirements Before Building:

```r
# Install required packages
install.packages(c(
  "rjtools", "knitr", "rmarkdown", "tinytex",
  "dplyr", "ggplot2", "tidyr", "data.table", "stringr"
))

# Install LaTeX
tinytex::install_tinytex()
```

### Submission Process:

1. Build the article (see Quick Start above)
2. Review the generated PDF
3. Submit at: https://journal.r-project.org/submit.html
4. Upload the files or ZIP package

**Detailed instructions are in `RJournal_submission/STEP_BY_STEP_GUIDE.md`**

---

## Timeline

### CRAN Resubmission:
- ✅ Issues fixed (today)
- 🔄 Resubmit to CRAN (do this today/tomorrow)
- ⏳ Wait for CRAN review (1-2 weeks)

### R Journal Submission:
- ✅ Article written (today)
- 🔄 Build and review PDF (when ready)
- 🔄 Submit to R Journal (after CRAN acceptance recommended)
- ⏳ Peer review process (2-4 months)

---

## Recommended Order

1. **First**: Resubmit to CRAN with the fixes
2. **Then**: Build and review the R Journal article
3. **Finally**: Submit to R Journal after CRAN acceptance

**Why this order?**
- R Journal requires packages to be on CRAN or Bioconductor
- Getting CRAN approval first strengthens your R Journal submission
- You can update the article with the final CRAN version number

---

## Need Help?

### For CRAN Submission:
- CRAN Repository Policy: https://cran.r-project.org/web/packages/policies.html
- Email: cran@r-project.org

### For R Journal Submission:
- Submission Guidelines: https://journal.r-project.org/submit.html
- Email: r-journal@r-project.org

### For Package Issues:
- Praveen D Chougale: praveenmaths89@gmail.com
- Usha Anathakumar: usha@som.iitb.ac.in

---

## Quick Command Reference

### CRAN Check
```bash
cd /path/to/vald.extractor
R CMD check --as-cran .
R CMD build .
```

### R Journal Build
```r
setwd("RJournal_submission")
source("scripts/build_article.R")
```

### View Generated PDF
```r
browseURL("RJournal_submission/valdextractor.pdf")
```

---

**You're all set! Both submissions are ready to go. Good luck! 🎉**
