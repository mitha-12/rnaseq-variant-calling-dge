// samtools faidx - cretes .fai index for GATK
process INDEX_FASTA {
	container 'quay.io/biocontainers/samtools:1.22.1--h96c455f_0'
	publishDir "${params.outdir}/reference", mode:'copy'

	input:
	path genome_fasta

	output:
	path "${genome_fasta}.fai", emit: fai

	script:
	"""
	samtools faidx ${genome_fasta}
	"""
}
	
