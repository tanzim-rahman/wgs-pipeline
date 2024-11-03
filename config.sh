#!/usr/bin/env bash

# NOTE: Directory names must NOT end with a "/".

# Number of CPU threads to run programs.
THREADS=30
# Maximum memory used by Spades.
MEMORY=120

# Name for the current run.
RUN_NAME="birdem"
# Location of the samplesheet file that contains sample information.
SAMPLESHEET="/home/igc-1/Documents/Tanzim/phoenix-pipeline/samplesheet.csv"

# Directory where the wgs-pipeline.sh and config.sh files as well as the bin folder is located.
WORK_DIR="/home/igc-1/Documents/Tanzim/phoenix-pipeline"
# Directory where the results and final run summary will be stored.
RESULTS_DIR="${WORK_DIR}/results/birdem"
# Directory where the run outputs of each sample will be stored.
RUN_DIR="${RESULTS_DIR}/runs"

# Directories for the various stages of the pipeline.
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
STATS_DIR="${RUN_DIR}/${SAMPLE_NAME}/11-stats"

# Databases
BBDUK_REF="/home/igc-1/NSNS/wgs_bacteria_30_oct_2024/phiX.fasta"

KRAKEN_DB="/home/igc-1/Documents/Tanzim/db/kraken2db"

GAMMA_HVDB="/home/igc-1/Pipelines/phoenix-2.0.2/assets/databases/HyperVirulence_20220414.fasta"
GAMMA_ARDB="/home/igc-1/Pipelines/phoenix-2.0.2/assets/databases/ResGANNCBI_20230517_srst2.fasta"
GAMMA_PFDB="/home/igc-1/Pipelines/phoenix-2.0.2/assets/databases/PF-Replicons_20230504.fasta"
DB_NAME_AR=$( echo ${GAMMA_ARDB} | sed 's:.*/::' | sed 's/.fasta//' )
DB_NAME_HV=$( echo ${GAMMA_HVDB} | sed 's:.*/::' | sed 's/.fasta//' )
DB_NAME_PF=$( echo ${GAMMA_PFDB} | sed 's:.*/::' | sed 's/.fasta//' )

ZIPPED_SKETCH="/home/igc-1/NSNS/wgs_bacteria_30_oct_2024/REFSEQ_20240124_Bacteria_complete.msh"
MASH_DB=${ZIPPED_SKETCH%.gz}
MASH_DB_VERSION=$( echo ${MASH_DB##*/} | cut -d '_' -f1,2 )

TAXA="/home/igc-1/Pipelines/phoenix-2.0.2/assets/databases/taxes_20230516.csv"

MLST_DB="/home/igc-1/Pipelines/phoenix-2.0.2/assets/databases/mlst_db_20230728/db"

NCBI_ASSEMBLY_STATS="/home/igc-1/Pipelines/phoenix-2.0.2/assets/databases/NCBI_Assembly_stats_20230504.txt"

# Conda location
CONDA_LOCATION="/home/igc-1/anaconda3/etc/profile.d/conda.sh"

# Conda environments
CONDA_ENV_BBMAP="wgs"
CONDA_ENV_FASTP="wgs"
CONDA_ENV_FASTQC="wgs"
CONDA_ENV_KRAKEN2="wgs"
CONDA_ENV_KRONATOOLS="wgs"
CONDA_ENV_SPADES="wgs"
CONDA_ENV_GAMMA="wgs"
CONDA_ENV_QUAST="wgs"
CONDA_ENV_MASH="wgs"
CONDA_ENV_FASTANI="wgs"
CONDA_ENV_MLST="wgs"
CONDA_ENV_PROKKA="wgs"
CONDA_ENV_AMRFINDER="amrfinder"
CONDA_ENV_STATS="wgs"
