// Netwoek plots
process NETWORK_PLOTS {
	container 'quay.io/biocontainers/bioconductor-clusterprofiler:4.14.0--r44hdfd78af_0'
	containerOptions "--bind ${params.org_hs_eg_db_path}:/usr/local/lib/R/library/org.Hs.eg.db"
	publishDir "${params.outdir}/network_plots", mode:'copy'

	input:
	path results

	output:
	path "network_cnetplot.png"
	path "network_emapplot.png"

	script:
	"""
	run_network_plots.R ${results} network
	"""
}
