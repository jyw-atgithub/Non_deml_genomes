library(ggplot2)
library(ggbio)
library(GenomicRanges)
library(IRanges)
library(rtracklayer)
library(patchwork)
library("patchwork")
library(khroma)

#if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager")
#BiocManager::install(c(
#  "ggbio",
#  "biovizBase",                         # sample genomic data used below
#  "Homo.sapiens",                       # OrganismDb gene models (hg19)
#  "TxDb.Hsapiens.UCSC.hg19.knownGene",  # TxDb gene models (hg19)
#  "BSgenome.Hsapiens.UCSC.hg19",        # reference sequence (hg19)
#  "VariantAnnotation"                   # reads VCF files
#))


work_dir <- "/Users/Oscar/Desktop/Emerson_Lab_Work/Non_melanogaster"
input_gff <- "/Users/Oscar/Desktop/data/Dpse_MV25_final.fasta.out.gff"
output_dir <- file.path(work_dir, "gene_telomere_plots")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

annotation <- rtracklayer::import(input_gff, format = "gff3")
chromosome_names <- as.character(seqlevels(annotation))
chromosome_lengths <- seqlengths(annotation)[chromosome_names]
missing_lengths <- is.na(chromosome_lengths) | !is.finite(chromosome_lengths)
chromosome_lengths[missing_lengths] <- sapply(
  chromosome_names[missing_lengths],
  function(chromosome) max(end(annotation)[as.character(seqnames(annotation)) == chromosome], na.rm = TRUE)
)

windows <- rbind(
  data.frame(
    seqid = chromosome_names,
    region = "first_100kb",
    window_start = 1,
    window_end = pmin(100000, chromosome_lengths),
    stringsAsFactors = FALSE
  ),
  data.frame(
    seqid = chromosome_names,
    region = "last_100kb",
    window_start = pmax(1, chromosome_lengths - 99999),
    window_end = chromosome_lengths,
    stringsAsFactors = FALSE
  )
)
windows$cluster <- paste(windows$seqid, windows$region, sep = "_")

repeats <- annotation[mcols(annotation)$type == "dispersed_repeat"]
gff_rows <- read.delim(
  input_gff,
  header = FALSE,
  sep = "\t",
  quote = "",
  comment.char = "#",
  col.names = c("seqid", "source", "type", "start", "end", "score", "strand", "phase", "attributes"),
  stringsAsFactors = FALSE
)
repeat_rows <- gff_rows[gff_rows$type == "dispersed_repeat", ]
if (length(repeats) != nrow(repeat_rows)) {
  stop("The imported GFF rows and repeat attributes do not have matching lengths.")
}
target <- repeat_rows$attributes
repeats$motif_type <- sub(".*Motif:([^\"[:space:]]+).*", "\\1", target, perl = TRUE)
repeats$motif_type[is.na(repeats$motif_type) | repeats$motif_type == target] <- "Unclassified"

repeat_data <- as.data.frame(repeats)
repeat_data$seqid <- as.character(repeat_data$seqnames)
repeat_data <- merge(repeat_data, windows, by = "seqid")
repeat_data <- repeat_data[
  repeat_data$start <= repeat_data$window_end & repeat_data$end >= repeat_data$window_start,
]
repeat_data$start <- pmax(repeat_data$start, repeat_data$window_start)
repeat_data$end <- pmin(repeat_data$end, repeat_data$window_end)
repeat_data$region <- factor(repeat_data$region, levels = c("first_100kb", "last_100kb"))
repeat_data$seqid <- factor(repeat_data$seqid, levels = chromosome_names)
repeat_data <- repeat_data[, c("seqid", "start", "end", "strand", "motif_type", "region", "cluster"), drop = FALSE]

empty_windows <- windows[!windows$cluster %in% unique(repeat_data$cluster), ]
if (nrow(empty_windows) > 0) {
  empty_data <- empty_windows
  empty_data$start <- empty_data$window_start
  empty_data$end <- empty_data$window_start
  empty_data$motif_type <- "No dispersed repeats"
  empty_data$seqnames <- empty_data$seqid
  empty_data$strand <- "+"
  empty_data <- empty_data[, names(repeat_data), drop = FALSE]
  repeat_data <- rbind(repeat_data, empty_data)
}

repeat_data$cluster <- factor(repeat_data$cluster, levels = windows$cluster)
repeat_data$motif_type <- factor(repeat_data$motif_type)
motif_levels <- levels(repeat_data$motif_type)
motif_colors <- setNames(
  khroma::colour("muted")(length(motif_levels)),
  motif_levels
)

window_anchors <- rbind(
  transform(windows, x = window_start),
  transform(windows, x = window_end)
)
window_anchors$seqid <- factor(window_anchors$seqid, levels = chromosome_names)
window_anchors$region <- factor(window_anchors$region, levels = c("first_100kb", "last_100kb"))

for (chromosome in chromosome_names) {
  chromosome_plots <- list()
  for (region_name in c("first_100kb", "last_100kb")) {
    window <- windows[windows$seqid == chromosome & windows$region == region_name, ]
    region_data <- repeat_data[
      repeat_data$seqid == chromosome & repeat_data$region == region_name,
      ,
      drop = FALSE
    ]
    region_ranges <- GenomicRanges::makeGRangesFromDataFrame(
      region_data[, c("seqid", "start", "end", "strand", "motif_type")],
      seqnames.field = "seqid",
      keep.extra.columns = TRUE
    )
    anchors <- data.frame(x = c(window$window_start, window$window_end), y = 0)

    plot <- ggplot2::ggplot() +
      ggbio::geom_alignment(
        data = region_ranges,
        mapping = ggplot2::aes(colour = motif_type)
      ) +
      ggplot2::geom_blank(data = anchors, ggplot2::aes(x = x, y = y)) +
      ggplot2::scale_x_continuous(
        limits = c(window$window_start, window$window_end),
        labels = scales::label_comma()
      ) +
      ggplot2::scale_colour_manual(values = motif_colors, name = "Motif type", drop = FALSE) +
      ggplot2::labs(
        x = paste0(chromosome, " coordinate (bp)"),
        y = NULL,
        title = paste(chromosome, region_name, sep = " - ")
      ) +
      ggplot2::theme_bw(base_size = 14) +
      ggplot2::theme(
        axis.text.y = ggplot2::element_text(size = 11),
        axis.text.x = ggplot2::element_text(size = 11, angle = 45, hjust = 1),
        legend.text = ggplot2::element_text(size = 11),
        legend.title = ggplot2::element_text(size = 13, face = "bold"),
        panel.grid.minor = ggplot2::element_blank()
      )

    file_stem <- file.path(
      output_dir,
      paste("dispersed_repeats", chromosome, region_name, "ggbio", sep = "_")
    )
    ggplot2::ggsave(paste0(file_stem, ".png"), plot, width = 10, height = 4, dpi = 300)
    chromosome_plots[[region_name]] <- plot
  }

  combined_plot <- (
    chromosome_plots[["first_100kb"]] /
      chromosome_plots[["last_100kb"]]
  ) +
    patchwork::plot_layout(guides = "collect") &
    ggplot2::theme(legend.position = "bottom")
  combined_stem <- file.path(
    output_dir,
    paste("dispersed_repeats", chromosome, "ggbio", sep = "_")
  )
  ggplot2::ggsave(paste0(combined_stem, ".png"), combined_plot, width = 10, height = 8, dpi = 300)
}

message("Wrote individual chromosome-window plots to: ", normalizePath(output_dir))
