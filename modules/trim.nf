// Trimming - using fastp - container
process TRIM {
	tag "$sample_id"
	container 'quay.io/biocontainers/fastp:1.3.6--h43da1c4_0'
	publishDir "${params.outdir}/trimmed", mode:'copy'

	input:
	tuple val(sample_id), path(fastq)

	output:
	tuple val(sample_id), path("${sample_id}_trimmed.fastq.gz"), emit:reads
	tuple val(sample_id), path("${sample_id}_fastp.json"), emit:json
	tuple val(sample_id), path("${sample_id}_fastp.html"),emit:html

	script:
	"""
	fastp \\
		-i ${fastq} \\
		-o ${sample_id}_trimmed.fastq.gz \\
		--qualified_quality_phred 20 \\
		--length_required 36 \\
		--json ${sample_id}_fastp.json \\
		--html ${sample_id}_fastp.html \\
		--thread ${task.cpus}
	"""
}
