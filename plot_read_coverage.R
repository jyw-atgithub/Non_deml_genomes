# Load necessary libraries
library("tidyverse")
library("khroma")
library("RColorBrewer")
library("ggbreak") 
library("patchwork")

# --- CONFIGURATION ---
work_dir <- "/Users/Oscar/Desktop/Emerson_Lab_Work/Non_melanogaster"
setwd(work_dir)
data_dir <- "/Users/Oscar/Desktop/data/"
long_input <- paste0(data_dir,"long-read_MV25_final.depth")
illumina_input <- paste0(data_dir,"illumina_MV25_final.depth")
# ---------------------

average_depth_windows <- function(data, window_size = 100, step_size = 50) {
    data %>%
        group_by(chr, type) %>%
        group_modify(~ {
            starts <- seq(1, max(.x$pos), by = step_size)
            ends <- starts + window_size - 1
            left <- findInterval(starts - 1, .x$pos)
            right <- findInterval(ends, .x$pos)
            cumulative_depth <- c(0, cumsum(.x$depth))
            tibble(
                pos = starts,
                depth = (cumulative_depth[right + 1] -
                         cumulative_depth[left + 1]) / (right - left)
            )
        }) %>%
        ungroup()
}

long_tsv = read_tsv(long_input, col_names = c("chr", "pos", "depth")) %>%
    mutate(type = "ONT") %>%
    average_depth_windows()
illumina_tsv = read_tsv(illumina_input, col_names = c("chr", "pos", "depth")) %>%
    mutate(type = "Illumina") %>%
    average_depth_windows()
combined_tsv = rbind(long_tsv, illumina_tsv)
rm(long_tsv, illumina_tsv)

fig = ggplot() +
  geom_line(data = combined_tsv, aes(x = pos, y = depth, color = type), linewidth = 0.5) + 
  facet_wrap(~chr, ncol = 1, scales = "free_x") +
  #facet_grid(type~.) +
  theme_minimal() +
  scale_color_highcontrast() +
  coord_cartesian(ylim = c(0, 300))

ggsave(filename = paste0(work_dir,"/MV25_read_coverage.png"), plot = fig, width = 16, height = 9, dpi = 120)

chrX_detail = ggplot() +
  geom_line(data = combined_tsv %>% filter(chr == "chrX"), aes(x = pos, y = depth, color = type), linewidth = 0.5) + 
  theme_minimal() +
  scale_color_highcontrast() +
  coord_cartesian(xlim = c(4.7e7, 5.1e7), ylim = c(0, 200))
ggsave(filename = paste0(work_dir,"/MV25_read_coverage_chrX_detail.png"), plot = chrX_detail, width = 16, height = 9, dpi = 120)