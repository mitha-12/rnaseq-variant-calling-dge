// Plots
process PLOT_DESEQ2 {
	container 'quay.io/biocontainers/bioconductor-deseq2:1.50.2--r45ha27e39d_0'
	publishDir "${params.outdir}/plots", mode:'copy'

	input:
	path dds
	path results

	output:
	path "deseq2_pca.png"
	path "deseq2_ma_plot.png"
	path "deseq2_volcano.png"
	path "deseq2_heatmap.png"

	script:
	"""
	plot_deseq2.R ${dds} ${results} deseq2
	"""
}
