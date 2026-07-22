#!/usr/bin/env Rscript

# GO enrichment analysis

args <- commandArgs(trailingOnly = TRUE)
results_file <- args[1]
out_prefix   <- args[2]

suppressMessages(library(clusterProfiler))
suppressMessages(library(org.Hs.eg.db))

res <- read.csv(results_file, row.names = 1)

sig_genes <- rownames(res[!is.na(res$padj) & res$padj < 0.05, ])

sig_genes_clean <- sub("\\..*$", "", sig_genes)

universe_clean <- sub("\\..*$", "", rownames(res))

enrichgo <- enrichGO(
  gene          = sig_genes_clean,
  universe      = universe_clean,
  OrgDb         = org.Hs.eg.db,
  keyType       = "ENSEMBL",
  ont           = "BP",  # Biological Process ontology
  pAdjustMethod = "BH",
  pvalueCutoff  = 0.05,
  readable      = TRUE
)

write.csv(as.data.frame(enrichgo), paste0(out_prefix, "_go_enrichment.csv"))

cat("GO enrichment complete.\n")
cat("Significant genes tested:", length(sig_genes_clean), "\n")
cat("Enriched GO terms found:", nrow(as.data.frame(enrichgo)), "\n")
