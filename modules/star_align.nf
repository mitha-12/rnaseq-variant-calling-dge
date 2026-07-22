// STAR Alignment
process STAR_ALIGN {
	tag "$sample_id"
	container 'quay.io/biocontainers/star:2.7.11b--h5ca1c30_8'
	publishDir "${params.outdir}/star_align", mode:'copy'

	input:
	tuple val(sample_id), path(fastq)
	path star_index

	output:
	tuple val(sample_id), path("${sample_id}_Aligned.sortedByCoord.out.bam"), emit:bam
	tuple val(sample_id), path("${sample_id}_Log.final.out"), emit:log

	script:
	"""
	STAR \\
		--runMode alignReads \\
		--twopassMode Basic \\
		--genomeDir ${star_index} \\
		--readFilesIn ${fastq} \\
		--readFilesCommand zcat \\
		--outSAMtype BAM SortedByCoordinate \\
		--outFileNamePrefix ${sample_id}_ \\
		--runThreadN ${task.cpus}
	"""
}
