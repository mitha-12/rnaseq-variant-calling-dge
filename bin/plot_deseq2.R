#!/usr/bin/env Rscript

# PCA, MA, Volcano plots and heatmap

args <- commandArgs(trailingOnly = TRUE)
dds_file     <- args[1]
results_file <- args[2]
out_prefix   <- args[3]

suppressMessages(library(DESeq2))
suppressMessages(library(ggplot2))

dds <- readRDS(dds_file)
res <- results(dds)

# PCA 
vsd <- vst(dds, blind = TRUE)
pca_data <- plotPCA(vsd, intgroup = "condition", returnData = TRUE)
percent_var <- round(100 * attr(pca_data, "percentVar"))

p_pca <- ggplot(pca_data, aes(PC1, PC2, color = condition, label = name)) +
  geom_point(size = 4) +
  geom_text(vjust = -1, size = 3) +
  xlab(paste0("PC1: ", percent_var[1], "% variance")) +
  ylab(paste0("PC2: ", percent_var[2], "% variance")) +
  theme_bw() +
  ggtitle("PCA of samples (VST-transformed)")

ggsave(paste0(out_prefix, "_pca.png"), p_pca, width = 7, height = 6, dpi = 150)

# MA
png(paste0(out_prefix, "_ma_plot.png"), width = 800, height = 700, res = 120)
plotMA(res, main = "MA Plot: AD vs Old")
dev.off()

# Volcano plot
res_df <- as.data.frame(res)
res_df$significant <- ifelse(!is.na(res_df$padj) & res_df$padj < 0.05,
                              "padj < 0.05", "Not significant")

p_volcano <- ggplot(res_df, aes(x = log2FoldChange, y = -log10(pvalue), color = significant)) +
  geom_point(alpha = 0.6, size = 1) +
  scale_color_manual(values = c("padj < 0.05" = "red", "Not significant" = "grey60")) +
  theme_bw() +
  ggtitle("Volcano Plot: AD vs Old") +
  xlab("log2 Fold Change") +
  ylab("-log10(p-value)")

ggsave(paste0(out_prefix, "_volcano.png"), p_volcano, width = 7, height = 6, dpi = 150)

# Heatmap - top 30 genes
top_genes <- rownames(res_df[order(res_df$padj), ])[1:30]
vsd_mat <- assay(vsd)[top_genes, ]
vsd_scaled <- t(scale(t(vsd_mat)))

heatmap_df <- as.data.frame(as.table(vsd_scaled))
colnames(heatmap_df) <- c("gene", "sample", "expression")

p_heatmap <- ggplot(heatmap_df, aes(x = sample, y = gene, fill = expression)) +
  geom_tile() +
  scale_fill_gradient2(low = "blue", mid = "white", high = "red", midpoint = 0) +
  theme_minimal() +
  theme(axis.text.y = element_text(size = 6)) +
  ggtitle("Top 30 DE genes (scaled expression)")

ggsave(paste0(out_prefix, "_heatmap.png"), p_heatmap, width = 7, height = 8, dpi = 150)

cat("Plotting complete. Generated: PCA, MA, volcano, heatmap.\n")

