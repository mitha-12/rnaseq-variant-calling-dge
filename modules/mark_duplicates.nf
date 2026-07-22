// Picard - MarkDuplicates - flags PCR duplicates for GATK
process MARK_DUPLICATES {
	tag "$sample_id"
	container 'quay.io/biocontainers/picard:3.4.0--hdfd78af_0'
	publishDir "${params.outdir}/deduplication", mode:'copy'

	input:
	tuple val(sample_id), path(bam)

	output:
	tuple val(sample_id), path("${sample_id}_dedup.bam"), emit:bam
	tuple val(sample_id), path("${sample_id}_dup_metrics.txt"), emit:metrics

	script:
	"""
	picard MarkDuplicates \\
		I=${bam} \\
		O=${sample_id}_dedup.bam \\
		M=${sample_id}_dup_metrics.txt
	"""
}
