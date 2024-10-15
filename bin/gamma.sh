#!/usr/bin/env bash

source /home/igc-1/anaconda3/etc/profile.d/conda.sh

conda activate wgs

source config.sh

mkdir -p ${GAMMA_DIR}

FILE="${SPADES_DIR}/${SAMPLE_NAME}.filtered.scaffolds.fa"

gunzip -f "${FILE}.gz"

DB_NAME=$(echo ${GAMMA_HVDB} | sed 's:.*/::' | sed 's/.fasta//')

GAMMA.py \
    ${FILE} \
    ${GAMMA_HVDB} \
    ${GAMMA_DIR}/${SAMPLE_NAME}_${DB_NAME}

DB_NAME=$(echo ${GAMMA_ARDB} | sed 's:.*/::' | sed 's/.fasta//')

GAMMA.py \
    ${FILE} \
    ${GAMMA_ARDB} \
    ${GAMMA_DIR}/${SAMPLE_NAME}_${DB_NAME}

DB_NAME=$(echo ${GAMMA_DBPF} | sed 's:.*/::' | sed 's/.fasta//')

GAMMA-S.py \
    ${FILE} \
    ${GAMMA_DBPF} \
    ${GAMMA_DIR}/${SAMPLE_NAME}_${DB_NAME}

gzip ${FILE}

conda deactivate
