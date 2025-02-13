#!/usr/bin/env python
# coding: utf-8

"""
This script downloads sequencing data from the SRA database using prefetch and converts it to FASTQ format using fasterq-dump.

Usage:
    python3 download_data_SRA.py <list_of_accession.txt> <number_of_threads>

Arguments:
    <list_of_accession.txt>: A text file containing a list of SRA accession IDs (one per line).
    <number_of_threads>: The number of threads to use for fasterq-dump (e.g., 6).

Example:
    python3 download_data_SRA.py /path/to/list_of_accession.txt 6

Steps:
    1. Downloads SRA files using prefetch.
    2. Converts SRA files to FASTQ format using fasterq-dump.
    3. Compresses the FASTQ files using gzip.
    4. Removes the original SRA files to save space.

Dependencies:
    - prefetch (from SRA Toolkit)
    - fasterq-dump (from SRA Toolkit)
    - gzip (command-line tool)

"""

import os
import sys

# Display help message if arguments are missing
if len(sys.argv) != 3:
    print("""
    Usage: python3 download_data_SRA.py <list_of_accession.txt> <number_of_threads>

    Arguments:
        <list_of_accession.txt>: A text file containing a list of SRA accession IDs (one per line).
        <number_of_threads>: The number of threads to use for fasterq-dump (e.g., 6).

    Example:
        python3 download_data_SRA.py /path/to/list_of_accession.txt 6
    """)
    sys.exit(1)

list_of_data = sys.argv[1]
threads = sys.argv[2]

name= list_of_data.split("/")
name1=name[-1].split(".")
folder_name= name1[0]
path="/".join(name[:-1])
folder=path+"/"+folder_name

with open(list_of_data, "r") as fp:
    for line in fp:
        aux= line.rstrip()
        cmd= "prefetch "+ aux +" -O " + folder
        os.system(cmd)
        nfolder=folder+"/"+aux+"/"+aux+".sra"
        cmd2= "fasterq-dump --split-files " + nfolder + " -O "+ folder+"/"+aux + " -e " +threads
        os.system(cmd2)
        cmd3= "gzip " + folder+"/"+aux+"/"+"*.fastq"
        os.system(cmd3)
        cmd4="rm "+ nfolder
        os.system(cmd4)
