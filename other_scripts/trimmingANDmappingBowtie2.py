#!/usr/bin/env python
# coding: utf-8
import sys
import os
import argparse
from pathlib import Path

# Configure script arguments
parser = argparse.ArgumentParser(
    description="Pipeline for trimming and mapping RNAseq data.",
    epilog="Usage example: python script.py --list_of_data data.txt --trimming_out ./trimming_results --mapping_out ./mapping_results --index /path/to/index --threads 32"
)
parser.add_argument("--list_of_data", required=True, help="File containing the list of FASTQ data (pairs of paths separated by tabs).")
parser.add_argument("--trimming_out", required=True, help="Output directory for trimming results.")
parser.add_argument("--mapping_out", required=True, help="Output directory for mapping results.")
parser.add_argument("--index", required=True, help="Path to the reference genome index for Bowtie2.")
parser.add_argument("--threads", type=int, default=16, help="Number of threads to use for trimming and mapping processes (default: 16).")
args = parser.parse_args()

# Global variables
adapters = "/media/eduardo/D1/ncRNAs_Leishmania_spp/z_adapters_truseq.fasta"
trimming_out = args.trimming_out
mapping_out = args.mapping_out
index = args.index
threads = args.threads
paired_list_file = f"{trimming_out}/paired/paired.txt"

# Create output directories
Path(trimming_out).mkdir(parents=True, exist_ok=True)
Path(f"{trimming_out}/paired").mkdir(parents=True, exist_ok=True)
Path(f"{trimming_out}/unpaired").mkdir(parents=True, exist_ok=True)
Path(f"{trimming_out}/reports/json").mkdir(parents=True, exist_ok=True)
Path(f"{trimming_out}/reports/html").mkdir(parents=True, exist_ok=True)
Path(mapping_out).mkdir(parents=True, exist_ok=True)

# Step 1: Trimming
paired_files = []
with open(args.list_of_data, "r") as fp:
    for line in fp:
        line = line.rstrip()
        aux = line.split("\t")
        fn = aux[0].split("/")[-1].split("_")[0]

        # Define output paths for trimming
        p1 = f"{trimming_out}/paired/{fn}_paired1.fq.gz"
        p2 = f"{trimming_out}/paired/{fn}_paired2.fq.gz"
        up1 = f"{trimming_out}/unpaired/{fn}_unpaired1.fq.gz"
        up2 = f"{trimming_out}/unpaired/{fn}_unpaired2.fq.gz"
        jsonr = f"{trimming_out}/reports/json/{fn}_report.json"
        htmlr = f"{trimming_out}/reports/html/{fn}_report.html"

        # fastp command
        fastp_cmd = (
            f"fastp -i {aux[0]} -I {aux[1]} -o {p1} -O {p2} -q 30 -r -w {threads} "
            f"--unpaired1 {up1} --unpaired2 {up2} -f 10 -t 10 --detect_adapter_for_pe "
            f"--adapter_fasta {adapters} -j {jsonr} -h {htmlr}"
        )
        print("Running trimming step")
        os.system(fastp_cmd)
        print("End of trimming step")

        # Save file pairs for mapping
        paired_files.append(f"{p1}\t{p2}")

# Save the list of paired files
with open(paired_list_file, "w") as paired_fp:
    for pair in paired_files:
        paired_fp.write(pair + "\n")

# Step 2: Mapping
with open(paired_list_file, "r") as fp:
    for line in fp:
        line = line.rstrip()
        aux = line.split("\t")
        fn = aux[0].split("/")[-1].split("_")[0]

        # Define output paths for mapping
        sam = f"{mapping_out}/{fn}.sam"
        sorted_sam = f"{mapping_out}/{fn}_sorted.sam"
        bam = f"{mapping_out}/{fn}.bam"

        # Bowtie2 command
        bowtie2_cmd = (
            f"bowtie2 -p {threads} -N 1 --local -x {index} -1 {aux[0]} -2 {aux[1]} -S {sam}"
        )
        print("Running mapping using bowtie2")
        os.system(bowtie2_cmd)

        # Sort SAM
        sort_cmd = f"samtools sort --threads {threads} {sam} -o {sorted_sam}"
        os.system(sort_cmd)

        # Convert to BAM
        bam_cmd = f"samtools view -bS -@ {threads} -o {bam} {sorted_sam}"
        os.system(bam_cmd)

        # Remove intermediate files
        os.system(f"rm {sam} {sorted_sam}")
        print("End of mapping")
