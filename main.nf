#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

// params
params.reads = "${projectDir}/assets/samples.csv"
params.genome_fasta = "${projectDir}/assets/GRCh38.primary_assembly.genome.fa"
params.gtf = "${projectDir}/assets/gencode.v50.primary_assembly.annotation.gtf"
params.outdir = "${projectDir}/results"
params.variant_caller = 'gatk'
params.funcotator_data_sources = null
params.org_hs_eg_db_path = "${projectDir}/assets/org_hs_eg_db/org.Hs.eg.db"

// Dashboard purpose - branches to run -- variant_calling, dge, both
params.run_mode = 'both'

def valid_modes = ['variant_calling', 'dge', 'both']
if (!(params.run_mode in valid_modes)) {
	error "Invalid run mode. Must be one of ${valid_modes.join(', ')}"
}
def run_variants = params.run_mode in ['variant_calling', 'both']
def run_dge = params.run_mode in ['dge', 'both']

// import modules
include {FASTQC} from './modules/fastqc.nf'
include {MULTIQC} from './modules/multiqc.nf'
include {TRIM} from './modules/trim.nf'
include {STAR_INDEX} from './modules/star_index.nf'
include {STAR_ALIGN} from './modules/star_align.nf'
include {ADD_READGROUPS} from './modules/add_readgroups.nf'
include {MARK_DUPLICATES} from './modules/mark_duplicates.nf'
include {INDEX_FASTA} from './modules/index_fasta.nf'
include {PREPARE_REFERENCE} from './modules/prepare_reference.nf'
include {SPLIT_NCIGAR} from './modules/split_ncigar.nf'
include {HAPLOTYPE_CALLER} from './modules/haplotype_caller.nf'
include {GENOMICS_DB_IMPORT} from './modules/genomics_db_import.nf'
include {GENOTYPE_GVCFS} from './modules/genotype_gvcfs.nf'
include {VARIANT_FILTRATION} from './modules/variant_filtration.nf'
include {FUNCOTATOR_DATA_SOURCES} from './modules/funcotator_data_sources.nf'
include {FUNCOTATOR} from './modules/funcotator.nf'
include {FEATURECOUNTS} from './modules/featurecounts.nf'
include {DESEQ2} from './modules/deseq2.nf'
include {PLOT_DESEQ2} from './modules/plot_deseq2.nf'
include {GO_ENRICHMENT} from './modules/go_enrichment.nf'
include {NETWORK_PLOTS} from './modules/network_plots.nf'

// workflow
workflow {
	log.info """
	RNAseq Pipeline
	Reads: 		${params.reads}
	Genome FASTA: 	${params.genome_fasta}
	GTF: 		${params.gtf}
	Outdir: 	${params.outdir}
	"""

	// input channel
	reads_ch = Channel.fromPath(params.reads)
			.splitCsv(header:true)
			.map {row ->tuple(row.sample_id, file(row.fastq))}

	FASTQC(reads_ch)
	TRIM(reads_ch)

	//Build STAR index
	STAR_INDEX(file(params.genome_fasta), file(params.gtf))
	// Read alignment
	STAR_ALIGN(TRIM.out.reads, STAR_INDEX.out.index)

	//Picard
	ADD_READGROUPS(STAR_ALIGN.out.bam)
	MARK_DUPLICATES(ADD_READGROUPS.out.bam)

// Variant-calling branch
	if (run_variants) {
		INDEX_FASTA(file(params.genome_fasta))
		PREPARE_REFERENCE(file(params.genome_fasta))
		SPLIT_NCIGAR(MARK_DUPLICATES.out.bam, file(params.genome_fasta), INDEX_FASTA.out.fai, PREPARE_REFERENCE.out.dict)	

		HAPLOTYPE_CALLER(SPLIT_NCIGAR.out.bam, file(params.genome_fasta), INDEX_FASTA.out.fai, PREPARE_REFERENCE.out.dict)	

	// Joint genotyping
		GENOMICS_DB_IMPORT(
			HAPLOTYPE_CALLER.out.gvcf.map { sample_id, gvcf ->gvcf }.collect(),
			HAPLOTYPE_CALLER.out.tbi.map { sample_id, tbi -> tbi }.collect(),
			INDEX_FASTA.out.fai
		)

		GENOTYPE_GVCFS(GENOMICS_DB_IMPORT.out.workspace, file(params.genome_fasta), INDEX_FASTA.out.fai, PREPARE_REFERENCE.out.dict)

		VARIANT_FILTRATION(GENOTYPE_GVCFS.out.vcf, GENOTYPE_GVCFS.out.tbi, file (params.genome_fasta), INDEX_FASTA.out.fai, PREPARE_REFERENCE.out.dict)	

		// Download only if the sources doesn't exist
		def data_sources_ch
		if (params.funcotator_data_sources) {
			data_sources_ch = Channel.fromPath(params.funcotator_data_sources)
		} else {
			FUNCOTATOR_DATA_SOURCES()
			data_sources_ch = FUNCOTATOR_DATA_SOURCES.out.data_sources
		}	

		FUNCOTATOR(VARIANT_FILTRATION.out.vcf, VARIANT_FILTRATION.out.tbi, file(params.genome_fasta), INDEX_FASTA.out.fai, PREPARE_REFERENCE.out.dict, data_sources_ch)
	}

	// DGE branch
	if (run_dge) {
		FEATURECOUNTS(
			MARK_DUPLICATES.out.bam.map {sample_id, bam -> bam}.collect(),
			file(params.gtf)
		)

		DESEQ2(FEATURECOUNTS.out.counts, file(params.reads))
	
		PLOT_DESEQ2(DESEQ2.out.dds, DESEQ2.out.results)

		GO_ENRICHMENT(DESEQ2.out.results)

		NETWORK_PLOTS(DESEQ2.out.results)	

	}

	MULTIQC(FASTQC.out.zip.map {sample_id, zip -> zip}.collect())
	

}


