// GO enrichment

process GO_ENRICHMENT {
	container 'quay.io/biocontainers/bioconductor-clusterprofiler:4.14.0--r44hdfd78af_0'
	containerOptions "--bind ${params.org_hs_eg_db_path}:/usr/local/lib/R/library/org.Hs.eg.db"
	publishDir "${params.outdir}/go_enrichment", mode:'copy'

	input:
	path results

	output:
	path "go_go_enrichment.csv"

	script:
	"""
	run_go_enrichment.R ${results} go
	"""
}
