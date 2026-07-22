// GATK -  Variant Filtration
process VARIANT_FILTRATION {
	container 'quay.io/biocontainers/gatk4:4.6.2.0--py310hdfd78af_1'
	publishDir "${params.outdir}/filtered_variants", mode:'copy'

	input:
	path vcf
	path tbi
	path genome_fasta
	path fai
	path dict

	output:
	path "joint_filtered.vcf.gz", emit:vcf
	path "joint_filtered.vcf.gz.tbi", emit:tbi

	script:
	"""
	gatk VariantFiltration \\
		-R ${genome_fasta} \\
		-V ${vcf} \\
		--window 35 \\
		--cluster 3 \\
		--filter-name "FS" --filter-expression "FS > 30.0" \\
		--filter-name "QD" --filter-expression "QD < 2.0" \\
		-O joint_filtered.vcf.gz
	"""
}

