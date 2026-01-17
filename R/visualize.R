#' Generate Summary Statistics for VALD Metrics
#'
#' @title Dynamic Summary Table for Performance Metrics
#'
#' @description
#' Creates a comprehensive summary table showing mean, standard deviation,
#' coefficient of variation, and sample size for all numeric performance metrics.
#' Can be grouped by test type, sex, sport, or any combination thereof.
#'
#' @param data Data frame. Test data (typically from \code{split_by_test()}).
#' @param group_vars Character vector. Variables to group by. Default is
#'   c("sex", "sports").
#' @param exclude_cols Character vector. Column names to exclude from summary
#'   (typically metadata columns). Default includes common ID and date fields.
#' @param digits Integer. Number of decimal places for rounding. Default is 2.
#'
#' @return Data frame with summary statistics (Mean, SD, CV, N) for each metric
#'   and grouping combination.
#'
#' @export
#'
#' @importFrom dplyr group_by summarise across where
#' @importFrom dplyr %>%
#' @importFrom stats sd
#'
#' @examples
#' \donttest{
#' if (FALSE) {
#'   test_datasets <- split_by_test(final_analysis_data)
#'   cmj_summary <- summary_vald_metrics(
#'     data = test_datasets$CMJ,
#'     group_vars = c("sex", "sports")
#'   )
#'   print(cmj_summary)
#' }
#' }
summary_vald_metrics <- function(data, group_vars = c("sex", "sports"),
                                 exclude_cols = c("profileId", "athleteId", "testId",
                                                 "Testdate", "dateofbirth", "age",
                                                 "Weight_on_Test_Day"),
                                 digits = 2) {

  group_vars <- intersect(group_vars, names(data))

  if (length(group_vars) == 0) {
    stop("None of the specified group_vars exist in data")
  }

  numeric_cols <- names(data)[sapply(data, is.numeric)]
  metric_cols <- setdiff(numeric_cols, exclude_cols)

  if (length(metric_cols) == 0) {
    stop("No numeric metric columns found after exclusions")
  }

  summary_df <- data %>%
    dplyr::group_by(dplyr::across(dplyr::all_of(group_vars))) %>%
    dplyr::summarise(
      dplyr::across(
        dplyr::all_of(metric_cols),
        list(
          Mean = ~ round(mean(.x, na.rm = TRUE), digits),
          SD = ~ round(stats::sd(.x, na.rm = TRUE), digits),
          CV = ~ round(stats::sd(.x, na.rm = TRUE) / mean(.x, na.rm = TRUE) * 100, digits),
          N = ~ sum(!is.na(.x))
        ),
        .names = "{.col}_{.fn}"
      ),
      .groups = "drop"
    )

  return(summary_df)
}


#' Plot Longitudinal Trends for VALD Metrics
#'
#' @title Time-Series Visualization of Performance Metrics
#'
#' @description
#' Creates professional line plots showing how performance metrics change over
#' time for individual athletes or groups. Useful for tracking training
#' adaptations, injury recovery, and seasonal trends.
#'
#' @param data Data frame. Test data with a date column and at least one metric.
#' @param date_col Character. Name of the date column. Default is "Testdate".
#' @param metric_col Character. Name of the metric to plot.
#' @param group_col Character. Optional grouping variable (e.g., "profileId",
#'   "sports"). If provided, separate lines are drawn for each group.
#' @param facet_col Character. Optional faceting variable (e.g., "sex").
#'   Creates separate panels for each level.
#' @param title Character. Plot title. If NULL, auto-generates from metric name.
#' @param smooth Logical. If TRUE, adds a smoothed trend line. Default is FALSE.
#'
#' @return A ggplot2 object.
#'
#' @export
#'
#' @importFrom ggplot2 ggplot aes geom_line geom_point labs theme_minimal theme element_text facet_wrap
#' @importFrom dplyr filter
#' @importFrom dplyr %>%
#'
#' @examples
#' \donttest{
#' if (FALSE) {
#'   test_datasets <- split_by_test(final_analysis_data)
#'
#'   # Plot individual athlete trends
#'   plot_vald_trends(
#'     data = test_datasets$CMJ,
#'     metric_col = "PEAK_FORCE_Both",
#'     group_col = "profileId",
#'     facet_col = "sex"
#'   )
#'
#'   # Plot sport-level averages
#'   sport_avg <- test_datasets$CMJ %>%
#'     group_by(Testdate, sports) %>%
#'     summarise(avg_force = mean(PEAK_FORCE_Both, na.rm = TRUE))
#'
#'   plot_vald_trends(
#'     data = sport_avg,
#'     date_col = "Testdate",
#'     metric_col = "avg_force",
#'     group_col = "sports"
#'   )
#' }
#' }
plot_vald_trends <- function(data, date_col = "Testdate", metric_col,
                            group_col = NULL, facet_col = NULL,
                            title = NULL, smooth = FALSE) {

  if (!date_col %in% names(data)) {
    stop("Date column '", date_col, "' not found in data")
  }
  if (!metric_col %in% names(data)) {
    stop("Metric column '", metric_col, "' not found in data")
  }

  data <- data %>%
    dplyr::filter(!is.na(.data[[metric_col]]))

  if (nrow(data) == 0) {
    stop("No non-missing data for metric: ", metric_col)
  }

  if (is.null(title)) {
    title <- paste("Trends in", metric_col)
  }

  p <- ggplot2::ggplot(
    data,
    ggplot2::aes(x = .data[[date_col]], y = .data[[metric_col]])
  )

  if (!is.null(group_col)) {
    p <- p + ggplot2::geom_line(ggplot2::aes(group = .data[[group_col]], color = .data[[group_col]]), alpha = 0.6)
    p <- p + ggplot2::geom_point(ggplot2::aes(color = .data[[group_col]]), size = 1.5, alpha = 0.7)
  } else {
    p <- p + ggplot2::geom_line(color = "#2c3e50", size = 1)
    p <- p + ggplot2::geom_point(color = "#2c3e50", size = 2)
  }

  if (smooth) {
    p <- p + ggplot2::geom_smooth(method = "loess", se = TRUE, color = "#e74c3c")
  }

  if (!is.null(facet_col)) {
    p <- p + ggplot2::facet_wrap(stats::as.formula(paste("~", facet_col)), scales = "free_y")
  }

  p <- p +
    ggplot2::labs(
      title = title,
      x = "Date",
      y = metric_col,
      color = if (!is.null(group_col)) group_col else NULL
    ) +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      plot.title = ggplot2::element_text(size = 14, face = "bold"),
      axis.title = ggplot2::element_text(size = 11),
      legend.position = "bottom"
    )

  return(p)
}


