!/usr/bin/env bash

source config.sh

echo `date -I'seconds'` >> times_${RUN_NAME}.txt
echo "" >> times_${RUN_NAME}.txt

global_start=`date +%s`
sed 1d ${SAMPLE_SHEET} | while read -r LINE || [ -n "${LINE}" ]; do

    SAMPLE_NAME=$( echo ${LINE} | cut -f 1 -d ',' )
    export SAMPLE_NAME

    READ_R1=$( echo ${LINE} | cut -f 2 -d ',' )
    export READ_R1

    READ_R2=$( echo ${LINE} | cut -f 3 -d ',' )
    export READ_R2

    echo ${SAMPLE_NAME} >> times_${RUN_NAME}.txt

    trim_start=`date +%s`
    ${WORK_DIR}/bin/trimming.sh
    end=`date +%s`
    runtime=$(( end - trim_start ))

    echo "Trimming: ${runtime}" >> times_${RUN_NAME}.txt

    start=`date +%s`
    ${WORK_DIR}/bin/kraken2_trimmed.sh
    end=`date +%s`
    runtime=$(( end - start ))

    echo "Kraken Trimmed: ${runtime}" >> times_${RUN_NAME}.txt

    start=`date +%s`
    ${WORK_DIR}/bin/spades.sh
    end=`date +%s`
    runtime=$(( end - start ))

    echo "Spades: ${runtime}" >> times_${RUN_NAME}.txt

    start=`date +%s`
    ${WORK_DIR}/bin/gamma.sh
    end=`date +%s`
    runtime=$(( end - start ))

    echo "Gamma: ${runtime}" >> times_${RUN_NAME}.txt

    start=`date +%s`
    ${WORK_DIR}/bin/quast.sh
    end=`date +%s`
    runtime=$(( end - start ))

    echo "Quast: ${runtime}" >> times_${RUN_NAME}.txt

    start=`date +%s`
    ${WORK_DIR}/bin/kraken2_assembly.sh
    end=`date +%s`
    runtime=$(( end - start ))

    echo "Kraken Assembly: ${runtime}" >> times_${RUN_NAME}.txt

    start=`date +%s`
    ${WORK_DIR}/bin/mash_fastani.sh
    end=`date +%s`
    runtime=$(( end - start ))

    echo "Mash + Fastani: ${runtime}" >> times_${RUN_NAME}.txt

    start=`date +%s`
    ${WORK_DIR}/bin/mlst.sh
    end=`date +%s`
    runtime=$(( end - start ))

    echo "MLST: ${runtime}" >> times_${RUN_NAME}.txt

    start=`date +%s`
    ${WORK_DIR}/bin/amr_finder.sh
    end=`date +%s`
    runtime=$(( end - start ))

    echo "Prokka + AMRFinder: ${runtime}" >> times_${RUN_NAME}.txt

    start=`date +%s`
    ${WORK_DIR}/bin/assembly_ratio.sh
    assembly_ratio_end=`date +%s`
    runtime=$(( assembly_ratio_end - start ))

    echo "Assembly Ratio: ${runtime}" >> times_${RUN_NAME}.txt

    total_runtime=$(( assembly_ratio_end - trim_start ))
    echo "Total: ${total_runtime}" >> times_${RUN_NAME}.txt

    echo "" >> times_${RUN_NAME}.txt
    fi
done

STATS_CPU=15
TOTAL_SAMPLES=$( cat ${SAMPLE_SHEET} | wc -l )
TOTAL_SAMPLES=$(( TOTAL_SAMPLES - 1 ))
PROCESS_SAMPLES=$(( TOTAL_SAMPLES_SAMPLES / STATS_CPU + 1 ))

start=`date +%s`
for i in $(seq 0 $(( STATS_CPU - 1 ))); do
    ${WORK_DIR}/bin/stats.sh $(( i*PROCESS_SAMPLES + 2 )) ${PROCESS_SAMPLES} &
done
wait
echo "Stats Finished"
end=`date +%s`
runtime=$(( end - start ))

echo "All Stats: ${runtime}" >> times_${RUN_NAME}.txt
echo "" >> times_${RUN_NAME}.txt

mkdir -p "${RESULTS_DIR}/summary"

mv ${RUN_DIR}/*/11-stats/*_summaryline.tsv ${RESULTS_DIR}/summary

(
    cd ${RESULTS_DIR}/summary && \

    ${WORK_DIR}/bin/phoenix/Create_phoenix_summary_tsv.py \
        --out Phoenix_Summary.tsv && \

    ${WORK_DIR}/bin/phoenix/GRiPHin.py \
        -r ${RUN_DIR} \
        -s ${SAMPLE_SHEET} \
        -a ${GAMMA_ARDB} \
        --output ${RESULTS_DIR}/summary/${RUN_NAME}_GRiPHin_Summary.xlsx \
        --coverage 30 \
        --phoenix
)

global_end=`date +%s`
global_runtime=$(( global_end - global_start ))

echo -e "Entire process took $(( global_runtime/60  )) minutes.\n\n" >> times_${RUN_NAME}.txt
