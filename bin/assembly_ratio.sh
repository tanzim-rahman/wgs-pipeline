#!/usr/bin/env bash

mkdir -p ${ASSEMBLY_RATIO_DIR}

${WORK_DIR}/bin/phoenix/calculate_assembly_ratio.sh \
    -d ${NCBI_ASSEMBLY_STATS} \
    -q ${QUAST_DIR}/report.tsv \
    -x ${MASH_DIR}/${SAMPLE_NAME}.tax \
    -s ${SAMPLE_NAME}

mv db_path_update.txt ${SAMPLE_NAME}_Assembly_ratio_*.txt ${SAMPLE_NAME}_GC_content_*.txt ${ASSEMBLY_RATIO_DIR}
