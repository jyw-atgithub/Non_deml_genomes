# Load necessary libraries
library(tidyverse)
library(Biostrings)
library(rtracklayer)
library(khroma)
library(RColorBrewer)
library(ggbreak) 
library(patchwork)

# --- CONFIGURATION ---
work_dir <- "/Users/Oscar/Desktop/Emerson_Lab_Work/Non_melanogaster"
setwd(work_dir)
data_dir <- "/Users/Oscar/Desktop/data/"
input_fastq <- paste0(data_dir,"dorado-polished_Dpse_MV25_hifiasm_12-2_hap1.fastq.gz")
fasta_file <- "assembly.fasta"
rm_out_file <- paste0(data_dir, "dorado-polished_Dpse_MV25_hifiasm_12-2_hap1.fa.out")
# ---------------------

# 1. Load Genome to get Contig Lengths
# We need this to draw the "background" bar for each contig
genome <- readQualityScaledDNAStringSet(input_fastq)
contig_info <- tibble(
  query = names(genome) %>% word(1), # Clean headers to match GFF
  start = 1,
  end = width(genome)
)


# 2. Parse the .out file
# rtracklayer does not work well on loading the RepeatMasker GFF. 
# Manual GFF3 Parsing (The "Fail-Safe" Way) is also BAD because not all info is included.
# We skip 3 lines (the header) and manually name the core columns
# Note: The 16th column 'overlap_star' is often empty, which causes the mismatch warning.
rm_data <- read_table(
  rm_out_file, 
  skip = 3,
  col_names = c(
    "sw_score", "perc_div", "perc_del", "perc_ins", "query", 
    "q_start", "q_end", "q_left", "strand", "repeat_name", 
    "class_family", "r_start", "r_end", "r_left", "id", "overlap_star"
  ),
  col_types = "ddddciiccccccccc" # Explicitly setting types prevents guessing errors
)

# 3. Clean Repeat Families
# We extract the main class (e.g., LINE, SINE, LTR) before the "/"
repeats_clean <- rm_data %>%
  mutate(
    # Ensure the query name matches the FASTA headers
    query = as.character(query),
    main_class = str_extract(class_family, "^[^/]+")
  ) %>%
  # Filter out any non-assembly contigs and handle NA classes
  filter(query %in% contig_info$query, !is.na(main_class))

# 4. Dynamic Color Palette for Multiple Classes
num_classes <- length(unique(repeats_clean$main_class))
custom_palette <- colorRampPalette(brewer.pal(min(num_classes, 12), "Paired"))(num_classes)


############################################################

# Size = 1800*1200 pt

plot_repeat_landscape <- function(input_tibble, plot_subtitle = "Repeat by Class") {
  # Calculate required colors based on the input data
  num_classes <- length(unique(input_tibble$main_class))
  # Generate custom palette
  custom_palette <- colorRampPalette(brewer.pal(min(num_classes, 12), "Paired"))(num_classes)
  
  # Build the ggplot object
  p <- ggplot() +
    # Draw the full length of each contig
    geom_rect(data = contig_info, 
              aes(xmin = start, xmax = end, ymin = -0.4, ymax = 0.4),
              fill = "grey95", color = "grey85", linewidth = 0.2) +
    
    # Draw the repeat segments
    geom_rect(data = input_tibble,
              aes(xmin = q_start, xmax = q_end, ymin = -0.4, ymax = 0.4, fill = main_class),
              alpha = 1) +
    
    # Grouping by Contig
    facet_wrap(~query, ncol = 1, strip.position = "left", scales = "free_x") +
    
    # Styling
    scale_fill_manual(values = custom_palette) +
    theme_minimal(base_size = 11) +
    labs(
      title = "Repeat Architecture Landscape",
      subtitle = plot_subtitle, # Variable applied here
      x = "Genomic Position (bp)",
      fill = "Repeat Class"
    ) +
    theme(
      axis.text.y = element_blank(),
      axis.ticks.y = element_blank(),
      panel.grid.major.y = element_blank(),
      panel.grid.minor.y = element_blank(),
      strip.text.y.left = element_text(angle = 0, face = "bold", size = 9),
      legend.position = "bottom",
      legend.box.margin = margin(t = 10)
    )
  
  return(p)
}

