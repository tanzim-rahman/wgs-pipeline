# WGS Pipeline

## Introduction

This repository is based on the [*Phoenix*](https://github.com/CDCgov/phoenix) pipeline by the [Centers for Disease Control and Prevention (CDC)](https://github.com/CDCgov).

It has been converted from a parallel pipeline that uses [NextFlow](https://www.nextflow.io) to a sequential pipeline that uses simple Bash scripts.

## Table of Contents

1. [Prerequisites](#rerequisites)

2. [How to use](#how-to-use)

3. [Samplesheet format](#samplesheet-format)

4. [Files and directories](#files-and-directories)

5. [Workflow overview](#workflow-overview)

## Prerequisites

- [Anaconda](https://www.anaconda.com)

- [BBMap](https://github.com/BioInfoTools/BBMap)

- [FastP](https://github.com/OpenGene/fastp)

- [FastQC](https://github.com/s-andrews/FastQC)

- [Kraken2](https://github.com/DerrickWood/kraken2)

    Note: The Kraken2 database must be the public Standard-8 version and created **on or after March 14th, 2023**. It can be downloaded from [Ben Langmead's github page](https://benlangmead.github.io/aws-indexes/k2).

- [KronaTools](https://github.com/marbl/Krona/tree/master/KronaTools)

- [Spades](https://github.com/ablab/spades)

- [GAMMA](https://github.com/rastanton/GAMMA)

- [Quast](https://github.com/ablab/quast)

- [Mash](https://github.com/marbl/Mash)

- [FastANI](https://github.com/ParBLiSS/FastANI)

- [MLST](https://github.com/tseemann/mlst)

- [Prokka](https://github.com/tseemann/prokka)

- [AMRFinderPlus](https://github.com/ncbi/amr)

## How to use

1. Clone the repository.

    `git clone https://github.com/tanzim-rahman/wgs-pipeline.git`

2. *[OPTIONAL]* Create a samplesheet file. See Section *Samplesheet format* for more details.

3. *[OPTIONAL]* Edit the *config.sh* file to set all run parameters.

4. Run the *wgs-pipeline.sh* file using
```
./wgs-pipeline.sh [OPTIONS]
```
Options that are **NOT** provided will be automatically imported from the *config.sh* file.

### Command line arguments

- -h/--help
    - Show the help dialog.
- -n/--run_name **NAME**
    - Sets the name of the current run to **NAME**. Final GRiPHin summary file has this prefix.
- -w/--work_dir **DIR**
    - Working directory. Must contain the *wgs-pipeline.sh* and *config.sh* files as well as the bin directory.
- -s/--samplesheet **FILE**
    - Full path to the samplesheet file. If *--generate_samplesheet **DIR*** is provided, this samplesheet file is automatically created from the samples contained in **DIR** directory.
- -g/--generate_samplesheet **DIR**
    - Automatically generates a samplesheet file using the **DIR** directory and saves to the *-s/--samplesheet **FILE*** location. The samples in **DIR** must have the extension fastq.gz or fq.gz and must also contain either _R1/_R2 or _1/_2 in their names to distinguish between reads.
- -r/--results_dir **DIR**
    - Directory where the run results will be stored. Indiviual sample results are stored in **DIR**/runs/{sample_name}/ while the run summary results are stored in **DIR**/summary/.
- --**REF** **DIR/FILE**
    - Sets the various references to either **DIR** or **FILE**. To be extra secure, use full path names. **REF** options include *--bbduk_ref **FILE***, *--kraken2_db **DIR***, *--gamma_{hv|ar|pf} **FILE***, *--mash_db **FILE***, *--taxa **FILE***, *--mlst_db **DIR/FILE*** and *--assembly_stats **FILE***.
- --conda **FILE**
    - Location of the *conda.sh* file. This is used in order to activate conda environments.
- --conda_all **NAME**
    - Sets the name of the conda environment containing all programs to **NAME**.
- --conda_**PROGRAM** **NAME**
    - Sets the name of the conda environment that contains **PROGRAM** to **NAME**. Overwrites --conda_all. **PROGRAM** options include *bbduk*, *fastp*, *fastqc*, *kraken2*, *kronatools*, *spades*, *gamma*, *quast*, *mash*, *fastani*, *mlst*, *prokka*, *amrfinder* and *stats*. *--conda_stats* is an environment that contains the python module *fastq*.

## Samplesheet format

The samplesheet must be in CSV format according to the [*Phoenix* pipeline guidelines](https://github.com/CDCgov/phoenix/wiki/Running-PHoeNIx#reads-samplesheet).

The first three columns of the samplesheet must contain the *Sample Name*, *Full Path to Read 1* and *Full Path to Read 2*.

```
sample,fastq_1,fastq_2
SAMPLE_1,$PATH/AEG588A1_S1_L002_R1_001.fastq.gz,AEG588A1_S1_L002_R2_001.fastq.gz
SAMPLE_2,$PATH/AEG588A2_S2_L002_R1_001.fastq.gz,AEG588A2_S2_L002_R2_001.fastq.gz
SAMPLE_3,$PATH/AEG588A3_S3_L002_R1_001.fastq.gz,AEG588A3_S3_L002_R2_001.fastq.gz
```

The reads must be in gzipped FastQ format and have either *.fastq.gz* or *.fq.gz* as their extension.

## Files and directories

- **bin**: contains the scripts used in the pipeline.

- **bin/phoenix**: contains scripts taken directly from the *Phoenix* pipeline. Some files have been modified slightly in order to avoid compatibility issues.

- **config.sh**: Contains the run parameters. Must be set before the pipeline is run.

- **flowchart.svg**: Flowchart for the pipeline.

- **wgs-pipeline.sh**: The main pipeline script.

- **README.md**: You are currently here.

## Workflow overview

<img src="flowchart.svg" alt="Pipeline flowchart" width="100%"/>
