# Load libraries
library(scholar)
library(rorcid)
library(stringdist)

# 1. Get Google Scholar publications
gs_id <- "YzHpPVgAAAAJ"
gs_pubs <- get_publications(gs_id)

# 2. Get ORCID publications
orcid_id <- "0000-0002-7972-7928"
orcid_data <- orcid_works(orcid_id)
orcid_pubs <- orcid_data[[1]]$works

# 3. Prepare titles for fuzzy matching
gs_titles <- tolower(gs_pubs$title)
orcid_titles <- tolower(orcid_pubs$title.title.value)

# 4. Fuzzy match ORCID titles to Google Scholar
matches <- sapply(orcid_titles, function(orcid_title) {
  distances <- stringdist(orcid_title, gs_titles, method = "jw")
  best_match <- which.min(distances)
  if (min(distances) < 0.2) best_match else NA
})

# 5. Combine into a merged data frame
merged_df <- data.frame(
  Title     = orcid_pubs$title.title.value,
  Year      = orcid_pubs$`publication-date.year.value`,
  Type      = orcid_pubs$type,
  ORCID_Journal = orcid_pubs$`journal-title.value`,
  GS_Title  = ifelse(!is.na(matches), gs_pubs$title[matches], NA),
  Author    = ifelse(!is.na(matches), gs_pubs$author[matches], NA),
  Journal   = ifelse(!is.na(matches), gs_pubs$journal[matches], NA),
  Number    = ifelse(!is.na(matches), gs_pubs$number[matches], NA),
  Citations = ifelse(!is.na(matches), gs_pubs$cites[matches], NA),
  stringsAsFactors = FALSE
)

# 6. View in RStudio
View(merged_df)

write.csv(merged_df, "publications.csv", row.names = FALSE)
