#' @keywords internal
"_PACKAGE"

#' vald.extractor: Robust Pipeline for VALD ForceDecks Data Extraction and Analysis
#'
#' @name vald.extractor-package
#' @aliases vald.extractor
#' @description
#' The vald.extractor package extends the valdr package by providing a
#' fault-tolerant, production-ready pipeline for extracting, cleaning, and
#' visualizing VALD ForceDecks data across multiple sports. It implements
#' chunked batch processing to prevent timeout errors, OAuth2 authentication
#' for metadata enrichment, and automated sports taxonomy mapping.
#'
#' @section Main Functions:
#'
#' **Data Extraction:**
#' \itemize{
#'   \item \code{\link{fetch_vald_batch}}: Chunked trial extraction with fault tolerance
#'   \item \code{\link{fetch_vald_metadata}}: OAuth2 authentication for profiles and groups
#' }
#'
#' **Data Cleaning:**
#' \itemize{
#'   \item \code{\link{standardize_vald_metadata}}: Unnest groups and create unified athlete records
#'   \item \code{\link{classify_sports}}: Automated sports taxonomy mapping
#'   \item \code{\link{patch_metadata}}: Fix missing demographics from external files
#' }
#'
#' **Data Transformation:**
#' \itemize{
#'   \item \code{\link{split_by_test}}: Split by test type with suffix removal
#' }
#'
#' **Analysis & Visualization:**
#' \itemize{
#'   \item \code{\link{summary_vald_metrics}}: Generate summary statistics
#'   \item \code{\link{plot_vald_trends}}: Longitudinal trend visualization
#'   \item \code{\link{plot_vald_compare}}: Cross-sectional group comparisons
#' }
#'
#' @section Key Features:
#' \itemize{
#'   \item Fault-tolerant chunked extraction prevents API timeout errors
#'   \item Automated sports classification saves hours of manual categorization
#'   \item Generic programming with suffix removal enables DRY analysis code
#'   \item Publication-ready visualizations with professional themes
#' }
NULL
