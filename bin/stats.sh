#!/usr/bin/env bash

source config.sh

source ${CONDA_LOCATION}

conda activate ${CONDA_ENV_STATS}

cat ${SAMPLESHEET} | tail -n +$1 | head -n $2 | while read LINE || [ -n "${LINE}" ]; do

    SAMPLE_NAME=$( echo ${LINE} | cut -f 1 -d ',' )
    export SAMPLE_NAME
    READ_R1=$( echo ${LINE} | cut -f 2 -d ',' )
    READ_R2=$( echo ${LINE} | cut -f 3 -d ',' )

    source config.sh

    ${WORK_DIR}/bin/phoenix/q30.py ${READ_R1} ${SAMPLE_NAME}_R1_stats.txt &
    ${WORK_DIR}/bin/phoenix/q30.py ${READ_R2} ${SAMPLE_NAME}_R2_stats.txt &
    wait
    ${WORK_DIR}/bin/phoenix/create_raw_stats_output.py -n ${SAMPLE_NAME} -r1 ${SAMPLE_NAME}_R1_stats.txt -r2 ${SAMPLE_NAME}_R2_stats.txt

    mkdir -p ${STATS_DIR}

    mv ${SAMPLE_NAME}_R1_stats.txt ${SAMPLE_NAME}_R2_stats.txt ${SAMPLE_NAME}_raw_read_counts.txt ${STATS_DIR}

    ${WORK_DIR}/bin/phoenix/pipeline_stats_writer.sh \
        -a ${STATS_DIR}/${SAMPLE_NAME}_raw_read_counts.txt \
        -b ${QC_DIR}/${SAMPLE_NAME}_trimmed_read_counts.txt \
        -c ${ASSEMBLY_RATIO_DIR}/${SAMPLE_NAME}_GC_content_*.txt \
        -d ${SAMPLE_NAME} \
        -e ${KRAKEN_TRIMMED_DIR}/${SAMPLE_NAME}.kraken2_trimmed.summary.txt \
        -f ${KRAKEN_TRIMMED_DIR}/${SAMPLE_NAME}.kraken2_trimmed.top_kraken_hit.txt \
        -g ${KRAKEN_TRIMMED_DIR}/${SAMPLE_NAME}_trimmed.krona.html \
        -h ${SPADES_DIR}/${SAMPLE_NAME}.renamed.scaffolds.fa.gz \
        -i ${SPADES_DIR}/${SAMPLE_NAME}.filtered.scaffolds.fa.gz \
        -m ${KRAKEN_ASSEMBLY_DIR}/${SAMPLE_NAME}.kraken2_wtasmbld.summary.txt \
        -n ${KRAKEN_ASSEMBLY_DIR}/${SAMPLE_NAME}.kraken2_wtasmbld.top_kraken_hit.txt \
        -o ${KRAKEN_ASSEMBLY_DIR}/${SAMPLE_NAME}_wtasmbld.krona.html \
        -p ${QUAST_DIR}/report.tsv \
        -q ${MASH_DIR}/${SAMPLE_NAME}.tax \
        -r ${ASSEMBLY_RATIO_DIR}/${SAMPLE_NAME}_Assembly_ratio_*.txt \
        -t ${MASH_DIR}/${SAMPLE_NAME}_${MASH_DB_VERSION}.fastANI.txt \
        -u ${GAMMA_DIR}/${SAMPLE_NAME}_HyperVirulence_*.gamma \
        -v ${GAMMA_DIR}/${SAMPLE_NAME}_PF-Replicons_*.gamma \
        -w ${GAMMA_DIR}/${SAMPLE_NAME}_ResGANNCBI_*.gamma \
        -y ${MLST_DIR}/${SAMPLE_NAME}_combined.tsv \
        -4 ${AMR_DIR}/${SAMPLE_NAME}_all_mutations.tsv \
        -5 0

    mv ${SAMPLE_NAME}.synopsis ${STATS_DIR}

    ${WORK_DIR}/bin/phoenix/Phoenix_summary_line.py \
        -q ${QUAST_DIR}/report.tsv \
        -t ${QC_DIR}/${SAMPLE_NAME}_trimmed_read_counts.txt \
        -a ${GAMMA_DIR}/${SAMPLE_NAME}_${DB_NAME_AR}.gamma \
        -v ${GAMMA_DIR}/${SAMPLE_NAME}_${DB_NAME_HV}.gamma \
        -p ${GAMMA_DIR}/${SAMPLE_NAME}_${DB_NAME_PF}.gamma \
        -r ${ASSEMBLY_RATIO_DIR}/${SAMPLE_NAME}_Assembly_ratio_*.txt \
        -m ${MLST_DIR}/${SAMPLE_NAME}_combined.tsv  \
        -u ${AMR_DIR}/${SAMPLE_NAME}_all_genes.tsv \
        -n ${SAMPLE_NAME} \
        -s ${STATS_DIR}/${SAMPLE_NAME}.synopsis \
        -x ${MASH_DIR}/${SAMPLE_NAME}.tax \
        -f ${MASH_DIR}/${SAMPLE_NAME}_${MASH_DB_VERSION}.fastANI.txt \
        -k ${KRAKEN_TRIMMED_DIR}/${SAMPLE_NAME}.kraken2_trimmed.top_kraken_hit.txt \
        -o ${STATS_DIR}/${SAMPLE_NAME}_summaryline.tsv

done

conda deactivate
