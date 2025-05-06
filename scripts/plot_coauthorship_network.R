library(tidyverse)
library(igraph)
library(ggraph)
library(scales)
library(showtext)
library(sysfonts)

# 0. Add custom CMUSerif font from local 'fonts' folder
font_add("CMUSerif", "fonts/cmunrm.otf")
showtext_auto()

# 1. Load publications
pubs <- read_csv("publications.csv", show_col_types = FALSE)

# 2. Create co-author pairs for each multi-author paper
edges <- pubs %>%
  separate_rows(Authors, sep = ",\\s*") %>%
  group_by(Title) %>%
  filter(n_distinct(Authors) > 1) %>%
  group_modify(~ {
    auths <- unique(.x$Authors)
    if (length(auths) < 2) return(tibble(from = character(), to = character()))
    pairs <- combn(auths, 2)
    tibble(from = pairs[1, ], to = pairs[2, ])
  }) %>%
  ungroup()

# 3. Add weights: count number of collaborations per pair
weighted_edges <- edges %>%
  count(from, to, name = "weight")  # keep as 'weight' for igraph compatibility

# 4. Count unique papers per author
author_pubs <- pubs %>%
  separate_rows(Authors, sep = ",\\s*") %>%
  distinct(Title, Authors) %>%
  count(Authors, name = "n_pubs") %>%
  rename(author = Authors)

# 5. Create igraph object
g <- graph_from_data_frame(weighted_edges, directed = FALSE, vertices = author_pubs)

library(tidyverse)
library(igraph)
library(ggraph)
library(scales)

# Plot
p <- ggraph(g, layout = "fr") +
  geom_edge_link(aes(width = weight), alpha = 0.2, show.legend = TRUE) +
  geom_node_point(aes(size = n_pubs), color = "#2c3e50", show.legend = TRUE) +
  geom_node_label(aes(label = name),
                  repel = TRUE,
                  size = 14,  # Author labels
                  family = "CMUSerif",
                  label.padding = unit(0.15, "lines"),
                  label.size = NA,
                  fill = scales::alpha("white", 0.7),
                  color = "black") +
  scale_size(name = "Number of Publications", range = c(6, 16), guide = "legend") +
  scale_edge_width(name = "Co-authored Papers", range = c(1, 10), guide = "legend")+
  labs(title = NULL) +
  theme_void(base_family = "CMUSerif") +
  theme(
    plot.title = element_text(hjust = 0.5, size = 42, face = "bold"),
    legend.title = element_text(size = 40),
    legend.text = element_text(size = 40)
  )

# Save the plot
ggsave("images/coauthorship_network.png", plot = p, width = 20, height = 15, dpi = 150)

