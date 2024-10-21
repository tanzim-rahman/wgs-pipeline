#!/usr/bin/env bash

RUN_NAME="test_run"
export RUN_NAME

INPUT_DIR="${PWD}/raw-data/${RUN_NAME}"
export INPUT_DIR

# for FILES in ${INPUT_DIR}/*_R1.fastq.gz; do
#     SAMPLE_NAME=${FILES##*/}
#     SAMPLE_NAME=${SAMPLE_NAME%_R1.fastq.gz}
#     export SAMPLE_NAME

#     ./bin/trimming.sh

#     ./bin/kraken2_trimmed.sh
    
#     ./bin/spades.sh

#     ./bin/gamma.sh

#     ./bin/quast.sh

#     ./bin/kraken2_assembly.sh

#     ./bin/mash_fastani.sh

#     ./bin/mlst.sh

#     ./bin/amr_finder.sh

#     ./bin/assembly_ratio.sh
    
#     ./bin/stats.sh
# done

source config.sh

mkdir -p "results/${RUN_NAME}"

mv runs/${RUN_NAME}/*/11-stats/*_summaryline.tsv results/${RUN_NAME}

(
    cd results/${RUN_NAME} && \

    ${WORK_DIR}/bin/phoenix/Create_phoenix_summary_tsv.py \
        --out Phoenix_Summary.tsv && \

    ${WORK_DIR}/bin/phoenix/GRiPHin.py \
        -r ${RUN_DIR} \
        -s ${WORK_DIR}/samplesheet.csv \
        -a ${GAMMA_ARDB} \
        --output ${RUN_NAME}_GRiPHin_Summary.xlsx \
        --coverage 30 \
        --phoenix
)
