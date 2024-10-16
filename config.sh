#!/usr/bin/env bash

RUN_NAME="test_run"

INPUT_DIR="/home/igc-1/tahsin/shotgun/"
SAMPLE_NAME="104S2_S49_L001"

WORK_DIR=$( pwd )
RUN_DIR="${WORK_DIR}/runs/${RUN_NAME}"

QC_DIR="${RUN_DIR}/${SAMPLE_NAME}/01-quality_control"
KRAKEN_TRIMMED_DIR="${RUN_DIR}/${SAMPLE_NAME}/02-kraken-trimmed"
SPADES_DIR="${RUN_DIR}/${SAMPLE_NAME}/03-spades"
GAMMA_DIR="${RUN_DIR}/${SAMPLE_NAME}/04-gamma"
QUAST_DIR="${RUN_DIR}/${SAMPLE_NAME}/05-quast"
KRAKEN_ASSEMBLY_DIR="${RUN_DIR}/${SAMPLE_NAME}/06-kraken-assembly"
MASH_DIR="${RUN_DIR}/${SAMPLE_NAME}/07-mash-fastani"
MLST_DIR="${RUN_DIR}/${SAMPLE_NAME}/08-mlst"
AMR_DIR="${RUN_DIR}/${SAMPLE_NAME}/09-amr"
ASSEMBLY_RATIO_DIR="${RUN_DIR}/${SAMPLE_NAME}/10-assembly-ratio"

# Databases
BBDUK_REF="/home/igc-1/anaconda3/envs/busco/share/bbmap/resources/adapters.fa"

KRAKEN_DB="/home/igc-1/Documents/Tanzim/db/kraken2db/"

GAMMA_HVDB="/home/igc-1/Pipelines/phoenix-2.0.2/assets/databases/HyperVirulence_20220414.fasta"
GAMMA_ARDB="/home/igc-1/Pipelines/phoenix-2.0.2/assets/databases/ResGANNCBI_20230517_srst2.fasta"
GAMMA_DBPF="/home/igc-1/Pipelines/phoenix-2.0.2/assets/databases/PF-Replicons_20230504.fasta"

ZIPPED_SKETCH="/home/igc-1/Pipelines/phoenix-2.0.2/assets/databases/REFSEQ_20230504_Bacteria_complete.msh.gz"
MASH_DB=${ZIPPED_SKETCH%.gz}
MASH_DB_VERSION=$( echo ${MASH_DB##*/} | cut -d '_' -f1,2 )

TAXA="/home/igc-1/Pipelines/phoenix-2.0.2/assets/databases/taxes_20230516.csv"

MLST_DB="/home/igc-1/Pipelines/phoenix-2.0.2/assets/databases/mlst_db_20230728/db"

NCBI_ASSEMBLY_STATS="/home/igc-1/Pipelines/phoenix-2.0.2/assets/databases/NCBI_Assembly_stats_20230504.txt"
