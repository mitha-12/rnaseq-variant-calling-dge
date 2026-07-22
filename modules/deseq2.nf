// DESeq2
process DESEQ2 {
        container 'quay.io/biocontainers/bioconductor-deseq2:1.50.2--r45ha27e39d_0'
        publishDir "${params.outdir}/deseq2", mode:'copy'

        input:
        path counts
        path samples_csv

        output:
        path "deseq2_results.csv", emit: results
        path "deseq2_normalized_counts.csv", emit: normalized_counts
        path "deseq2_dds.rds", emit: dds

        script:
        """
        run_deseq2.R ${counts} ${samples_csv} deseq2
        """
}
// cache-bust: force fresh run to avoid stale resume glitch
