#!/usr/bin/env bash

# Function to print out help blurb
show_help () {
    echo ""
	echo "Usage: ./generate_samplesheet.sh -d fastq_directory [-s samplesheet_path]"
    echo -e "\t-d\tFull Path to directory containing sample fastq files. Must NOT end with '/'"
    echo -e "\t-s\t[Optional] Path to samplesheet to be created. By default creates a samplesheet.csv in the current directory."
}

# Parse command line options
while getopts ":h?d:s:" option; do
	case "${option}" in
		\?)
			echo "Invalid option found: ${OPTARG}"
			show_help
			exit 0
			;;
		d)
			FASTQ_DIR=${OPTARG};;
		s)
			SAMPLESHEET_PATH=${OPTARG};;
		:)
			echo "Option -${OPTARG} requires as argument";;
		h)
			show_help
			exit 0
			;;
	esac
done

if [ -z "${SAMPLESHEET_PATH}" ]; then
    SAMPLESHEET_PATH="./samplesheet.csv"
fi

printf "sample,fastq_1,fastq_2" > ${SAMPLESHEET_PATH}
SAMPLES=$( ls ${FASTQ_DIR} | sed -n "s|\(.*\)_\([R]*\)1\([._].*\)|\1,${FASTQ_DIR}/\1_\21\3,${FASTQ_DIR}/\1_\22\3|p" )
for SAMPLE in ${SAMPLES[@]}; do
    printf "\n${SAMPLE}" >> ${SAMPLESHEET_PATH}
done
