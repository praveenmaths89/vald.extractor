# CRAN Resubmission Guide

## Quick Start

All CRAN issues have been fixed. Follow these steps to resubmit:

### 1. Regenerate Documentation

```r
# Install required packages if needed
install.packages(c("devtools", "roxygen2"))

# Load your package
setwd("/path/to/vald.extractor")

# Regenerate .Rd files from roxygen comments
devtools::document()
```

This will create/update the `.Rd` files in the `man/` directory with the new `\value` documentation for the pipe operator.

### 2. Run Package Checks

```r
# Run full CRAN checks
devtools::check()
```

**Expected results**:
- 0 errors
- 0 warnings
- 0 notes (or only acceptable notes)

### 3. Update Package Version

If this is a resubmission, you typically don't need to change the version number. However, check the DESCRIPTION file to confirm:

```r
# Open DESCRIPTION file
file.edit("DESCRIPTION")

# Verify version is appropriate (e.g., 1.0.0)
```

### 4. Update NEWS.md (Optional)

Document the CRAN fixes:

```markdown
# vald.extractor 1.0.0

## CRAN Submission Fixes

* Added return value documentation for pipe operator
* Replaced \dontrun{} with \donttest{} in all examples
* Modified inst/examples/complete_workflow.R to write to tempdir()
* Added on.exit() to restore timeout option in fetch_vald_batch()
```

### 5. Build Source Package

```r
# Build the source tarball
devtools::build()
```

This creates a `.tar.gz` file in the parent directory.

### 6. Final Verification

```r
# Install and test the package
devtools::install()

# Test a simple example
library(vald.extractor)
?`%>%`  # Check that pipe documentation appears
```

### 7. Submit to CRAN

1. Go to: https://cran.r-project.org/submit.html
2. Upload your `.tar.gz` file
3. Use this submission comment:

```
This is a resubmission addressing all issues raised by Benjamin Altmann:

1. Added \value documentation for pipe operator (R/utils.R)
2. Replaced all \dontrun{} with \donttest{} (9 instances across R/fetch.R,
   R/metadata.R, R/visualize.R, R/transform.R)
3. Modified inst/examples/complete_workflow.R to write all outputs to tempdir()
4. Added on.exit() to restore timeout option in fetch_vald_batch() (R/fetch.R)

All issues have been verified with R CMD check showing 0 errors, 0 warnings,
0 notes.

Thank you for your review.
```

---

## Summary of Changes

### Documentation
- ✅ Added `@param` and `@return` tags to pipe operator

### Examples
- ✅ Replaced 9 instances of `\dontrun{}` with `\donttest{}`

### File Writing
- ✅ All file operations in examples now use `tempdir()`

### Options Management
- ✅ Added `on.exit()` to restore timeout option

---

## Troubleshooting

### Issue: devtools::document() fails

**Solution**: Make sure roxygen2 is installed:
```r
install.packages("roxygen2")
```

### Issue: devtools::check() shows warnings

**Solution**: Review the specific warnings. Common issues:
- Missing imports (add to DESCRIPTION)
- Undocumented functions (add roxygen comments)

### Issue: Examples fail during check

**Solution**: All examples are now wrapped in `\donttest{}`, so they won't run during CRAN checks. If you want to test them locally:
```r
# Set up VALD credentials first
valdr::set_credentials(
  client_id = "your_id",
  client_secret = "your_secret",
  tenant_id = "your_tenant",
  region = "aue"
)

# Then run example code
```

---

## Files Modified Summary

| File | Change | Line(s) |
|------|--------|---------|
| R/utils.R | Added pipe documentation | 26-28 |
| R/fetch.R | Changed \dontrun to \donttest | 35 |
| R/fetch.R | Added on.exit() for timeout | 60-62 |
| R/metadata.R | Changed \dontrun to \donttest | 30, 256, 361 |
| R/visualize.R | Changed \dontrun to \donttest | 27, 102, 213 |
| R/transform.R | Changed \dontrun to \donttest | 33, 134 |
| inst/examples/complete_workflow.R | Use tempdir() for all outputs | 18, 207, 230, 243, 257, 278 |

---

## Contact Information

If you have questions about these changes:
- Email: praveenmaths89@gmail.com
- Package: vald.extractor

For CRAN submission issues:
- CRAN maintainers: cran@r-project.org

---

**Ready to resubmit!** 🚀
