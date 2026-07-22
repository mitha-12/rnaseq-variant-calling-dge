# RNA-seq Variant Calling & Differential Expression Pipeline

A reproducible **Nextflow** pipeline for human bulk RNA-seq that supports two independent analysis workflows from the same aligned reads:

- **Variant Calling** – GATK RNA-seq Best Practices with joint genotyping and Funcotator annotation
- **Differential Gene Expression (DGE)** – featureCounts → DESeq2 → GO enrichment → network visualization

Designed for **SLURM + Apptainer/Singularity** HPC environments.

## Workflow

```
FASTQ
  ↓
FastQC → fastp → STAR → Read Groups → MarkDuplicates
                │
        ┌───────┴────────┐
        │                │
 Variant Calling       DGE
 SplitNCigarReads      featureCounts
 HaplotypeCaller       DESeq2
 Joint Genotyping      PCA / Volcano / Heatmap
 Variant Filtering     GO Enrichment
 Funcotator            Network Plots
```

Run either workflow independently or both using `--run_mode`.

## Features

- Nextflow DSL2 modular workflow
- GATK RNA-seq variant calling
- Joint genotyping across samples
- Differential expression with DESeq2
- GO enrichment and network visualization
- Containerized with Apptainer/Singularity
- SLURM-ready
- Streamlit results dashboard

## Requirements

- Nextflow ≥25
- SLURM
- Apptainer/Singularity
- Human GRCh38 reference genome & annotation

---

## Dataset

This pipeline was developed and tested on a subset of a public human postmortem brain RNA-seq dataset:

- **GEO series**: [GSE153873](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE153873)
- **BioProject**: PRJNA644383
- **Tissue**: Lateral temporal lobe, postmortem (CNDR brain bank)
- **Platform**: Illumina NextSeq 500, single-end, 75bp
- **Full series**: 11 Alzheimer's disease, 10 aged control, 8 young control samples

For this build, 4 samples were used (2 AD, 2 aged control), selected via NCBI's SRA Run Selector:

| sample_id | condition | SRA Run | GEO Sample |
|---|---|---|---|
| AD1  | AD  | SRR12158133 | GSM4656350 |
| AD2  | AD  | SRR12158138 | GSM4656358 |
| OLD1 | old | SRR12158131 | GSM4656348 |
| OLD2 | old | SRR12158132 | GSM4656349 |

