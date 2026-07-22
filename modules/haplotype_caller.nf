// Variant Calling - HaplotypeCaller
process HAPLOTYPE_CALLER {
	tag "$sample_id"
	container 'quay.io/biocontainers/gatk4:4.6.2.0--py310hdfd78af_1'
	publishDir "${params.outdir}/variants", mode:'copy'

	input:
	tuple val(sample_id), path(bam)
	path genome_fasta
	path fai
	path dict

	output:
	tuple val(sample_id), path("${sample_id}.g.vcf.gz"), emit:gvcf
	tuple val(sample_id), path("${sample_id}.g.vcf.gz.tbi"), emit:tbi

	script:
	"""
	gatk HaplotypeCaller \\
		-R ${genome_fasta} \\
		-I ${bam} \\
		-O ${sample_id}.g.vcf.gz \\
		-ERC GVCF \\
		--dont-use-soft-clipped-bases \\
		--standard-min-confidence-threshold-for-calling 20
	"""
}
