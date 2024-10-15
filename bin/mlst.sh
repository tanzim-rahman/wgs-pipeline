#!/usr/bin/env bash

source /home/igc-1/anaconda3/etc/profile.d/conda.sh

conda activate wgs

source config.sh

mkdir -p ${MLST_DIR}

# if [[ ${fasta} = *.gz ]]
# then
#     unzipped_fasta=\$(basename ${fasta} .gz)
#     gunzip --force ${fasta}
# else
#     unzipped_fasta=${fasta}
# fi

# mlst \
#     --threads 30 \
#     ${SPADES_DIR}/${SAMPLE_NAME}.filtered.scaffolds.fa.gz \
#     > ${MLST_DIR}/${SAMPLE_NAME}.tsv

SCHEME=$( tail -n1 ${MLST_DIR}/${SAMPLE_NAME}.tsv | cut -f2 )

if [[ ${SCHEME} == "abaumannii_2" ]]; then
    mv ${MLST_DIR}/${SAMPLE_NAME}.tsv ${MLST_DIR}/${SAMPLE_NAME}_1.tsv
    mlst --scheme abaumannii --threads 30 \$unzipped_fasta > ${MLST_DIR}/${SAMPLE_NAME}_2.tsv
    cat ${MLST_DIR}/${SAMPLE_NAME}_1.tsv ${MLST_DIR}/${SAMPLE_NAME}_2.tsv > ${MLST_DIR}/${SAMPLE_NAME}.tsv
    rm ${MLST_DIR}/${SAMPLE_NAME}_*.tsv
elif [[ ${SCHEME} == "abaumannii" ]]; then
    mv ${MLST_DIR}/${SAMPLE_NAME}.tsv ${MLST_DIR}/${SAMPLE_NAME}_1.tsv
    mlst --scheme abaumannii_2 --threads 30 \$unzipped_fasta > ${MLST_DIR}/${SAMPLE_NAME}_2.tsv
    cat ${MLST_DIR}/${SAMPLE_NAME}_1.tsv ${MLST_DIR}/${SAMPLE_NAME}_2.tsv > ${MLST_DIR}/${SAMPLE_NAME}.tsv
    rm ${MLST_DIR}/${SAMPLE_NAME}_*.tsv
elif [[ ${SCHEME} == "ecoli" ]]; then
    mv ${MLST_DIR}/${SAMPLE_NAME}.tsv ${MLST_DIR}/${SAMPLE_NAME}_1.tsv
    mlst --scheme ecoli_2 --threads 30 \$unzipped_fasta > ${MLST_DIR}/${SAMPLE_NAME}_2.tsv
    cat ${MLST_DIR}/${SAMPLE_NAME}_1.tsv ${MLST_DIR}/${SAMPLE_NAME}_2.tsv > ${MLST_DIR}/${SAMPLE_NAME}.tsv
    rm ${MLST_DIR}/${SAMPLE_NAME}_*.tsv
elif [[ ${SCHEME} == "ecoli_2" ]]; then
    mv ${MLST_DIR}/${SAMPLE_NAME}.tsv ${MLST_DIR}/${SAMPLE_NAME}_1.tsv
    mlst --scheme ecoli --threads 30 \$unzipped_fasta > ${MLST_DIR}/${SAMPLE_NAME}_2.tsv
    cat ${MLST_DIR}/${SAMPLE_NAME}_1.tsv ${MLST_DIR}/${SAMPLE_NAME}_2.tsv > ${MLST_DIR}/${SAMPLE_NAME}.tsv
    rm ${MLST_DIR}/${SAMPLE_NAME}_*.tsv
else
    :
fi

# # Add in generic header
# sed -i '1i source_file  Database  ST  locus_1 locus_2 locus_3 locus_4 locus_5 locus_6 locus_7 locus_8 lous_9  locus_10' ${MLST_DIR}/${SAMPLE_NAME}.tsv

# #handling to get database version being used
# if [[ $terra == false ]]; then
#     db_version=\$(cat /mlst-${mlst_version_cleaned}/db/db_version | date -f - +%Y-%m-%d )
# else
#     db_version=\$(cat /opt/conda/envs/phoenix/db/db_version | date -f - +%Y-%m-%d )
# fi

conda deactivate
