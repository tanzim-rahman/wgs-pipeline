#!/usr/bin/env bash

source ${CONDA_LOCATION}

conda activate ${CONDA_ENV_QUAST}

mkdir -p ${QUAST_DIR}

quast.py \
    --output-dir ${QUAST_DIR} \
    --threads 30 \
    ${SPADES_DIR}/${SAMPLE_NAME}.filtered.scaffolds.fa.gz

conda deactivate
