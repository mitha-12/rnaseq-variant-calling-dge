// Combine all gvcfs into one space
process GENOMICS_DB_IMPORT {
	container 'quay.io/biocontainers/gatk4:4.6.2.0--py310hdfd78af_1'
	publishDir "${params.outdir}/genomicsdb", mode:'copy'

	input:
	path gvcfs
	path tbis
	path fai

	output:
	path "genomicsdb_workspace", emit:workspace

	script:
	def gvcf_args = gvcfs.collect { "-V ${it}" }.join(' ')
	"""
	grep -E '^chr([0-9]+|X|Y|M)\\s' ${fai} | awk '{print \$1}' > intervals.list

	gatk GenomicsDBImport \\
		${gvcf_args} \\
		--genomicsdb-workspace-path genomicsdb_workspace \\
		-L intervals.list \\
		--merge-input-intervals
	"""
}
