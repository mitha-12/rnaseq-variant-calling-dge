// Picard - Add read groups - GATK requires (@RG)
process ADD_READGROUPS {
	tag "$sample_id"
	container 'quay.io/biocontainers/picard:3.4.0--hdfd78af_0'
	publishDir "${params.outdir}/readgroups", mode:'copy'

	input:
	tuple val(sample_id), path(bam)

	output:
	tuple val(sample_id), path("${sample_id}_rg.bam"), emit:bam

	script:
	"""
	picard AddOrReplaceReadGroups \\
		I=${bam} \\
		O=${sample_id}_rg.bam \\
		RGID=${sample_id} \\
		RGLB=lib1 \\
		RGPL=ILLUMINA \\
		RGPU=unit1 \\
		RGSM=${sample_id}
	"""
}
