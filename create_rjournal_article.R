# Script to create R Journal article for vald.extractor package
# Run this script to generate the article structure

# Install rjtools if not already installed
if (!requireNamespace("rjtools", quietly = TRUE)) {
  install.packages("rjtools")
}

library(rjtools)

# Create article in a new directory
article_dir <- "RJournal_submission"

# Create the article structure
rjtools::create_article(
  path = article_dir,
  edit = FALSE
)

message("Article structure created in: ", article_dir)
message("Next steps:")
message("1. Edit the .Rmd file in the ", article_dir, " directory")
message("2. Knit the Rmd to generate PDF")
message("3. Run rjtools::initial_check_article('", article_dir, "')")
