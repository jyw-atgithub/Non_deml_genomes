library(dplyr)
library(geneviewer)
library(htmlwidgets)
library(webshot2)

extract_attribute <- function(attributes, keys) {
  pattern <- paste0("(?:^|;)(?:", paste(keys, collapse = "|"), ")=([^;]+)")
  value <- sub(pattern, "\\1", attributes, perl = TRUE)
  ifelse(value == attributes, NA_character_, value)
}

work_dir <- "/Users/Oscar/Desktop/Emerson_Lab_Work/Non_melanogaster"
input_gff <- "/Users/Oscar/Desktop/data/Dpse_MV25_final.fasta.out.gff"
output_dir <- file.path(work_dir, "gene_telomere_plots")

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

gff <- read_gff(input_gff)
if ("motif_type" %in% names(gff)) {
  gff$motif_type <- as.character(gff$motif_type)
} else if ("motif" %in% names(gff)) {
  gff$motif_type <- as.character(gff$motif)
} else if ("attributes" %in% names(gff)) {
  gff$motif_type <- sub(
    ".*Target[[:space:]]+\"Motif:([^\"]+)\".*",
    "\\1",
    gff$attributes,
    perl = TRUE
  )
  gff$motif_type[gff$motif_type == gff$attributes] <- NA_character_
  gff$motif_type <- coalesce(
    gff$motif_type,
    extract_attribute(
    gff$attributes,
    c("motif_type", "motif", "repeat_type", "class", "classification")
    )
  )
} else {
  gff$motif_type <- NA_character_
}
gff$motif_type[is.na(gff$motif_type) | gff$motif_type == ""] <- "Unclassified"

chromosomes <- gff %>%
  group_by(seqid) %>%
  summarise(chromosome_length = max(end, na.rm = TRUE), .groups = "drop")

windows <- bind_rows(
  chromosomes %>% transmute(seqid, region = "first_100kb", window_start = 1, window_end = pmin(100000, chromosome_length)),
  chromosomes %>% transmute(seqid, region = "last_100kb", window_start = pmax(1, chromosome_length - 99999), window_end = chromosome_length)
) %>%
  mutate(cluster = paste(seqid, region, sep = "_"))

dispersed_repeats <- gff %>%
  filter(type == "dispersed_repeat") %>%
  inner_join(windows, by = "seqid") %>%
  filter(start <= window_end, end >= window_start) %>%
  mutate(
    start = pmax(start, window_start),
    end = pmin(end, window_end),
    name = paste0(seqid, ":", start, "-", end),
    cluster = as.character(cluster),
    motif_type = as.character(motif_type)
  ) %>%
  select(name, start, end, strand, motif_type, cluster)

empty_windows <- windows %>%
  anti_join(dispersed_repeats %>% distinct(cluster), by = "cluster") %>%
  transmute(
    name = "No dispersed repeats",
    start = window_start,
    end = window_start,
    strand = "+",
    motif_type = "No dispersed_repeat",
    cluster = as.character(cluster)
  )

dispersed_repeats <- bind_rows(dispersed_repeats, empty_windows)

plot <- GC_chart(
  dispersed_repeats,
  start = "start",
  end = "end",
  cluster = "cluster",
  group = "motif_type",
  strand = "strand",
  height = paste0(max(300, 120 * n_distinct(dispersed_repeats$cluster)), "px")
)

for (i in seq_len(nrow(windows))) {
  window <- windows[i, ]
  cluster_name <- as.character(window$cluster)
  plot <- plot %>%
    GC_scale(
      cluster = cluster_name,
      start = window$window_start,
      end = window$window_end,
      ticksCount = 5,
      textStyle = list(fontSize = "14px")
    ) %>%
    GC_clusterTitle(
      cluster = cluster_name,
      title = paste(window$seqid, window$region, sep = " - "),
      titleFont = list(fontSize = "18px", fontWeight = "bold")
    )
}

plot <- plot %>%
  GC_labels(
    "name",
    labelOptions = list(fontSize = "16px", fontWeight = "bold")
  ) %>%
  GC_legend(TRUE, position = "bottom")

motif_types <- sort(unique(dispersed_repeats$motif_type))
motif_colors <- setNames(
  grDevices::hcl.colors(length(motif_types), palette = "Dark 3"),
  motif_types
)
plot <- plot %>%
  GC_color(customColors = as.list(motif_colors))

html_file <- file.path(output_dir, "dispersed_repeats_first_last_100kb.html")
png_file <- file.path(output_dir, "dispersed_repeats_first_last_100kb.png")

htmlwidgets::saveWidget(plot, html_file, selfcontained = TRUE)
webshot2::webshot(html_file, png_file, vwidth = 1800, vheight = 1800, zoom = 2)

message("Wrote: ", png_file)
