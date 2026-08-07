# Load libraries
library(tidyverse)
library(Biostrings)
library(khroma)       # Specialized colorblind palettes
library(RColorBrewer) # Standard research palettes

# --- CONFIGURATION ---
work_dir <- "/Users/Oscar/Desktop/Emerson_Lab_Work/Non_melanogaster"
setwd(work_dir)
data_dir <- "/Users/Oscar/Desktop/data/"

input_fastq <- paste0(data_dir,"dorado-polished_Dpse_MV25_hifiasm_12-2_hap1.fastq.gz")  # CHANGE THIS VARIABLE
window_size  <- 1000
step_size    <- 500
# ---------------------

# 1. Load the FASTQ file
if (!file.exists(input_fastq)) stop("File not found!")

# readQualityScaledDNAStringSet is the gold standard for FASTQ in R
fq <- readQualityScaledDNAStringSet(input_fastq)

# 2. Extract Quality Scores efficiently
# We convert the entire quality set to a list of integer vectors at once
qual_list <- as(quality(fq), "IntegerList")
contig_names <- names(fq)

# 3. Processing function
process_contig_quality <- function(i) {
  # Get the integer Phred scores for the i-th contig
  qual_values <- as.integer(qual_list[[i]])
  name        <- contig_names[i]
  seq_len     <- length(qual_values)
  
  if(seq_len < window_size) return(NULL) # Skip if contig is too short
  
  # Calculate window starts
  starts <- seq(1, max(1, seq_len - window_size + 1), by = step_size)
  
  # Calculate averages
  map_df(starts, function(s) {
    e <- min(s + window_size - 1, seq_len)
    tibble(
      contig = name,
      position = s + (window_size / 2),
      avg_quality = mean(qual_values[s:e])
    )
  })
}

# 4. Run processing across all sequences
plot_data <- map_df(1:length(fq), process_contig_quality) %>%
  mutate(contig = as.factor(contig)) # CRITICAL: Ensure contig is a factor
plot_data_hap1 = plot_data %>% filter(str_detect(contig, regex("h1tg")))

#Another solution to limited color number
#num_contigs <- length(unique(plot_data$contig))
#custom_palette <- colorRampPalette(brewer.pal(min(num_contigs, 12), "Paired"))(num_contigs)
#use this in ggplot: "scale_color_manual(values = custom_palette) +"


# 3. Plotting with a more robust color handling
quality_trend <- ggplot(plot_data_hap1, aes(x = position, y = avg_quality, color = contig)) +
  geom_line(alpha = 0.8, linewidth = 1) +
  scale_color_muted() + 
  theme_bw(base_size = 20) +
  labs(
    title = "Sliding Window Quality of Dorado Polished Contigs",
    subtitle = paste("Window:", window_size, "bp | Step:", step_size, "bp"),
    x = "Position (bp)",
    y = "Mean Phred Score (Q)",
    color = "Contig ID"
  ) +
  facet_wrap(~contig, scales = "free_x") +
  theme(
    legend.position = "bottom",
    legend.text = element_text(size = 12)
  )

ggsave( "Hap1_quality_score_trend.png",
  plot = quality_trend, 
  device = "png", 
  width = 4800, height = 3000,
  units = "px", dpi = 300,
  limitsize = FALSE)