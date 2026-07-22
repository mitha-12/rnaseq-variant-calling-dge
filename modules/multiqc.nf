// MultiQC using apptainer - container
process MULTIQC{
	container 'quay.io/biocontainers/multiqc:1.35--pyhdfd78af_1'
	publishDir "${params.outdir}/multiqc", mode:'copy'

	input:
 	path fastqc_files

	output:
	path "multiqc_report.html"
	path "multiqc_data"

	script:
	"""
	multiqc .
	"""
}
