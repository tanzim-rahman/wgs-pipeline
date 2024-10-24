#!/usr/bin/env bash

source /home/igc-1/anaconda3/etc/profile.d/conda.sh

conda activate wgs

source config.sh

mkdir -p ${SPADES_DIR}

spades.py \
    --threads 30 \
    --memory 120 \
    -s ${QC_DIR}/${SAMPLE_NAME}.singles.fastq.gz \
    -1 ${QC_DIR}/${SAMPLE_NAME}_R1_trimmed_fastp.fastq.gz \
    -2 ${QC_DIR}/${SAMPLE_NAME}_R2_trimmed_fastp.fastq.gz \
    --phred-offset 33 \
    -o ${SPADES_DIR}/

./bin/phoenix/rename_fasta_headers.py \
    --input ${SPADES_DIR}/scaffolds.fasta \
    --output ${SPADES_DIR}/${SAMPLE_NAME}.renamed.scaffolds.fa \
    --name ${SAMPLE_NAME}

gzip --force ${SPADES_DIR}/${SAMPLE_NAME}.renamed.scaffolds.fa

reformat.sh \
    -Xmx120g \
    in=${SPADES_DIR}/${SAMPLE_NAME}.renamed.scaffolds.fa.gz \
    out=${SPADES_DIR}/${SAMPLE_NAME}.filtered.scaffolds.fa.gz \
    threads=30 \
    minlength=500 \
    &> ${SPADES_DIR}/${SAMPLE_NAME}.bbmap_filtered.log

conda deactivate
