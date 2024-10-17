#!/usr/bin/env bash

RUN_NAME="test_run"

INPUT_DIR="${PWD}/raw-data/${RUN_NAME}"
export INPUT_DIR

for FILES in ${INPUT_DIR}/*_R1.fastq.gz; do
    SAMPLE_NAME=${FILES##*/}
    SAMPLE_NAME=${SAMPLE_NAME%_R1.fastq.gz}
    export SAMPLE_NAME

    ./bin/trimming.sh

    ./bin/kraken2_trimmed.sh
    
    ./bin/spades.sh

    ./bin/gamma.sh

    ./bin/quast.sh

    ./bin/kraken2_assembly.sh

    ./bin/mash_fastani.sh

    ./bin/mlst.sh

    ./bin/amr_finder.sh

    ./bin/assembly_ratio.sh
    
    ./bin/stats.sh
done

# ls $INPUT_DIR
