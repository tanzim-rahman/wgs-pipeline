#!/usr/bin/env python3

## orginal script from https://github.com/dayedepps/q30/blob/master/fastq.py
## modified to be python3 not 2 and added read count. 
## by Jill Hagey qpk9@cdc.gov 4/3/2023

import os,sys
#disable cache usage in the Python so __pycache__ isn't formed. If you don't do this using 'nextflow run cdcgov/phoenix...' a second time will causes and error
sys.dont_write_bytecode = True # needs to be before the import fastq
import fastq
import time

def qual_stat(qstr):
    q20 = 0
    q30 = 0
    for q in qstr:
        qual = ord(q) - 33
        #qual = ord(q) - 33 #python2 version
        if qual >= 30:
            q30 += 1
            q20 += 1
        elif qual >= 20:
            q20 += 1
    return q20, q30

def stat(filename, output_file):

    reader = fastq.read(filename)
    total_read_count = 0
    total_base_count = 0
    q20_count = 0
    q30_count = 0

    for read in reader:

        total_read_count = total_read_count + 1
        total_base_count += len(read.getQual())
        q20, q30 = qual_stat(read.getQual())
        q20_count += q20
        q30_count += q30

    with open(output_file, 'w') as file:
        file.write(f'total reads: {total_read_count}\n')
        file.write(f'total bases: {total_base_count}\n')
        file.write(f'q20 bases: {q20_count}\n')
        file.write(f'q30 bases: {q30_count}\n')
        file.write(f'q20 percents: {100 * float(q20_count)/float(total_base_count)}\n')
        file.write(f'q30 percents: {100 * float(q30_count)/float(total_base_count)}')

def main():

    if len(sys.argv) < 3:
        print("usage: python q30.py <fastq_file> <output_file>")
        sys.exit(1)
    stat(sys.argv[1], sys.argv[2])

if __name__ == "__main__":
    time1 = time.time()
    main()
    time2 = time.time()
    print('Time used: ' + str(time2-time1))
