// SplitNCigarReads - GATK pre-processing step
process SPLIT_NCIGAR {
	tag "$sample_id"
	container 'quay.io/biocontainers/gatk4:4.6.2.0--py310hdfd78af_1'
	publishDir "${params.outdir}/split_ncigar", mode:'copy'

	input:
	tuple val(sample_id), path(bam)
	path genome_fasta
	path fai
	path dict

	output:
	tuple val(sample_id), path("${sample_id}_split.bam"), emit:bam

	script:
	"""
	gatk SplitNCigarReads \\
		-R ${genome_fasta} \\
		-I ${bam} \\
		-O ${sample_id}_split.bam
	"""
}
