#!/usr/bin/env bash

source config.sh

echo `date` >> times.txt
echo "" >> times.txt

global_start=`date +%s`
sed 1d ${SAMPLE_SHEET} | while read LINE; do

    SAMPLE_NAME=$( echo ${LINE} | cut -f 1 -d ',' )
    export SAMPLE_NAME

    READ_R1=$( echo ${LINE} | cut -f 2 -d ',' )
    export READ_R1

    READ_R2=$( echo ${LINE} | cut -f 3 -d ',' )
    export READ_R2

    echo ${SAMPLE_NAME} >> times.txt

    trim_start=`date +%s`
    ./bin/trimming.sh
    end=`date +%s`
    trim_runtime=$((end-trim_start))

    echo "Trimming: ${trim_runtime}" >> times.txt

    start=`date +%s`
    ./bin/kraken2_trimmed.sh
    end=`date +%s`
    kraken_trim_runtime=$((end-start))

    echo "Kraken Trimmed: ${kraken_trim_runtime}" >> times.txt

    start=`date +%s`
    ./bin/spades.sh
    end=`date +%s`
    spades_runtime=$((end-start))

    echo "Spades: ${spades_runtime}" >> times.txt

    start=`date +%s`
    ./bin/gamma.sh
    end=`date +%s`
    gamma_runtime=$((end-start))

    echo "Gamma: ${gamma_runtime}" >> times.txt

    start=`date +%s`
    ./bin/quast.sh
    end=`date +%s`
    quast_runtime=$((end-start))

    echo "Quast: ${quast_runtime}" >> times.txt

    start=`date +%s`
    ./bin/kraken2_assembly.sh
    end=`date +%s`
    kraken_assembly_runtime=$((end-start))

    echo "Kraken Assembly: ${kraken_assembly_runtime}" >> times.txt

    start=`date +%s`
    ./bin/mash_fastani.sh
    end=`date +%s`
    mash_fastani_runtime=$((end-start))

    echo "Mash + Fastani: ${mash_fastani_runtime}" >> times.txt

    start=`date +%s`
    ./bin/mlst.sh
    end=`date +%s`
    mlst_runtime=$((end-start))

    echo "MLST: ${mlst_runtime}" >> times.txt

    start=`date +%s`
    ./bin/amr_finder.sh
    end=`date +%s`
    amr_runtime=$((end-start))

    echo "Prokka + AMRFinder: ${amr_runtime}" >> times.txt

    start=`date +%s`
    ./bin/assembly_ratio.sh
    end=`date +%s`
    assembly_ratio_runtime=$((end-start))

    echo "Assembly Ratio: ${assembly_ratio_runtime}" >> times.txt

    start=`date +%s`
    ./bin/stats.sh
    stats_end=`date +%s`
    stats_runtime=$((stats_end-start))

    echo "Stats: ${stats_runtime}" >> times.txt

    total_runtime=$((stats_end-trim_start))
    echo "Total: ${total_runtime}" >> times.txt

    echo "" >> times.txt
done

echo "" >> times.txt

mkdir -p "${RUN_DIR}/summary"

mv ${RUN_DIR}/*/11-stats/*_summaryline.tsv ${RUN_DIR}/summary

(
    cd ${RUN_DIR}/summary && \

    ${WORK_DIR}/bin/phoenix/Create_phoenix_summary_tsv.py \
        --out Phoenix_Summary.tsv && \

    ${WORK_DIR}/bin/phoenix/GRiPHin.py \
        -r ${RUN_DIR} \
        -s ${ROOT_DIR}/samplesheet.csv \
        -a ${GAMMA_ARDB} \
        --output ${RUN_DIR}/summary/${RUN_NAME}_GRiPHin_Summary.xlsx \
        --coverage 30 \
        --phoenix
)

global_end=`date +%s`
global_runtime=$(( global_end - global_start ))

echo -e "Entire process took $(( global_runtime/60  )) minutes.\n\n" >> times.txt
