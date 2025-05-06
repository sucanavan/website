#!/usr/bin/env Rscript

# scripts/update_publications.R
# Combine ORCID metadata + Google Scholar citation counts

library(scholar)
library(rorcid)
library(stringdist)
library(readr)
library(dplyr)

# ---- Parameters ----
gs_id     <- "YzHpPVgAAAAJ"
orcid_id  <- "0000-0002-7972-7928"
out_file  <- "publications.csv"

# ---- 1. Google Scholar ----
gs_pubs <- get_publications(gs_id)

# ---- 2. ORCID metadata ----
orcid_data <- orcid_works(orcid_id)
orcid_pubs <- orcid_data[[1]]$works

orcid_titles <- tolower(orcid_pubs$title.title.value)
gs_titles    <- tolower(gs_pubs$title)

# ---- 3. Fuzzy match ----
matches <- sapply(orcid_titles, function(orcid_title) {
  dists <- stringdist(orcid_title, gs_titles, method = "jw")
  best  <- which.min(dists)
  if (min(dists) < 0.2) best else NA
})

# ---- 4. Merge ----
merged_df <- data.frame(
  Title   = orcid_pubs$title.title.value,
  Year    = orcid_pubs$`publication-date.year.value`,
  Type    = orcid_pubs$type,
  Journal = orcid_pubs$`journal-title.value`,
  Authors = ifelse(!is.na(matches), gs_pubs$author[matches], NA),  # may contain "..."
  Citations = ifelse(!is.na(matches), gs_pubs$cites[matches], NA),
  stringsAsFactors = FALSE
)

# ---- 5. Manual cleanup ----
merged_df <- merged_df[!(merged_df$Year == 2016 & grepl("bamboo", merged_df$Title, ignore.case = TRUE)), ]
merged_df <- merged_df[!grepl("Correction:", merged_df$Title), ]
merged_df <- merged_df[!grepl("^\\s*Preventing the Next Plant Invasion", merged_df$Title), ]

# ---- 6. Save ----
write_csv(merged_df, out_file)
message("Wrote updated publications to ", out_file)

timestamp <- format(Sys.Date(), "%Y-%m-%d")
backup_file <- paste0("publications_backup_", timestamp, ".csv")
if (!dir.exists("data")) dir.create("data")
write_csv(merged_df, file.path("data", backup_file))
message("Backup written to: ", file.path("data", backup_file))