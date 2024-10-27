#!/usr/bin/env bash

source ${CONDA_LOCATION}

conda activate ${CONDA_ENV_MASH}

source config.sh

mkdir -p ${MASH_DIR}

if [[ ${ZIPPED_SKETCH} = *.gz ]]; then
    pigz -vdf ${ZIPPED_SKETCH}
else
    :
fi

mash \
    dist \
    -p 30 \
    ${MASH_DB} \
    ${SPADES_DIR}/${SAMPLE_NAME}.filtered.scaffolds.fa.gz > ${MASH_DIR}/${SAMPLE_NAME}_${MASH_DB_VERSION}.txt

mkdir -p ${MASH_DIR}/reference_dir

${WORK_DIR}/bin/phoenix/sort_and_prep_dist.sh \
    -a ${SPADES_DIR}/${SAMPLE_NAME}.filtered.scaffolds.fa.gz \
    -x ${MASH_DIR}/${SAMPLE_NAME}_${MASH_DB_VERSION}.txt \
    -o ${MASH_DIR}/reference_dir

mv ${SAMPLE_NAME}_${MASH_DB_VERSION}_best_MASH_hits.txt ${MASH_DIR}/${SAMPLE_NAME}_${MASH_DB_VERSION}_best_MASH_hits.txt

conda deactivate

conda activate ${CONDA_ENV_FASTANI}

fastANI \
    -q ${SPADES_DIR}/${SAMPLE_NAME}.filtered.scaffolds.fa.gz \
    --rl ${MASH_DIR}/${SAMPLE_NAME}_${MASH_DB_VERSION}_best_MASH_hits.txt \
    -o ${MASH_DIR}/${SAMPLE_NAME}_${MASH_DB_VERSION}.ani.txt

${WORK_DIR}/bin/phoenix/ANI_best_hit_formatter.sh \
    -a ${MASH_DIR}/${SAMPLE_NAME}_${MASH_DB_VERSION}.ani.txt \
    -n ${SAMPLE_NAME} \
    -d ${MASH_DB_VERSION}

mv ${SAMPLE_NAME}_${MASH_DB_VERSION}.fastANI.txt ${MASH_DIR}/${SAMPLE_NAME}_${MASH_DB_VERSION}.fastANI.txt

${WORK_DIR}/bin/phoenix/determine_taxID.sh \
    -k ${KRAKEN_ASSEMBLY_DIR}/${SAMPLE_NAME}.kraken2_wtasmbld.summary.txt \
    -s ${SAMPLE_NAME} \
    -f ${MASH_DIR}/${SAMPLE_NAME}_${MASH_DB_VERSION}.fastANI.txt \
    -d ${TAXA} \
    -r ${KRAKEN_TRIMMED_DIR}/${SAMPLE_NAME}.kraken2_trimmed.top_kraken_hit.txt

mv ${SAMPLE_NAME}.tax ${MASH_DIR}/${SAMPLE_NAME}.tax

conda deactivate
