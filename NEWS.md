# vald.extractor 0.1.1

## Metadata Fix

* Corrected spelling of author name in package metadata.

# vald.extractor 0.1.0

## Initial Release

First CRAN submission of vald.extractor package.

### Core Features

* **Fault-Tolerant Data Extraction**
  - `fetch_vald_batch()`: Chunked trial extraction with configurable batch sizes
  - Automatic error logging without halting entire extraction
  - Support for large datasets (5000+ tests)

* **Metadata Management**
  - `fetch_vald_metadata()`: OAuth2 authentication for profiles and groups
  - `standardize_vald_metadata()`: Unnest group memberships and create unified athlete records
  - `classify_sports()`: Automated sports taxonomy with 15+ sport patterns
  - `patch_metadata()`: Import corrections from Excel/CSV files

* **Data Transformation**
  - `split_by_test()`: Split wide-format data by test type with suffix removal
  - Generic programming support for DRY analysis code
  - Automatic handling of multiple test types (CMJ, DJ, ISO, etc.)

* **Analysis & Visualization**
  - `summary_vald_metrics()`: Generate grouped summary statistics
  - `plot_vald_trends()`: Longitudinal trend visualization
  - `plot_vald_compare()`: Cross-sectional group comparisons
  - Professional ggplot2 themes

### Documentation

* Comprehensive vignette: "End-to-End Pipeline: From API to Multi-Sport Analysis"
* Complete roxygen2 documentation for all exported functions
* Detailed README with use cases and comparison to manual workflow

### Package Infrastructure

* CRAN-compliant DESCRIPTION with proper dependencies
* MIT license
* .Rbuildignore and .gitignore configurations
* Modular code structure (fetch.R, metadata.R, transform.R, visualize.R, utils.R)
