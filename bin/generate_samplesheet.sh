#!/usr/bin/env bash

# Path to directory containing sample fastq files. Must NOT end with "/"
FASTQ_DIR=""
# Path for generating new samplesheet
SAMPLESHEET_PATH=""

printf "sample,fastq_1,fastq_2" > ${SAMPLESHEET_PATH}
SAMPLES=$( ls ${FASTQ_DIR} | sed -n "s|\(.*\)_\([R]*\)1\([._].*\)|\1,${FASTQ_DIR}/\1_\21\3,${FASTQ_DIR}/\1_\22\3|p" )
for SAMPLE in ${SAMPLES[@]}; do
    printf "\n${SAMPLE}" >> ${SAMPLESHEET_PATH}
done