The remaining samples from the full series (9 more AD, 8 more aged, 8 young) can be added the same way to scale up the analysis or enable a three-way AD/aged/young comparison — see [Limitations](#known-limitations-and-future-work).

### Downloading the dataset yourself

```bash
mkdir -p raw_fastq && cd raw_fastq

for srr in SRR12158133 SRR12158138 SRR12158131 SRR12158132; do
  url=$(curl -s "https://www.ebi.ac.uk/ena/portal/api/filereport?accession=${srr}&result=read_run&fields=fastq_ftp" \
        | tail -n1 | cut -f2)
  wget "http://${url}"
done
```

This queries ENA's API for each sample's direct FASTQ download link (more reliable than NCBI's SRA toolkit for this purpose) and downloads all 4 files (~1.5GB each).

Then build `assets/samples.csv` (see [Usage](#usage) below) pointing at the downloaded files.

---

## Usage

```bash
nextflow run main.nf \
    -profile slurm \
    --run_mode both \
    --funcotator_data_sources <path>
```

Available run modes:
- `variant_calling`
- `dge`
- `both` (default)

### Samplesheet format

`assets/samples.csv`:
```csv
sample_id,fastq,condition
AD1,/path/to/raw_fastq/SRR12158133.fastq.gz,AD
AD2,/path/to/raw_fastq/SRR12158138.fastq.gz,AD
OLD1,/path/to/raw_fastq/SRR12158131.fastq.gz,old
OLD2,/path/to/raw_fastq/SRR12158132.fastq.gz,old
```

### One-time setup steps

**Funcotator data sources** (run on the login node — compute nodes on many clusters can't reach Google Cloud Storage):
```bash
bash bin/download_funcotator_data.sh
```

**org.Hs.eg.db** (no combined container exists with clusterProfiler; extracted once and bind-mounted at runtime):
```bash
apptainer pull assets/org_hs_eg_db.img docker://quay.io/biocontainers/bioconductor-org.hs.eg.db:3.20.0--r44hdfd78af_0
mkdir -p assets/org_hs_eg_db
apptainer exec assets/org_hs_eg_db.img cp -r /usr/local/lib/R/library/org.Hs.eg.db assets/org_hs_eg_db/
```

**Environment** (works around node-local `/tmp` reliability issues seen on some clusters):
```bash
export TMPDIR=/path/to/scratch/nxf_tmp
export APPTAINER_TMPDIR=/path/to/scratch/apptainer_tmp
```

Submit the Nextflow orchestrator itself as a SLURM job (not interactively — `-profile slurm` only relocates individual tasks, not the orchestrator):
```bash
sbatch --partition=<partition> --cpus-per-task=2 --mem=4G --time=2-00:00:00 --wrap="\
  cd /path/to/pipeline && nextflow run main.nf -profile slurm --run_mode both \
  --funcotator_data_sources assets/funcotator_dataSources_germline/<extracted-folder>"
```

**Expected runtime**: DGE branch alone, under 30 minutes once containers are cached. Full pipeline including joint genotyping: several hours to potentially 12+, depending on cluster filesystem performance (GenomicsDBImport is I/O-bound and known to perform poorly on network-attached storage).

---

## Results

Demonstrated on the 4-sample dataset above. Outputs include:
- Joint-genotyped VCF
- Annotated variants
- Gene count matrix
- Differential expression results
- PCA, MA, volcano, and heatmap plots
- GO enrichment
- Gene-concept and enrichment network plots
- MultiQC report

**Summary**: 135 significant DE genes (padj < 0.05) between AD and aged-control samples. Top enriched GO terms were antiviral/innate-immune/interferon-response pathways (`OAS1/OAS2/OAS3/MX1/IFI44/IFI44L/RSAD2`), consistent with the well-documented neuroinflammation signature in published AD transcriptomics literature.

All outputs in `results_summary/`.

---

## Dashboard

A Streamlit dashboard is included for exploring pipeline results interactively — DE gene table (filterable by significance), all plots, GO enrichment terms, and pipeline execution metadata.

**Important**: the dashboard visualizes results that have *already been generated* by running the pipeline. It does not run Nextflow itself and does not need HPC access to view existing results. To generate new results (a different dataset, more samples, etc.), you need HPC access to actually run the pipeline as described above — the dashboard is a viewer, not a job submission tool. (A future version may add direct pipeline-triggering from the dashboard; see [Limitations](#known-limitations-and-future-work).)

### Running the dashboard

```bash
pip install streamlit pandas plotly pillow
streamlit run dashboard/app.py
```

Opens in your browser at `http://localhost:8501`. Expects `results_summary/` to exist alongside the dashboard (same layout as this repo).

---

## Known limitations and future work

- **Single-end only.** Paired-end support would require per-sample layout detection and conditional logic in several modules.
- **Strandedness is hardcoded** (`-s 2`, reverse-stranded) based on empirical testing (`-s 0/1/2` comparison) on this specific dataset. A generic version would re-run this check automatically per new dataset.
- **BQSR skipped** — a future iteration could add this with a proper known-sites VCF (dbSNP/1000 Genomes).
- **n=4 samples.** Sufficient to demonstrate the architecture and produce a real, literature-consistent result, but underpowered for strong clinical conclusions. The full source series (11 AD, 10 aged, 8 young) would enable a three-way comparison.
- **Dashboard is view-only.** A future version could let users upload FASTQs and trigger a real pipeline run on connected HPC infrastructure — a substantially larger project (job orchestration, credential handling, async status tracking) intentionally scoped out of this phase.
- **Network analysis** uses gene-concept/enrichment-map views rather than WGCNA (needs more samples) or STRING-based PPI (needs live API access, uncertain on network-restricted compute nodes).

---

## Repository Structure

```
main.nf
nextflow.config
modules/
bin/
slurm_config/
dashboard/
results_summary/
```