# --- USAGE EXAMPLES ---
# my_plot1 <- plot_repeat_landscape(repeats_clean) 
# my_plot2 <- plot_repeat_landscape(repeats_filtered, "High-Confidence Repeats Only")

###################################################################
# Visualize by the repeat name
repeats_TE_only <- repeats_clean %>% filter_out(class_family == "Simple_repeat") %>% filter_out(class_family == "Low_complexity")

num_classes <- length(unique(repeats_TE_only$repeat_name))
custom_palette <- colorRampPalette(brewer.pal(min(num_classes, 12), "Paired"))(num_classes)

ggplot() +
  # Draw the background bar for each contig
  geom_rect(data = contig_info, 
            aes(xmin = start, xmax = end, ymin = -0.4, ymax = 0.4),
            fill = "grey95", color = "grey85", linewidth = 0.2) +
  
  # Draw the repeats
  geom_rect(data = repeats_TE_only,
            aes(xmin = q_start, xmax = q_end, ymin = -0.4, ymax = 0.4, fill = repeat_name),
            alpha = 1) +
  
  # CRITICAL CHANGE: scales = "free_x"
  facet_wrap(~query, ncol = 1, strip.position = "left", scales = "free_x") +
  
  # Styling
  scale_fill_manual(values = custom_palette) +
  theme_minimal(base_size = 16) +
  labs(
    title = "Comparative Repeat Landscape",
    subtitle = "Only TE",
    x = "Genomic Position (bp)",
    fill = "Repeat Name"
  ) +
  theme(
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank(),
    panel.grid.major.y = element_blank(),
    panel.grid.minor.y = element_blank(),
    strip.text.y.left = element_text(angle = 0, face = "bold", size = 12),
    legend.position = "none",
    # Add space between facets to make individual scales clearer
    panel.spacing = unit(1, "lines") 
  )

###############################################################

###################################################################
# Visualize by the repeat name
repeats_TE_only <- repeats_clean %>% filter_out(class_family == "Simple_repeat") %>% filter_out(class_family == "Low_complexity")

num_classes <- length(unique(repeats_TE_only$repeat_name))
custom_palette <- colorRampPalette(brewer.pal(min(num_classes, 12), "Paired"))(num_classes)

ggplot() +
  # Draw the background bar for each contig
  geom_rect(data = contig_info, 
            aes(xmin = start, xmax = end, ymin = -0.4, ymax = 0.4),
            fill = "grey95", color = "grey85", linewidth = 0.2) +
  
  # Draw the repeats
  geom_rect(data = repeats_TE_only,
            aes(xmin = q_start, xmax = q_end, ymin = -0.4, ymax = 0.4, fill = repeat_name),
            alpha = 1) +
  
  # CRITICAL CHANGE: scales = "free_x"
  facet_wrap(~query, ncol = 1, strip.position = "left", scales = "free_x") +
  
  # Styling
  scale_fill_manual(values = custom_palette) +
  theme_minimal(base_size = 16) +
  labs(
    title = "Comparative Repeat Landscape",
    subtitle = "Only TE",
    x = "Genomic Position (bp)",
    fill = "Repeat Name"
  ) +
  theme(
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank(),
    panel.grid.major.y = element_blank(),
    panel.grid.minor.y = element_blank(),
    strip.text.y.left = element_text(angle = 0, face = "bold", size = 12),
    legend.position = "none",
    # Add space between facets to make individual scales clearer
    panel.spacing = unit(1, "lines") 
  )

###############################################################
#repeat_name == "BS3_DM" | repeat_name == "BS"|
repeats_telo <- repeats_clean %>% filter( repeat_name == "TAHRE" | repeat_name == "HeT-A-B"| repeat_name == "HeT-A" | repeat_name == "TART-A" | repeat_name == "TART-B1")

