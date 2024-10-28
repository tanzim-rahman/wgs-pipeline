#!/usr/bin/env bash

# NOTE: Directory names must NOT end with a "/"

# Name for the current run.
RUN_NAME=""
# Location of the samplesheet file that contains sample information.
SAMPLE_SHEET=""

# Directory where the pipeline.sh file as well as the bin folder is located.
WORK_DIR="$( pwd )"
# Directory where the results directory will be stored. This can be the same directory that contains the input FastQ files.
ROOT_DIR=""
# Directory where the results and final run summary will be stored.
RESULTS_DIR="${ROOT_DIR}/results"
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
BBDUK_REF=""

KRAKEN_DB=""

GAMMA_HVDB=""
GAMMA_ARDB=""
GAMMA_DBPF=""
DB_NAME_AR=$( echo ${GAMMA_ARDB} | sed 's:.*/::' | sed 's/.fasta//' )
DB_NAME_HV=$( echo ${GAMMA_HVDB} | sed 's:.*/::' | sed 's/.fasta//' )
DB_NAME_PF=$( echo ${GAMMA_DBPF} | sed 's:.*/::' | sed 's/.fasta//' )

ZIPPED_SKETCH=""
MASH_DB=${ZIPPED_SKETCH%.gz}
MASH_DB_VERSION=$( echo ${MASH_DB##*/} | cut -d '_' -f1,2 )

TAXA=""

MLST_DB=""

NCBI_ASSEMBLY_STATS=""

# Conda location
CONDA_LOCATION=""

# Conda environments
CONDA_ENV_BBMAP=""
CONDA_ENV_FASTP=""
CONDA_ENV_FASTQC=""
CONDA_ENV_KRAKEN2=""
CONDA_ENV_KRONATOOLS=""
CONDA_ENV_SPADES=""
CONDA_ENV_GAMMA=""
CONDA_ENV_QUAST=""
CONDA_ENV_MASH=""
CONDA_ENV_FASTANI=""
CONDA_ENV_MLST=""
CONDA_ENV_PROKKA=""
CONDA_ENV_AMRFINDER=""
CONDA_ENV_STATS=""
