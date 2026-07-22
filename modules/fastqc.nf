// FastQC using biocontainers - apptainer
process FASTQC {
	tag "$sample_id"
	container 'quay.io/biocontainers/fastqc:0.12.1--hdfd78af_0'
	// CAUTION: Using mode:'copy' will clone the files and have a permanent copy even when 'work' log is cleared
        // Use mode:'symlink' to use less disk space and when no permanent copy needed

	publishDir "${params.outdir}/fastqc", mode: 'copy'

	input:
	tuple val(sample_id), path(fastq)

	output:
	tuple val(sample_id), path("*_fastqc.html"), emit:html
	tuple val(sample_id), path("*_fastqc.zip"), emit:zip

	script:
	"""
	fastqc ${fastq} --outdir .
	"""
}

