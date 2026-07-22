// STAR INDEX
process STAR_INDEX {
	container 'quay.io/biocontainers/star:2.7.11b--h5ca1c30_8'
	publishDir "${params.outdir}/star_index", mode:'copy'

	input:
	path genome_fasta
	path gtf

	output:
	path "star_index", emit: index

	script:
	"""

	mkdir star_index
	
	STAR \\
		--runMode genomeGenerate \\
		--genomeDir star_index \\
		--genomeFastaFiles ${genome_fasta} \\
		--sjdbGTFfile ${gtf} \\
		--sjdbOverhang 74 \\
		--runThreadN ${task.cpus}
	"""
}
