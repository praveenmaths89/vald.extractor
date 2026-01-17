# CRAN Submission Issues - Fixed

This document summarizes all fixes applied in response to CRAN feedback from Benjamin Altmann.

## Date: January 17, 2026

---

## Issues Reported by CRAN

### 1. Missing \value Tags in .Rd Files ✅ FIXED

**Issue**: Missing documentation for the `pipe.Rd` file explaining what the function returns.

**Fix Applied**:
- Added `@param` and `@return` documentation to the pipe operator in `R/utils.R` (lines 26-28)
- Documentation now includes:
  - `@param lhs` - A value or the magrittr placeholder
  - `@param rhs` - A function call using the magrittr semantics
  - `@return` - The result of calling `rhs(lhs)`

**Files Modified**: `R/utils.R`

---

### 2. Inappropriate Use of \dontrun{} ✅ FIXED

**Issue**: Examples wrapped in `\dontrun{}` should use `\donttest{}` instead, as the examples can be executed (they just require API credentials).

**Fix Applied**:
Replaced all 9 instances of `\dontrun{}` with `\donttest{}` in the following files:

1. `R/fetch.R` - Line 35 (fetch_vald_batch example)
2. `R/metadata.R` - Line 30 (fetch_vald_metadata example)
3. `R/metadata.R` - Line 256 (standardize_vald_metadata example)
4. `R/metadata.R` - Line 361 (classify_sports example)
5. `R/visualize.R` - Line 27 (summary_vald_metrics example)
6. `R/visualize.R` - Line 102 (plot_vald_trends example)
7. `R/visualize.R` - Line 213 (plot_vald_compare example)
8. `R/transform.R` - Line 33 (split_by_test example)
9. `R/transform.R` - Line 134 (patch_metadata example)

**Rationale**: These examples require VALD API credentials but are otherwise executable, so `\donttest{}` is more appropriate than `\dontrun{}`.

**Files Modified**: `R/fetch.R`, `R/metadata.R`, `R/visualize.R`, `R/transform.R`

---

### 3. Writing to User's Home Filespace ✅ FIXED

**Issue**: The file `inst/examples/complete_workflow.R` writes files to the user's working directory, which violates CRAN policies.

**Fix Applied**:
- Added `output_dir <- tempdir()` at the beginning of the script (line 18)
- Modified all file write operations to use `file.path(output_dir, filename)`:
  1. Line 207: `write.csv()` now writes to tempdir
  2. Line 230: `ggsave()` for trends plot now writes to tempdir
  3. Line 243: `ggsave()` for comparison plot now writes to tempdir
  4. Line 257: `ggsave()` for jump height plot now writes to tempdir
  5. Line 278: `save()` for workspace now writes to tempdir
- Added user-friendly messages showing where files are saved

**Files Modified**: `inst/examples/complete_workflow.R`

---

### 4. Changing User's Options Without on.exit() ✅ FIXED

**Issue**: The function `fetch_vald_batch()` in `R/fetch.R` sets `options(timeout = 18000)` without using `on.exit()` to restore the original value.

**Fix Applied**:
- Lines 60-62 in `R/fetch.R`:
  ```r
  old_timeout <- getOption("timeout")
  on.exit(options(timeout = old_timeout), add = TRUE)
  options(timeout = 18000)
  ```
- This ensures the timeout option is restored even if the function exits with an error

**Files Modified**: `R/fetch.R`

---

## Additional Checks Performed

### No Other Option/Par/Working Directory Changes
- Searched all R files for `options()`, `par()`, and `setwd()` calls
- Only found the timeout option change, which is now properly handled with `on.exit()`
- ✅ No other violations found

### No File Writing in Core R Functions
- Verified that no core R functions write files
- All file operations are in examples/vignettes
- ✅ Compliant

### Test Files Compliance
- `tests/testthat/test-utils.R` properly uses `tempfile()` for test data
- Cleanup is performed with `unlink()` after tests
- ✅ Compliant

### Vignette Compliance
- `vignettes/end-to-end-pipeline.Rmd` has `eval = FALSE` in setup
- File write operations in vignette are never executed during build
- ✅ Compliant

---

## Summary of Files Modified

1. **R/utils.R**
   - Added `@return` documentation for pipe operator

2. **R/fetch.R**
   - Changed `\dontrun{}` to `\donttest{}`
   - Added `on.exit()` for timeout option restoration

3. **R/metadata.R**
   - Changed 3 instances of `\dontrun{}` to `\donttest{}`

4. **R/visualize.R**
   - Changed 3 instances of `\dontrun{}` to `\donttest{}`

5. **R/transform.R**
   - Changed 2 instances of `\dontrun{}` to `\donttest{}`

6. **inst/examples/complete_workflow.R**
   - Added `output_dir <- tempdir()` setup
   - Modified 5 file write operations to use tempdir()

---

## Verification Steps

Before resubmitting to CRAN:

1. ✅ Run `devtools::document()` to regenerate .Rd files
2. ✅ Run `devtools::check()` to verify no new issues
3. ✅ Verify all examples run with `\donttest{}` properly
4. ✅ Test that complete_workflow.R writes to tempdir()
5. ✅ Confirm no files are written to user directories during check

---

## Response to CRAN Reviewer

Dear Benjamin Altmann,

Thank you for your detailed review. I have addressed all four issues:

1. **\value tags**: Added return value documentation for the pipe operator
2. **\dontrun{}**: Replaced all 9 instances with `\donttest{}` as examples are executable with API credentials
3. **File writing**: Modified `inst/examples/complete_workflow.R` to write all outputs to `tempdir()`
4. **Options restoration**: Added `on.exit()` to restore timeout option in `fetch_vald_batch()`

All changes have been tested with `R CMD check` and no new issues were found.

Best regards,
Praveen D. Chougale

---

## CRAN Resubmission Checklist

- [x] Fixed all documentation issues
- [x] Replaced `\dontrun{}` with `\donttest{}`
- [x] File writing now uses `tempdir()`
- [x] Options are restored with `on.exit()`
- [x] Verified with `devtools::check()`
- [ ] Update DESCRIPTION version number
- [ ] Update NEWS.md with changes
- [ ] Resubmit to CRAN

---

**Status**: ✅ ALL ISSUES RESOLVED - READY FOR RESUBMISSION
