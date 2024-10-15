#!/usr/bin/env bash

source /home/igc-1/anaconda3/etc/profile.d/conda.sh

conda activate wgs

source config.sh

mkdir -p ${KRAKEN_ASSEMBLY_DIR}

kraken2 \
    --db ${KRAKEN_DB} \
    --threads 30 \
    --report ${KRAKEN_ASSEMBLY_DIR}/${SAMPLE_NAME}.kraken2_wtasmbld.summary.txt \
    --gzip-compressed \
    --unclassified-out ${KRAKEN_ASSEMBLY_DIR}/${SAMPLE_NAME}_wtasmbld.unclassified.fasta \
    --classified-out ${KRAKEN_ASSEMBLY_DIR}/${SAMPLE_NAME}_wtasmbld.classified.fasta \
    --output ${KRAKEN_ASSEMBLY_DIR}/${SAMPLE_NAME}.kraken2_wtasmbld.classifiedreads.txt \
    ${SPADES_DIR}/${SAMPLE_NAME}.filtered.scaffolds.fa.gz

gzip ${KRAKEN_ASSEMBLY_DIR}/*.fasta

./bin/phoenix/make_kreport.py \
    --input ${KRAKEN_ASSEMBLY_DIR}/${SAMPLE_NAME}.kraken2_wtasmbld.classifiedreads.txt \
    --output ${KRAKEN_ASSEMBLY_DIR}/${SAMPLE_NAME}.kraken2_wtasmbld.summary.txt \
    --taxonomy ${KRAKEN_DB}/ktaxonomy.tsv \
    --use-read-len

./bin/phoenix/kreport2krona.py \
    --report ${KRAKEN_ASSEMBLY_DIR}/${SAMPLE_NAME}.kraken2_wtasmbld.summary.txt \
    --output ${KRAKEN_ASSEMBLY_DIR}/${SAMPLE_NAME}_wtasmbld.krona

./bin/phoenix/kraken2_best_hit.sh \
    -i ${KRAKEN_ASSEMBLY_DIR}/${SAMPLE_NAME}.kraken2_wtasmbld.summary.txt \
    -q ${QUAST_DIR}/report.tsv \
    -n ${SAMPLE_NAME}

mv ${SAMPLE_NAME}.summary.txt ${KRAKEN_ASSEMBLY_DIR}/${SAMPLE_NAME}.kraken2_wtasmbld.top_kraken_hit.txt

ktImportText  \
    -o ${KRAKEN_ASSEMBLY_DIR}/${SAMPLE_NAME}_wtasmbld.krona.html \
    ${KRAKEN_ASSEMBLY_DIR}/${SAMPLE_NAME}_wtasmbld.krona

conda deactivate
