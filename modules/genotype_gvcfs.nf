// Produce joint genotype -- using vcf from GenomicsDB space
process GENOTYPE_GVCFS {
	container 'quay.io/biocontainers/gatk4:4.6.2.0--py310hdfd78af_1'
	publishDir "${params.outdir}/joint_variants", mode:'copy'

	input:
	path workspace
	path genome_fasta
	path fai
	path dict

	output:
	path "joint_genotyped.vcf.gz", emit:vcf
	path "joint_genotyped.vcf.gz.tbi", emit:tbi
	
	script:
	"""
	gatk GenotypeGVCFs \\
		-R ${genome_fasta} \\
		-V gendb://${workspace} \\
		-O joint_genotyped.vcf.gz
	"""
}
