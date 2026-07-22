// GATK Functator
process FUNCOTATOR {
	container 'quay.io/biocontainers/gatk4:4.6.2.0--py310hdfd78af_1'
	publishDir "${params.outdir}/annotated_variants", mode:'copy'

	input:
	path vcf
	path tbi
	path genome_fasta
	path fai
	path dict
	path data_sources

	output:
	path "joint_annotated.vcf.gz", emit:vcf
	path "joint_annotated.vcf.gz.tbi", emit:tbi

	script:
	"""
	gatk Funcotator \\
		-R ${genome_fasta} \\
		-V ${vcf} \\
		-O joint_annotated.vcf.gz \\
		--output-file-format VCF \\
		--data-sources-path ${data_sources} \\
		--ref-version hg38
	"""
}
