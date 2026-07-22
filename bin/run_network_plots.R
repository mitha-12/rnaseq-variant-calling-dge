#!/usr/bin/env Rscript
# cnetplot, emapplot - network analysis

args <- commandArgs(trailingOnly = TRUE)
results_file <- args[1]
out_prefix   <- args[2]

suppressMessages(library(clusterProfiler))
suppressMessages(library(org.Hs.eg.db))
suppressMessages(library(enrichplot))
suppressMessages(library(ggplot2))

res <- read.csv(results_file, row.names = 1)

sig_genes <- rownames(res[!is.na(res$padj) & res$padj < 0.05, ])
sig_genes_clean <- sub("\\..*$", "", sig_genes)
universe_clean <- sub("\\..*$", "", rownames(res))

enrichgo <- enrichGO(
  gene          = sig_genes_clean,
  universe      = universe_clean,
  OrgDb         = org.Hs.eg.db,
  keyType       = "ENSEMBL",
  ont           = "BP",
  pAdjustMethod = "BH",
  pvalueCutoff  = 0.05,
  readable      = TRUE
)

enrichgo_sim <- pairwise_termsim(enrichgo)

p_cnet <- cnetplot(enrichgo, showCategory = 10, categorySize = "pvalue") +
  ggtitle("Gene-Concept Network: Top 10 GO Terms")

ggsave(paste0(out_prefix, "_cnetplot.png"), p_cnet, width = 10, height = 8, dpi = 150)

p_emap <- emapplot(enrichgo_sim, showCategory = 15) +
  ggtitle("Enrichment Map: Top 15 GO Terms")

ggsave(paste0(out_prefix, "_emapplot.png"), p_emap, width = 10, height = 8, dpi = 150)

cat("Network plots complete. Generated: cnetplot, emapplot.\n")
