# Quick Reference Card - R Journal Submission

## One-Command Build

```r
setwd("RJournal_submission")
source("scripts/build_article.R")
```

## Prerequisites (Run Once)

```r
install.packages(c("rjtools", "knitr", "rmarkdown", "tinytex"))
tinytex::install_tinytex()
```

## Files You'll Submit

- ✅ `valdextractor.pdf` (generated)
- ✅ `valdextractor.Rmd` (source)
- ✅ `references.bib` (bibliography)
- ✅ `cover_letter.txt` (motivation)
- ✅ `_Rpackages.txt` (dependencies)

## Submission URL

https://journal.r-project.org/submit.html

## Validation

```r
library(rjtools)
initial_check_article(getwd())
```

## Article Structure

1. Introduction (problem context)
2. Package Design (philosophy & architecture)
3. Typical Workflow (step-by-step usage)
4. Detailed Use Case (multi-sport scenario)
5. Technical Implementation (batch processing, taxonomy, suffix removal)
6. Comparison (manual vs automated)
7. Limitations & Future
8. Conclusion

## Key Contributions

- Fault-tolerant batch processing for API data
- Automated sports taxonomy classification
- Generic test-type programming patterns

## Page Count

16-18 pages (within 20-page limit ✓)

## Contact

- Authors: praveenmaths89@gmail.com, usha@som.iitb.ac.in
- R Journal: r-journal@r-project.org
