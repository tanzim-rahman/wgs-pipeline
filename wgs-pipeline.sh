#!/usr/bin/env bash

show_help() {
    echo "Pipeline for short read genomic analysis."
    echo "USAGE ./wgs-pipeline.sh [OPTIONS]"
    echo "If options are not provided as arguments, default values are imported from config.sh."
    echo "Paths must not end with a '/' and should be provided in their full form."
    echo "OPTIONS"
    printf "    %-35s|    %s\n" "-h/--help" "Shows the help dialog."
    printf "    %-35s|    %s\n" "-n/--run_name NAME" "Name of current run."
    printf "    %-35s|    %s\n" "-w/--work_dir DIR" "Working directory. Must contain the wgs-pipeline.sh and config.sh files as well as the bin directory."
    printf "    %-35s|    %s\n" "-s/--samplesheet FILE" "Full path to the samplesheet file. If --generate_samplesheet DIR is provided, this samplesheet file is automatically created from the samples contained in DIR directory."
    printf "    %-35s|    %s\n" "-g/--generate_samplesheet DIR" "Automatically generates a samplesheet file using the DIR directory and saves to -s/--samplesheet FILE. The samples in DIR must have the extension fastq.gz or fq.gz and must contain either _R1/_R2 or _1/_2 in their names to distinguish between reads."
    printf "    %-35s|    %s\n" "-r/--results_dir DIR" "Directory where the run results will be stored. Indiviual sample results are stored in DIR/runs/{sample_name}/ while the final summary results are stored in DIR/summary/."
    printf "    %-35s|    %s\n" "-t/--threads INT" "Number of CPU threads to use."
    printf "    %-35s|    %s\n" "-m/--memory INT" "Maximum memory used by Spades."
    echo "REFERENCES AND DATABASES"
    printf "    %-35s|    %s\n" "--bbduk_ref FILE" "Path to BBDUK reference file."
    printf "    %-35s|    %s\n" "--kraken2_db DIR" "Path to Kraken2 DB directory."
    printf "    %-35s|    %s\n" "--gamme_hv FILE" "Path to GAMMA Hypervirulence reference file."
    printf "    %-35s|    %s\n" "--gamme_ar FILE" "Path to GAMMA AR reference file."
    printf "    %-35s|    %s\n" "--gamme_pf FILE" "Path to GAMMA PlasmidFinder reference file."
    printf "    %-35s|    %s\n" "--mash_db FILE" "Path to MASH sketch file. May be gzipped."
    printf "    %-35s|    %s\n" "--taxa FILE" "Path to taxinomy reference file."
    printf "    %-35s|    %s\n" "--mlst_db DIR/FILE" "Path to MLST DB directory or gzipped file."
    printf "    %-35s|    %s\n" "--assembly_stats FILE" "Path to assembly stats file."
    echo "CONDA ENVIRONMENTS"
    printf "    %-35s|    %s\n" "--conda FILE" "Location of the conda.sh file. This is used in order to activate conda environments."
    printf "    %-35s|    %s\n" "--conda_all NAME" "Sets the name of the conda environment containing all programs to NAME."
    printf "    %-35s|    %s\n" "--conda_PROGRAM NAME" "Sets the name of the conda environment that contains PROGRAM to NAME. Overwrites --conda_all."
    echo "    PROGRAM options: bbduk, fastp, fastqc, kraken2, kronatools, spades, gamma, quast, mash, fastani, mlst, prokka, amrfinder, stats."
}

source config.sh

CONDA_ENV_BBMAP_SET=false
CONDA_ENV_FASTP_SET=false
CONDA_ENV_FASTQC_SET=false
CONDA_ENV_KRAKEN2_SET=false
CONDA_ENV_KRONATOOLS_SET=false
CONDA_ENV_SPADES_SET=false
CONDA_ENV_GAMMA_SET=false
CONDA_ENV_QUAST_SET=false
CONDA_ENV_MASH_SET=false
CONDA_ENV_FASTANI_SET=false
CONDA_ENV_MLST_SET=false
CONDA_ENV_PROKKA_SET=false
CONDA_ENV_AMRFINDER_SET=false
CONDA_ENV_STATS_SET=false

GENERATE_SAMPLESHEET=false
RAW_DATA_LOCATION=""

