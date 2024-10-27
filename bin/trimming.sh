#!/usr/bin/env bash

source ${CONDA_LOCATION}

conda activate busco

source config.sh

mkdir -p ${QC_DIR}

bbduk.sh \
    -Xmx50g \
    in1=${READ_R1} \
    in2=${READ_R2} \
    out1="${QC_DIR}/${SAMPLE_NAME}_R1_trimmed.fastq.gz" \
    out2="${QC_DIR}/${SAMPLE_NAME}_R2_trimmed.fastq.gz" \
    threads=30 \
    ref=${BBDUK_REF} \
    &> ${QC_DIR}/${SAMPLE_NAME}.bbduk.log

conda deactivate

conda activate wgs

fastp \
    --in1 ${QC_DIR}/${SAMPLE_NAME}_R1_trimmed.fastq.gz \
    --in2 ${QC_DIR}/${SAMPLE_NAME}_R2_trimmed.fastq.gz \
    --out1 ${QC_DIR}/${SAMPLE_NAME}_R1_trimmed_fastp.fastq.gz \
    --out2 ${QC_DIR}/${SAMPLE_NAME}_R2_trimmed_fastp.fastq.gz \
    --json ${QC_DIR}/${SAMPLE_NAME}.fastp.json \
    --html ${QC_DIR}/${SAMPLE_NAME}.fastp.html \
    --unpaired1 ${QC_DIR}/${SAMPLE_NAME}_R1_unpaired_fastp.fastq.gz \
    --unpaired2 ${QC_DIR}/${SAMPLE_NAME}_R2_unpaired_fastp.fastq.gz \
    --thread 30 \
    --detect_adapter_for_pe \
    2> ${QC_DIR}/${SAMPLE_NAME}.fastp.log

READ1="${QC_DIR}/${SAMPLE_NAME}_R1_unpaired_fastp.fastq.gz"
READ2="${QC_DIR}/${SAMPLE_NAME}_R2_unpaired_fastp.fastq.gz"

if [[ ! -s ${READ1} ]] && [[ ! -s ${READ2} ]]; then
    echo "Both are empty" >> ${QC_DIR}/debug_status.log
    echo "!!!!! - Both are empty"
    # Both are empty, do nothing??? Nope we handle now
    #Create psuedo file as empty aint cutting it

    echo -e '{\n\t"summary": {\n\t\t"after_filtering": {\n\t\t\t"total_reads":0,\n\t\t\t"total_bases":0,\n\t\t\t"q20_bases":0,\n\t\t\t"q30_bases":0,\n\t\t\t"q20_rate":0,\n\t\t\t"q30_rate":0,\n\t\t\t"read1_mean_length":0,\n\t\t\t"gc_content":0\n\t\t}\n\t}\n}' > ${QC_DIR}/${SAMPLE_NAME}_singles.fastp.json

    ${WORK_DIR}/bin/phoenix/create_empty_fastp_json.sh -n ${SAMPLE_NAME}

    mv ${SAMPLE_NAME}_singles.fastp.json ${QC_DIR}/${SAMPLE_NAME}_singles.fastp.json

    touch "${QC_DIR}/${SAMPLE_NAME}_empty.html"
    touch ${QC_DIR}/${SAMPLE_NAME}.singles.fastq
    gzip ${QC_DIR}/${SAMPLE_NAME}.singles.fastq
else
    if [[ ! -s ${READ1} ]]; then
        echo "READ1 is empty, but not READ2, zcatting READ2(R2)" >> ${QC_DIR}/debug_status.log
        echo "!!!!! - READ1 is empty, but not READ2, zcatting READ2(R2)"
        # Only R1 is empty, run on R2 only
        zcat ${READ2} > ${QC_DIR}/${SAMPLE_NAME}.cat_singles.fastq
        gzip ${QC_DIR}/${SAMPLE_NAME}.cat_singles.fastq
    elif [[ ! -s ${READ2} ]]; then
        echo "READ2 is empty, but not READ1. zcatting READ1(R1)" >> ${QC_DIR}/debug_status.log
        echo "!!!!! - READ2 is empty, but not READ1. zcatting READ1(R1)"
        # Only R2 is empty, run on R1 only
        zcat ${READ1} > ${QC_DIR}/${SAMPLE_NAME}.cat_singles.fastq
        gzip ${QC_DIR}/${SAMPLE_NAME}.cat_singles.fastq
    else
        echo "Neither is empty" >> ${QC_DIR}/debug_status.log
        echo "!!!!! - Neither is empty"
        # Both reads have contents
        zcat ${READ1} ${READ2} > ${QC_DIR}/${SAMPLE_NAME}.cat_singles.fastq
        gzip ${QC_DIR}/${SAMPLE_NAME}.cat_singles.fastq
    fi
    # Possibly will need to catch when in1 is empty, dont know how fastp handles it, but right now we need to many of its standard outputs
    fastp \
        --in1 ${QC_DIR}/${SAMPLE_NAME}.cat_singles.fastq.gz \
        --thread $30 \
        --json ${QC_DIR}/${SAMPLE_NAME}_singles.fastp.json \
        --html ${QC_DIR}/${SAMPLE_NAME}_singles.fastp.html \
        --out1 ${QC_DIR}/${SAMPLE_NAME}.singles.fastq.gz \
        2> ${QC_DIR}/${SAMPLE_NAME}.fastp.log
fi

${WORK_DIR}/bin/phoenix/FastP_QC.py \
    --trimmed_json ${QC_DIR}/${SAMPLE_NAME}.fastp.json \
    --single_json ${QC_DIR}/${SAMPLE_NAME}_singles.fastp.json \
    --name ${SAMPLE_NAME}

mv ${SAMPLE_NAME}_trimmed_read_counts.txt ${QC_DIR}/${SAMPLE_NAME}_trimmed_read_counts.txt

fastqc \
    --threads 30 \
    ${QC_DIR}/${SAMPLE_NAME}_R1_trimmed_fastp.fastq.gz \
    ${QC_DIR}/${SAMPLE_NAME}_R2_trimmed_fastp.fastq.gz

conda deactivate
