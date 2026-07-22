// Funcotator germline annotation download
process FUNCOTATOR_DATA_SOURCES {
	container 'quay.io/biocontainers/gatk4:4.6.2.0--py310hdfd78af_1'
	publishDir "${params.outdir}/funcotator_data_sources", mode:'copy'

	output:
	path "funcotator_dataSources*", emit: data_sources

	script:
	"""
	gatk FuncotatorDataSourceDownloader \\
		--germline \\
		--validate-integrity \\
		--extract-after-download \\
		--hg38 \\
		-O funcotator_dataSources_germline
	"""
}
