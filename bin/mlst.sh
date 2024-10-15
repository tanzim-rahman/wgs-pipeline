#!/usr/bin/env bash

source /home/igc-1/anaconda3/etc/profile.d/conda.sh

conda activate wgs

source config.sh

mkdir -p ${MLST_DIR}

mlst \
    --threads 30 \
    ${SPADES_DIR}/${SAMPLE_NAME}.filtered.scaffolds.fa.gz \
    > ${MLST_DIR}/${SAMPLE_NAME}.tsv

SCHEME=$( tail -n1 ${MLST_DIR}/${SAMPLE_NAME}.tsv | cut -f2 )

if [[ ${SCHEME} == "abaumannii_2" ]]; then
    mv ${MLST_DIR}/${SAMPLE_NAME}.tsv ${MLST_DIR}/${SAMPLE_NAME}_1.tsv
    
    mlst \
        --scheme abaumannii \
        --threads 30 \
        ${SPADES_DIR}/${SAMPLE_NAME}.filtered.scaffolds.fa.gz \
        > ${MLST_DIR}/${SAMPLE_NAME}_2.tsv
    
    cat ${MLST_DIR}/${SAMPLE_NAME}_1.tsv ${MLST_DIR}/${SAMPLE_NAME}_2.tsv > ${MLST_DIR}/${SAMPLE_NAME}.tsv
    
    rm ${MLST_DIR}/${SAMPLE_NAME}_*.tsv
elif [[ ${SCHEME} == "abaumannii" ]]; then
    mv ${MLST_DIR}/${SAMPLE_NAME}.tsv ${MLST_DIR}/${SAMPLE_NAME}_1.tsv
    
    mlst --scheme abaumannii_2 \
    --threads 30 \
    ${SPADES_DIR}/${SAMPLE_NAME}.filtered.scaffolds.fa.gz \
    > ${MLST_DIR}/${SAMPLE_NAME}_2.tsv
    
    cat ${MLST_DIR}/${SAMPLE_NAME}_1.tsv ${MLST_DIR}/${SAMPLE_NAME}_2.tsv > ${MLST_DIR}/${SAMPLE_NAME}.tsv
    
    rm ${MLST_DIR}/${SAMPLE_NAME}_*.tsv
elif [[ ${SCHEME} == "ecoli" ]]; then
    mv ${MLST_DIR}/${SAMPLE_NAME}.tsv ${MLST_DIR}/${SAMPLE_NAME}_1.tsv
    
    mlst --scheme ecoli_2 \
    --threads 30 \
    ${SPADES_DIR}/${SAMPLE_NAME}.filtered.scaffolds.fa.gz \
    > ${MLST_DIR}/${SAMPLE_NAME}_2.tsv
    
    cat ${MLST_DIR}/${SAMPLE_NAME}_1.tsv ${MLST_DIR}/${SAMPLE_NAME}_2.tsv > ${MLST_DIR}/${SAMPLE_NAME}.tsv
    
    rm ${MLST_DIR}/${SAMPLE_NAME}_*.tsv
elif [[ ${SCHEME} == "ecoli_2" ]]; then
    mv ${MLST_DIR}/${SAMPLE_NAME}.tsv ${MLST_DIR}/${SAMPLE_NAME}_1.tsv
    
    mlst --scheme ecoli \
    --threads 30 \
    ${SPADES_DIR}/${SAMPLE_NAME}.filtered.scaffolds.fa.gz \
    > ${MLST_DIR}/${SAMPLE_NAME}_2.tsv
    
    cat ${MLST_DIR}/${SAMPLE_NAME}_1.tsv ${MLST_DIR}/${SAMPLE_NAME}_2.tsv > ${MLST_DIR}/${SAMPLE_NAME}.tsv
    
    rm ${MLST_DIR}/${SAMPLE_NAME}_*.tsv
else
    :
fi

# Add in generic header
sed -i '1i source_file\tDatabase\tST\tlocus_1\tlocus_2\tlocus_3\tlocus_4\tlocus_5\tlocus_6\tlocus_7\tlocus_8\tlous_9\tlocus_10' ${MLST_DIR}/${SAMPLE_NAME}.tsv

if [[ ${MLST_DB} = *.tar.gz ]]; then
    tar --use-compress-program="pigz -vdf" -xf ${MLST_DB}

    MLST_DB="${MLST_DB%.tar.gz}/db"
else
    :
fi

./bin/phoenix/fix_MLST2.py \
    --input ${MLST_DIR}/${SAMPLE_NAME}.tsv \
    --taxonomy ${MASH_DIR}/${SAMPLE_NAME}.tax \
    --mlst_database ${MLST_DB}

mv ${MASH_DIR}/${SAMPLE_NAME}_combined.tsv ${MASH_DIR}/${SAMPLE_NAME}_status.txt ${MLST_DIR}

conda deactivate
