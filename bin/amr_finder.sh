#!/usr/bin/env bash

source ${CONDA_LOCATION}

conda activate wgs

source config.sh

mkdir -p ${AMR_DIR}

gunzip ${SPADES_DIR}/${SAMPLE_NAME}.filtered.scaffolds.fa.gz

prokka \
    --cpus 30 \
    --prefix ${SAMPLE_NAME} \
    --outdir ${AMR_DIR}/prokka_outputs \
    --force \
    ${SPADES_DIR}/${SAMPLE_NAME}.filtered.scaffolds.fa

gzip ${SPADES_DIR}/${SAMPLE_NAME}.filtered.scaffolds.fa

${WORK_DIR}/bin/phoenix/get_taxa_for_amrfinder.py -t ${MASH_DIR}/${SAMPLE_NAME}.tax -o ${AMR_DIR}/${SAMPLE_NAME}_AMRFinder_Organism.csv

conda deactivate

conda activate amrfinder

IFS=$'\n' read -r -d '' -a ORGANISMS < ${AMR_DIR}/${SAMPLE_NAME}_AMRFinder_Organism.csv

if [ "${ORGANISMS[0]}" != "No Match Found" ]; then
    organism="--organism ${ORGANISMS[0]}"
else
    organism=""
fi

amrfinder \
    --nucleotide ${SPADES_DIR}/${SAMPLE_NAME}.filtered.scaffolds.fa.gz \
    --protein ${AMR_DIR}/prokka_outputs/${SAMPLE_NAME}.faa \
    --gff ${AMR_DIR}/prokka_outputs/${SAMPLE_NAME}.gff \
    --annotation_format prokka \
    --mutation_all ${AMR_DIR}/${SAMPLE_NAME}_all_mutations.tsv \
    $organism \
    --plus \
    --threads 30 \
    > ${AMR_DIR}/${SAMPLE_NAME}_all_genes.tsv

sed -i '1s/ /_/g' ${AMR_DIR}/${SAMPLE_NAME}_all_genes.tsv

conda deactivate
