#!/bin/bash
set -euo pipefail

# Usage: download_funcotator_data.sh <apptainer_cache_dir> [output_dir]
CACHE_DIR="${1:?Usage: download_funcotator_data.sh <apptainer_cache_dir> [output_dir]}"
OUTDIR="${2:-./assets/funcotator_dataSources_germline}"

echo "Downloading Funcotator germline data sources to: ${OUTDIR}"

apptainer exec "${CACHE_DIR}/quay.io-biocontainers-gatk4-4.6.2.0--py310hdfd78af_1.img" \
  gatk FuncotatorDataSourceDownloader --germline --validate-integrity --extract-after-download --hg38 -O "${OUTDIR}"

echo "Done. Run the pipeline with:"
echo "  --funcotator_data_sources ${OUTDIR}"
