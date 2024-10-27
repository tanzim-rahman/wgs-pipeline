#!/usr/bin/env bash

source config.sh

source ${CONDA_LOCATION}

conda activate ${CONDA_ENV_SPADES}

mkdir -p ${SPADES_DIR}

spades.py \
    --threads 30 \
    --memory 120 \
    -s ${QC_DIR}/${SAMPLE_NAME}.singles.fastq.gz \
    -1 ${QC_DIR}/${SAMPLE_NAME}_R1_trimmed_fastp.fastq.gz \
    -2 ${QC_DIR}/${SAMPLE_NAME}_R2_trimmed_fastp.fastq.gz \
    --phred-offset 33 \
    -o ${SPADES_DIR}/

${WORK_DIR}/bin/phoenix/rename_fasta_headers.py \
    --input ${SPADES_DIR}/scaffolds.fasta \
    --output ${SPADES_DIR}/${SAMPLE_NAME}.renamed.scaffolds.fa \
    --name ${SAMPLE_NAME}

gzip --force ${SPADES_DIR}/${SAMPLE_NAME}.renamed.scaffolds.fa

conda deactivate

conda activate ${CONDA_ENV_BBMAP}

reformat.sh \
    -Xmx120g \
    in=${SPADES_DIR}/${SAMPLE_NAME}.renamed.scaffolds.fa.gz \
    out=${SPADES_DIR}/${SAMPLE_NAME}.filtered.scaffolds.fa.gz \
    threads=30 \
    minlength=500 \
    &> ${SPADES_DIR}/${SAMPLE_NAME}.bbmap_filtered.log

conda deactivate