VALID_ARGS=$(getopt -o hn:w:s:g:r:t:m: --long help,run_name:,work_dir:,samplesheet:,generate_samplesheet:,results_dir:,threads:,memory:,bbduk_ref:,kraken2_db:,gamma_hv:,gamma_ar:,gamma_pf:,mash_db:,taxa_ref:,mlst_db:,assembly_stats:,conda_path:,conda_all:,conda_bbmap:,conda_fastp:,conda_fastqc:,conda_kraken2:,conda_kronatools:,conda_spades:,conda_gamma:,conda_quast:,conda_mash:,conda_fastani:,conda_mlst:,conda_prokka:,conda_amrfinder:,conda_stats: -- "$@")
if [[ $? -ne 0 ]]; then
    exit 1;
fi

eval set -- "$VALID_ARGS"
while [ : ]; do
    case "$1" in
        -h | --help)
            show_help
            exit 0
            ;;
        -n | --run_name)
            RUN_NAME="$2"
            shift 2
            ;;
        -w | --work_dir)
            WORK_DIR="$2"
            shift 2
            ;;
        -s | --samplesheet)
            SAMPLESHEET="$2"
            shift 2
            ;;
        -g | --generate_samplesheet)
            RAW_DATA_LOCATION="$2"
            GENERATE_SAMPLESHEET=true
            shift 2
            ;;
        -r | --results_dir)
            RESULTS_DIR="$2"
            RUN_DIR="${RESULTS_DIR}/runs"
            shift 2
            ;;
        -t | --threads)
            THREADS="$2"
            shift 2
            ;;
        -m | --memory)
            MEMORY="$2"
            shift 2
            ;;
        --bbduk_ref)
            BBDUK_REF="$2"
            shift 2
            ;;
        --kraken2_db)
            KRAKEN_DB="$2"
            shift 2
            ;;
        --gamma_hv)
            GAMMA_HVDB="$2"
            DB_NAME_HV=$( echo ${GAMMA_HVDB} | sed 's:.*/::' | sed 's/.fasta//' )
            shift 2
            ;;
        --gamma_ar)
            GAMMA_ARDB="$2"
            DB_NAME_AR=$( echo ${GAMMA_ARDB} | sed 's:.*/::' | sed 's/.fasta//' )
            shift 2
            ;;
        --gamma_pf)
            GAMMA_PFDB="$2"
            DB_NAME_PF=$( echo ${GAMMA_PFDB} | sed 's:.*/::' | sed 's/.fasta//' )
            shift 2
            ;;
        --mash_db)
            ZIPPED_SKETCH="$2"
            MASH_DB=${ZIPPED_SKETCH%.gz}
            MASH_DB_VERSION=$( echo ${MASH_DB##*/} | cut -d '_' -f1,2 )
            shift 2
            ;;
        --taxa_ref)
            TAXA="$2"
            shift 2
            ;;
        --mlst_db)
            MLST_DB="$2"
            shift 2
            ;;
        --assembly_stats)
            NCBI_ASSEMBLY_STATS="$2"
            shift 2
            ;;
        --conda_path)
            CONDA_LOCATION="$2"
            shift 2
            ;;
        --conda_all)
            if [ "${CONDA_ENV_BBMAP_SET}" = false ]; then
                CONDA_ENV_BBMAP="$2"
            fi
            if [ "${CONDA_ENV_FASTP_SET}" = false ]; then
                CONDA_ENV_FASTP="$2"
            fi
            if [ "${CONDA_ENV_FASTQC_SET}" = false ]; then
                CONDA_ENV_FASTQC="$2"
            fi
            if [ "${CONDA_ENV_KRAKEN2_SET}" = false ]; then
                CONDA_ENV_KRAKEN2="$2"
            fi
            if [ "${CONDA_ENV_KRONATOOLS_SET}" = false ]; then
                CONDA_ENV_KRONATOOLS="$2"
            fi
            if [ "${CONDA_ENV_SPADES_SET}" = false ]; then
                CONDA_ENV_SPADES="$2"
            fi
            if [ "${CONDA_ENV_GAMMA_SET}" = false ]; then
                CONDA_ENV_GAMMA="$2"
            fi
            if [ "${CONDA_ENV_QAUST_SET}" = false ]; then
                CONDA_ENV_QUAST="$2"
            fi
            if [ "${CONDA_ENV_MASH_SET}" = false ]; then
                CONDA_ENV_MASH="$2"
            fi
            if [ "${CONDA_ENV_FASTANI_SET}" = false ]; then
                CONDA_ENV_FASTANI="$2"
            fi
            if [ "${CONDA_ENV_MLST_SET}" = false ]; then
                CONDA_ENV_MLST="$2"
            fi
            if [ "${CONDA_ENV_PROKKA_SET}" = false ]; then
                CONDA_ENV_PROKKA="$2"
            fi
            if [ "${CONDA_ENV_AMRFINDER_SET}" = false ]; then
                CONDA_ENV_AMRFINDER="$2"
            fi
            if [ "${CONDA_ENV_STATS_SET}" = false ]; then
                CONDA_ENV_STATS="$2"
            fi
            shift 2
            ;;
        --conda_bbmap)
            CONDA_ENV_BBMAP="$2"
            CONDA_ENV_BBMAP_SET=true
            shift 2
            ;;
        --conda_fastp)
            CONDA_ENV_FASTP="$2"
            CONDA_ENV_FASTP_SET=true
            shift 2
            ;;
        --conda_fastqc)
            CONDA_ENV_FASTQC="$2"
            CONDA_ENV_FASTQC_SET=true
            shift 2
            ;;
        --conda_kraken2)
            CONDA_ENV_KRAKEN2="$2"
            CONDA_ENV_KRAKEN2_SET=true
            shift 2
            ;;
        --conda_kronatools)
            CONDA_ENV_KRONATOOLS="$2"
            CONDA_ENV_KRONATOOLS_SET=true
            shift 2
            ;;
        --conda_spades)
            CONDA_ENV_SPADES="$2"
            CONDA_ENV_SPADES_SET=true
            shift 2
            ;;
        --conda_gamma)
            CONDA_ENV_GAMMA="$2"
            CONDA_ENV_GAMMA_SET=true
            shift 2
            ;;
        --conda_quast)
            CONDA_ENV_QUAST="$2"
            CONDA_ENV_QUAST_SET=true
            shift 2
            ;;
        --conda_mash)
            CONDA_ENV_MASH="$2"
            CONDA_ENV_MASH_SET=true
            shift 2
            ;;
        --conda_fastani)
            CONDA_ENV_FASTANI="$2"
            CONDA_ENV_FASTANI_SET=true
            shift 2
            ;;
        --conda_mlst)
            CONDA_ENV_MLST="$2"
            CONDA_ENV_MLST_SET=true
            shift 2
            ;;
        --conda_prokka)
            CONDA_ENV_PROKKA="$2"
            CONDA_ENV_PROKKA_SET=true
            shift 2
            ;;
        --conda_amrfinder)
            CONDA_ENV_AMRFINDER="$2"
            CONDA_ENV_AMRFINDER_SET=true
            shift 2
            ;;
        --conda_stats)
            CONDA_ENV_STATS="$2"
            CONDA_ENV_STATS_SET=true
            shift 2
            ;;
        --) shift; 
            break 
            ;;
    esac
