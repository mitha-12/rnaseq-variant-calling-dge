// Create the .dict sequence for GATK
process PREPARE_REFERENCE {
	container 'quay.io/biocontainers/gatk4:4.6.2.0--py310hdfd78af_1'
	publishDir "${params.outdir}/reference", mode: 'copy'

	input:
	path genome_fasta

	output:
	path "*.dict", emit:dict

	script:
	"""
	gatk CreateSequenceDictionary -R ${genome_fasta} -O \$(basename ${genome_fasta} .fa).dict

	"""
}
