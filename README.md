# Susan Canavan – Website

This repository contains the source files for my website built with [Quarto](https://quarto.org/).

## File Structure

-   `index.qmd` — Home page\
-   `about.qmd` — About section\
-   `research.qmd` — Research interests and activities\
-   `publications.qmd` — Publication list (generated from CSV)\
-   `media.qmd` — News and media coverage\
-   `styles.css` — Custom styling and font\
-   `scripts/update_publications.R` — Script to update publications from Google Scholar and ORCID\
-   `publications.csv` — Automatically generated list of publications

## Updating Publications

To refresh the publication list (`publications.csv`) from Google Scholar and ORCID:

1. Open R or RStudio.
2. Set your working directory to the root of the website project:

    ```r
    setwd("path/to/your/website/project")
    ```

3. Make the update script executable (first time only):

    ```r
    Sys.chmod("scripts/update_publications.R", mode = "0755")
    ```

4. Run the script:

    ```r
    system("Rscript scripts/update_publications.R")
    ```

This will fetch your latest publications, fuzzy match titles between Google Scholar and ORCID, and write a new `publications.csv` file used by the website.