done

if [ "${GENERATE_SAMPLESHEET}" = true ]; then
    ${WORK_DIR}/bin/generate_samplesheet.sh -d "${RAW_DATA_LOCATION}" -s ${SAMPLESHEET}
fi

# echo "RUN DETAILS"
# printf "%-20s:    %s\n" "RUN NAME" "${RUN_NAME}"
# printf "%-20s:    %s\n" "SAMPLESHEET" "${SAMPLESHEET}"
# printf "%-20s:    %s\n" "WORK DIR" "${WORK_DIR}"
# printf "%-20s:    %s\n" "RESULTS DIR" "${RESULTS_DIR}"
# printf "%-20s:    %s\n" "RUN DIR" "${RUN_DIR}"

# echo "DATABASES"
# printf "%-20s:    %s\n" "BBMAP" "${BBDUK_REF}"
# printf "%-20s:    %s\n" "KRAKEN" "${KRAKEN_DB}"
# printf "%-20s:    %s\n" "GAMMA HV" "${GAMMA_HVDB}"
# printf "%-20s:    %s\n" "GAMMA AR" "${GAMMA_ARDB}"
# printf "%-20s:    %s\n" "GAMMA PF" "${GAMMA_PFDB}"
# printf "%-20s:    %s\n" "MASH" "${ZIPPED_SKETCH}"
# printf "%-20s:    %s\n" "TAXA" "${TAXA}"
# printf "%-20s:    %s\n" "MLST" "${MLST_DB}"
# printf "%-20s:    %s\n" "ASSEMBLY STATS" "${NCBI_ASSEMBLY_STATS}"