num_classes <- length(unique(repeats_telo$repeat_name))
custom_palette <- colorRampPalette(brewer.pal(min(num_classes, 12), "Paired"))(num_classes)

window_fraction <- 0.10

contig_plot_info <- contig_info %>%
  transmute(
    query,
    contig_end = end,
    left_end = contig_end * window_fraction,
    right_start = contig_end * (1 - window_fraction)
  )

contig_windows_plot <- bind_rows(
  contig_plot_info %>%
    transmute(
      query,
      region = "Start 10%",
      xmin_plot = 0,
      xmax_plot = left_end
    ),
  contig_plot_info %>%
    transmute(
      query,
      region = "End 10%",
      xmin_plot = right_start,
      xmax_plot = contig_end
    )
)

repeats_telo_with_contig <- repeats_telo %>%
  left_join(contig_plot_info, by = "query")

repeats_telo_start <- repeats_telo_with_contig %>%
  mutate(
    region = "Start 10%",
    xmin_plot = pmax(q_start, 0),
    xmax_plot = pmin(q_end, left_end)
  ) %>%
  filter(xmin_plot <= xmax_plot)

repeats_telo_end <- repeats_telo_with_contig %>%
  mutate(
    region = "End 10%",
    xmin_plot = pmax(q_start, right_start),
    xmax_plot = pmin(q_end, contig_end)
  ) %>%
  filter(xmin_plot <= xmax_plot)

repeats_telo_ends <- bind_rows(repeats_telo_start, repeats_telo_end)

arrow_data <- repeats_telo_ends %>%
  transmute(
    query,
    region,
    x_arrow = (xmin_plot + xmax_plot) / 2,
    y_start = 0.72,
    y_end = 0.44
  )

contig_windows_plot$region <- factor(contig_windows_plot$region, levels = c("Start 10%", "End 10%"))
repeats_telo_ends$region <- factor(repeats_telo_ends$region, levels = c("Start 10%", "End 10%"))
arrow_data$region <- factor(arrow_data$region, levels = c("Start 10%", "End 10%"))

contig_windows_plot$query <- factor(contig_windows_plot$query, levels = contig_info$query)
repeats_telo_ends$query <- factor(repeats_telo_ends$query, levels = contig_info$query)
arrow_data$query <- factor(arrow_data$query, levels = contig_info$query)

ggplot() +
  # Draw the background bar for each contig
  geom_rect(data = contig_windows_plot,
            aes(xmin = xmin_plot, xmax = xmax_plot, ymin = -0.4, ymax = 0.4),
            fill = "grey95", color = "grey85", linewidth = 0.2) +
  
  # Draw the repeats
  geom_rect(data = repeats_telo_ends,
            aes(xmin = xmin_plot, xmax = xmax_plot, ymin = -0.4, ymax = 0.4, fill = repeat_name),
            alpha = 1) +
  # Add red arrows at desired repeat locations
  geom_segment(
    data = arrow_data,
    aes(x = x_arrow, xend = x_arrow, y = y_start, yend = y_end),
    color = "red3",
    linewidth = 0.4,
    arrow = grid::arrow(length = grid::unit(0.12, "cm"), type = "closed")
  ) +
  facet_wrap(
    vars(query, region),
    ncol = 2,
    scales = "free_x"
  ) +
  scale_x_continuous(
    labels = scales::label_number(big.mark = ",", accuracy = 1),
    expand = expansion(mult = c(0, 0))
  ) +
  
  # Styling
  #scale_fill_manual(values = custom_palette) +
  scale_fill_muted() +
  theme_minimal(base_size = 20) +
  labs(
    x = "Position (bp)",
    fill = "Repeat Class"
  ) +
  theme(
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank(),
    panel.grid.major.y = element_blank(),
    panel.grid.minor.y = element_blank(),
    strip.text.y.left = element_text(angle = 0, face = "bold", size = 16),
    strip.text.x = element_text(face = "bold", size = 16),
    legend.position = "bottom",
    # Add space between facets to make individual scales clearer
    panel.spacing = unit(1, "lines") 
  )
