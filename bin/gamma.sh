#!/usr/bin/env bash

source config.sh

source ${CONDA_LOCATION}

conda activate ${CONDA_ENV_GAMMA}

mkdir -p ${GAMMA_DIR}

FILE="${SPADES_DIR}/${SAMPLE_NAME}.filtered.scaffolds.fa"

gunzip -f "${FILE}.gz"

GAMMA.py \
    ${FILE} \
    ${GAMMA_HVDB} \
    ${GAMMA_DIR}/${SAMPLE_NAME}_${DB_NAME_HV}

GAMMA.py \
    ${FILE} \
    ${GAMMA_ARDB} \
    ${GAMMA_DIR}/${SAMPLE_NAME}_${DB_NAME_AR}

GAMMA-S.py \
    ${FILE} \
    ${GAMMA_DBPF} \
    ${GAMMA_DIR}/${SAMPLE_NAME}_${DB_NAME_PF}

gzip ${FILE}

conda deactivate
