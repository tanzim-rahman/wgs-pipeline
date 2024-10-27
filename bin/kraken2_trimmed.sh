#!/usr/bin/env bash

source config.sh

source ${CONDA_LOCATION}

conda activate ${CONDA_ENV_KRAKEN2}

mkdir -p ${KRAKEN_TRIMMED_DIR}

kraken2 \
    --db ${KRAKEN_DB} \
    --threads 30 \
    --report ${KRAKEN_TRIMMED_DIR}/${SAMPLE_NAME}.kraken2_trimmed.summary.txt \
    --gzip-compressed \
    --unclassified-out ${KRAKEN_TRIMMED_DIR}/${SAMPLE_NAME}_trimmed.unclassified#.fasta \
    --classified-out ${KRAKEN_TRIMMED_DIR}/${SAMPLE_NAME}_trimmed.classified#.fasta \
    --output ${KRAKEN_TRIMMED_DIR}/${SAMPLE_NAME}.kraken2_trimmed.classifiedreads.txt \
    --paired \
    ${QC_DIR}/${SAMPLE_NAME}_R1_trimmed_fastp.fastq.gz \
    ${QC_DIR}/${SAMPLE_NAME}_R2_trimmed_fastp.fastq.gz

gzip ${KRAKEN_TRIMMED_DIR}/*.fasta

${WORK_DIR}/bin/phoenix/kreport2mpa.py \
    --report-file ${KRAKEN_TRIMMED_DIR}/${SAMPLE_NAME}.kraken2_trimmed.summary.txt \
    --output ${KRAKEN_TRIMMED_DIR}/${SAMPLE_NAME}_trimmed.mpa

${WORK_DIR}/bin/phoenix/kreport2krona.py \
    --report ${KRAKEN_TRIMMED_DIR}/${SAMPLE_NAME}.kraken2_trimmed.summary.txt \
    --output ${KRAKEN_TRIMMED_DIR}/${SAMPLE_NAME}_trimmed.krona

conda deactivate

conda activate ${CONDA_ENV_KRONATOOLS}

ktImportText  \
    -o ${KRAKEN_TRIMMED_DIR}/${SAMPLE_NAME}_trimmed.krona.html \
    ${KRAKEN_TRIMMED_DIR}/${SAMPLE_NAME}_trimmed.krona

${WORK_DIR}/bin/phoenix/kraken2_best_hit.sh \
    -i ${KRAKEN_TRIMMED_DIR}/${SAMPLE_NAME}.kraken2_trimmed.summary.txt \
    -q ${QC_DIR}/${SAMPLE_NAME}_trimmed_read_counts.txt \
    -n ${SAMPLE_NAME}

mv ${SAMPLE_NAME}.summary.txt ${KRAKEN_TRIMMED_DIR}/${SAMPLE_NAME}.kraken2_trimmed.top_kraken_hit.txt

conda deactivate
