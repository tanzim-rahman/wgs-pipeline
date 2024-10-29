#!/usr/bin/env bash

source ${CONDA_LOCATION}

conda activate ${CONDA_ENV_KRAKEN2}

mkdir -p ${KRAKEN_ASSEMBLY_DIR}

kraken2 \
    --db ${KRAKEN_DB} \
    --threads ${THREADS} \
    --report ${KRAKEN_ASSEMBLY_DIR}/${SAMPLE_NAME}.kraken2_wtasmbld.summary.txt \
    --gzip-compressed \
    --unclassified-out ${KRAKEN_ASSEMBLY_DIR}/${SAMPLE_NAME}_wtasmbld.unclassified.fasta \
    --classified-out ${KRAKEN_ASSEMBLY_DIR}/${SAMPLE_NAME}_wtasmbld.classified.fasta \
    --output ${KRAKEN_ASSEMBLY_DIR}/${SAMPLE_NAME}.kraken2_wtasmbld.classifiedreads.txt \
    ${SPADES_DIR}/${SAMPLE_NAME}.filtered.scaffolds.fa.gz

gzip ${KRAKEN_ASSEMBLY_DIR}/*.fasta

${WORK_DIR}/bin/phoenix/make_kreport.py \
    --input ${KRAKEN_ASSEMBLY_DIR}/${SAMPLE_NAME}.kraken2_wtasmbld.classifiedreads.txt \
    --output ${KRAKEN_ASSEMBLY_DIR}/${SAMPLE_NAME}.kraken2_wtasmbld.summary.txt \
    --taxonomy ${KRAKEN_DB}/ktaxonomy.tsv \
    --use-read-len

${WORK_DIR}/bin/phoenix/kreport2krona.py \
    --report ${KRAKEN_ASSEMBLY_DIR}/${SAMPLE_NAME}.kraken2_wtasmbld.summary.txt \
    --output ${KRAKEN_ASSEMBLY_DIR}/${SAMPLE_NAME}_wtasmbld.krona

${WORK_DIR}/bin/phoenix/kraken2_best_hit.sh \
    -i ${KRAKEN_ASSEMBLY_DIR}/${SAMPLE_NAME}.kraken2_wtasmbld.summary.txt \
    -q ${QUAST_DIR}/report.tsv \
    -n ${SAMPLE_NAME}

mv ${SAMPLE_NAME}.summary.txt ${KRAKEN_ASSEMBLY_DIR}/${SAMPLE_NAME}.kraken2_wtasmbld.top_kraken_hit.txt

conda deactivate

conda activate ${CONDA_ENV_KRONATOOLS}

ktImportText  \
    -o ${KRAKEN_ASSEMBLY_DIR}/${SAMPLE_NAME}_wtasmbld.krona.html \
    ${KRAKEN_ASSEMBLY_DIR}/${SAMPLE_NAME}_wtasmbld.krona

conda deactivate
