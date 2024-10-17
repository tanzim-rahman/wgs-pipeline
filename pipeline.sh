#!/usr/bin/env bash

RUN_NAME="test_run"

INPUT_DIR="${PWD}/raw-data/${RUN_NAME}"
# SAMPLE_NAME="104S2_S49_L001"

for FILES in ${INPUT_DIR}/*_R1.fastq.gz; do
    SAMPLE_NAME=${FILES##*/}
    SAMPLE_NAME=${SAMPLE_NAME%_R1.fastq.gz}
    echo $SAMPLE_NAME
done

# ls $INPUT_DIR