# echo "CONDA ENVIRONMENTS"
# printf "%-20s:    %s\n" "CONDA LOCATION" "${CONDA_LOCATION}"
# printf "%-20s:    %s\n" "BBMAP" "${CONDA_ENV_BBMAP}"
# printf "%-20s:    %s\n" "FASTP" "${CONDA_ENV_FASTP}"
# printf "%-20s:    %s\n" "FASTQC" "${CONDA_ENV_FASTQC}"
# printf "%-20s:    %s\n" "KRAKEN2" "${CONDA_ENV_KRAKEN2}"
# printf "%-20s:    %s\n" "KRONATOOLS" "${CONDA_ENV_KRONATOOLS}"
# printf "%-20s:    %s\n" "SPADES" "${CONDA_ENV_SPADES}"
# printf "%-20s:    %s\n" "GAMMA" "${CONDA_ENV_GAMMA}"
# printf "%-20s:    %s\n" "QUAST" "${CONDA_ENV_QUAST}"
# printf "%-20s:    %s\n" "MASH" "${CONDA_ENV_MASH}"
# printf "%-20s:    %s\n" "FASTANI" "${CONDA_ENV_FASTANI}"
# printf "%-20s:    %s\n" "MLST" "${CONDA_ENV_MLST}"
# printf "%-20s:    %s\n" "PROKKA" "${CONDA_ENV_PROKKA}"
# printf "%-20s:    %s\n" "AMRFINDER" "${CONDA_ENV_AMRFINDER}"
# printf "%-20s:    %s\n" "STATS" "${CONDA_ENV_STATS}"

export RUN_NAME
export SAMPLESHEET
export WORK_DIR
export RESULTS_DIR
export RUN_DIR
export BBDUK_REF
export KRAKEN_DB
export GAMMA_HVDB
export DB_NAME_HV
export GAMMA_ARDB
export DB_NAME_AR
export GAMMA_PFDB
export DB_NAME_PF
export ZIPPED_SKETCH
export MASH_DB
export MASH_DB_VERSION
export TAXA
export MLST_DB
export NCBI_ASSEMBLY_STATS
export CONDA_LOCATION
export CONDA_ENV_BBMAP
export CONDA_ENV_FASTP
export CONDA_ENV_FASTQC
export CONDA_ENV_KRAKEN2
export CONDA_ENV_KRONATOOLS
export CONDA_ENV_SPADES
export CONDA_ENV_GAMMA
export CONDA_ENV_QUAST
export CONDA_ENV_MASH
export CONDA_ENV_FASTANI
export CONDA_ENV_MLST
export CONDA_ENV_PROKKA
export CONDA_ENV_AMRFINDER
export CONDA_ENV_STATS

echo `date -I'seconds'` >> times_${RUN_NAME}.txt
echo "" >> times_${RUN_NAME}.txt

global_start=`date +%s`
sed 1d ${SAMPLESHEET} | while read -r LINE || [ -n "${LINE}" ]; do

    SAMPLE_NAME=$( echo ${LINE} | cut -f 1 -d ',' )
    export SAMPLE_NAME

    READ_R1=$( echo ${LINE} | cut -f 2 -d ',' )
    export READ_R1

    READ_R2=$( echo ${LINE} | cut -f 3 -d ',' )
    export READ_R2

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

    export QC_DIR
    export KRAKEN_TRIMMED_DIR
    export SPADES_DIR
    export GAMMA_DIR
    export QUAST_DIR
    export KRAKEN_ASSEMBLY_DIR
    export MASH_DIR
    export MLST_DIR
    export AMR_DIR
    export ASSEMBLY_RATIO_DIR
    export STATS_DIR

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

; done

STATS_CPU=$(( THREADS / 2 ))
TOTAL_SAMPLES=$( cat ${SAMPLESHEET} | wc -l )
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
        -s ${SAMPLESHEET} \
        -a ${GAMMA_ARDB} \
        --output ${RESULTS_DIR}/summary/${RUN_NAME}_GRiPHin_Summary.xlsx \
        --coverage 30 \
        --phoenix
)

global_end=`date +%s`
global_runtime=$(( global_end - global_start ))

echo -e "Entire process took $(( global_runtime / 60  )) minutes.\n\n" >> times_${RUN_NAME}.txt