#' Compare Performance Across Groups
#'
#' @title Boxplot Comparison of Metrics by Sport, Sex, or Team
#'
#' @description
#' Creates boxplots to compare performance metrics across different groups
#' (e.g., sports, sex, teams). Useful for benchmarking and identifying
#' performance differences between populations.
#'
#' @param data Data frame. Test data with grouping variables and metrics.
#' @param metric_col Character. Name of the metric to plot.
#' @param group_col Character. Primary grouping variable (x-axis).
#'   Default is "sports".
#' @param fill_col Character. Optional fill color grouping (e.g., "sex").
#'   Default is "sex".
#' @param title Character. Plot title. If NULL, auto-generates from metric name.
#' @param y_label Character. Y-axis label. If NULL, uses metric_col.
#'
#' @return A ggplot2 object.
#'
#' @export
#'
#' @importFrom ggplot2 ggplot aes geom_boxplot labs theme_minimal theme element_text
#' @importFrom dplyr filter
#' @importFrom dplyr %>%
#'
#' @examples
#' \donttest{
#' if (FALSE) {
#'   test_datasets <- split_by_test(final_analysis_data)
#'
#'   # Compare CMJ peak force across sports and sex
#'   plot_vald_compare(
#'     data = test_datasets$CMJ,
#'     metric_col = "PEAK_FORCE_Both",
#'     group_col = "sports",
#'     fill_col = "sex",
#'     title = "Peak Force Comparison by Sport and Sex"
#'   )
#' }
#' }
plot_vald_compare <- function(data, metric_col, group_col = "sports",
                             fill_col = "sex", title = NULL, y_label = NULL) {

  if (!metric_col %in% names(data)) {
    stop("Metric column '", metric_col, "' not found in data")
  }
  if (!group_col %in% names(data)) {
    stop("Group column '", group_col, "' not found in data")
  }

  data <- data %>%
    dplyr::filter(!is.na(.data[[metric_col]]))

  if (nrow(data) == 0) {
    stop("No non-missing data for metric: ", metric_col)
  }

  if (is.null(title)) {
    title <- paste(metric_col, "by", group_col)
  }
  if (is.null(y_label)) {
    y_label <- metric_col
  }

  if (!is.null(fill_col) && fill_col %in% names(data)) {
    p <- ggplot2::ggplot(
      data,
      ggplot2::aes(x = .data[[group_col]], y = .data[[metric_col]], fill = .data[[fill_col]])
    ) +
      ggplot2::geom_boxplot(alpha = 0.7)
  } else {
    p <- ggplot2::ggplot(
      data,
      ggplot2::aes(x = .data[[group_col]], y = .data[[metric_col]])
    ) +
      ggplot2::geom_boxplot(fill = "#3498db", alpha = 0.7)
  }

  p <- p +
    ggplot2::labs(
      title = title,
      x = group_col,
      y = y_label,
      fill = fill_col
    ) +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      plot.title = ggplot2::element_text(size = 14, face = "bold"),
      axis.title = ggplot2::element_text(size = 11),
      axis.text.x = ggplot2::element_text(angle = 45, hjust = 1),
      legend.position = "bottom"
    )

  return(p)
}
