#!/usr/bin/env Rscript

# DGE - DESeq2

args <- commandArgs(trailingOnly = TRUE)
counts_file   <- args[1]
samples_file  <- args[2]
out_prefix    <- args[3]

suppressMessages(library(DESeq2))

# --- Read featureCounts output ---
counts_raw <- read.table(counts_file, header = TRUE, skip = 1, row.names = 1,
                          sep = "\t", check.names = FALSE)

count_matrix <- as.matrix(counts_raw[, 6:ncol(counts_raw)])

colnames(count_matrix) <- sub("_dedup\\.bam$", "", colnames(count_matrix))

# Read sample metadata
samples <- read.csv(samples_file)
rownames(samples) <- samples$sample_id

samples <- samples[colnames(count_matrix), ]

# DESeq2
dds <- DESeqDataSetFromMatrix(
  countData = count_matrix,
  colData   = samples,
  design    = ~ condition
)

dds <- DESeq(dds)
res <- results(dds)
res_ordered <- res[order(res$padj), ]

# Output
write.csv(as.data.frame(res_ordered), paste0(out_prefix, "_results.csv"))
write.csv(counts(dds, normalized = TRUE), paste0(out_prefix, "_normalized_counts.csv"))
saveRDS(dds, paste0(out_prefix, "_dds.rds"))  # saved for the plotting step next

cat("DESeq2 complete.\n")
cat("Total genes tested:", nrow(res), "\n")
cat("Significant (padj < 0.05):", sum(res$padj < 0.05, na.rm = TRUE), "\n")

