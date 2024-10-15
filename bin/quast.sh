#!/usr/bin/env bash

source /home/igc-1/anaconda3/etc/profile.d/conda.sh

conda activate wgs

source config.sh

mkdir -p ${QUAST_DIR}

quast.py \
    --output-dir ${QUAST_DIR} \
    --threads 30 \
    ${SPADES_DIR}/${SAMPLE_NAME}.filtered.scaffolds.fa.gz

conda deactivate
