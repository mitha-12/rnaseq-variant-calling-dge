// featuresCounts
process FEATURECOUNTS {
	container 'quay.io/biocontainers/subread:2.1.1--h577a1d6_0'
	publishDir "${params.outdir}/featurecounts", mode:'copy'

	input:
	path bams
	path gtf

	output:
	path "gene_counts.txt", emit: counts
	path "gene_counts.txt.summary", emit: summary

	script:
	"""
	featureCounts \\
		-T ${task.cpus} \\
		-a ${gtf} \\
		--primary \\
		-Q 10 \\
		-s 2 \\
		-o gene_counts.txt \\
		${bams}
	"""
}
