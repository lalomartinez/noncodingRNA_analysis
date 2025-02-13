#!/bin/bash

#Script to run StructRNAfinder, requires a list of genomes in FASTA format "FASTA_FILES"
#as well as the path to the Rfam models "RFAM_MODELS", the path to StructRNAfinder "STRUCTRNAFINDER"
#the name of the folder where the program outputs will be saved "OUTPUT_DIR" and the number of threads to use "THREADS"
# To Run this script need to install structRNAfinder 
# https://github.com/viniciusmaracaja/structRNAfinder


#Input paths and parameters
FASTA_FILES=(
    "/home/emartinez/tritryp_66_genome/ncbi_LdonovaniAG83_genome.fasta"
    "/home/emartinez/tritryp_66_genome/ncbi_LdonovaniPasteur_genome.fasta"
    "/home/emartinez/tritryp_66_genome/ncbi_LinfantumTR01_genome.fasta"
    "/home/emartinez/tritryp_66_genome/ncbi_LmajorSD75_genome.fasta"
    "/home/emartinez/tritryp_66_genome/ncbi_LperuvianaPAB-4377_genome.fasta"
    "/home/emartinez/tritryp_66_genome/ncbi_LspLD974_genome.fasta"
    "/home/emartinez/tritryp_66_genome/TriTrypDB-66_LaethiopicaL147_Genome.fasta"
    "/home/emartinez/tritryp_66_genome/TriTrypDB-66_LamazonensisMHOMBR71973M2269_Genome.fasta"
    "/home/emartinez/tritryp_66_genome/TriTrypDB-66_LarabicaLEM1108_Genome.fasta"
    "/home/emartinez/tritryp_66_genome/TriTrypDB-66_LbraziliensisMHOMBR75M2903_Genome.fasta"
    "/home/emartinez/tritryp_66_genome/TriTrypDB-66_LbraziliensisMHOMBR75M2904_Genome.fasta"
    "/home/emartinez/tritryp_66_genome/TriTrypDB-66_LdonovaniBHU1220_Genome.fasta"
    "/home/emartinez/tritryp_66_genome/TriTrypDB-66_LdonovaniBPK282A1_Genome.fasta"
    "/home/emartinez/tritryp_66_genome/TriTrypDB-66_LenriettiiLEM3045_Genome.fasta"
    "/home/emartinez/tritryp_66_genome/TriTrypDB-66_LgerbilliLEM452_Genome.fasta"
    "/home/emartinez/tritryp_66_genome/TriTrypDB-66_LinfantumJPCM5_Genome.fasta"
    "/home/emartinez/tritryp_66_genome/TriTrypDB-66_LmajorFriedlin_Genome.fasta"
    "/home/emartinez/tritryp_66_genome/TriTrypDB-66_LmajorLV39c5_Genome.fasta"
    "/home/emartinez/tritryp_66_genome/TriTrypDB-66_LmartiniquensisLEM2494_Genome.fasta"
    "/home/emartinez/tritryp_66_genome/TriTrypDB-66_LmexicanaMHOMGT2001U1103_Genome.fasta"
    "/home/emartinez/tritryp_66_genome/TriTrypDB-66_LpanamensisMHOMCOL81L13_Genome.fasta"
    "/home/emartinez/tritryp_66_genome/TriTrypDB-66_LpanamensisMHOMPA94PSC1_Genome.fasta"
    "/home/emartinez/tritryp_66_genome/TriTrypDB-66_LtarentolaeParrotTarII_Genome.fasta"
    "/home/emartinez/tritryp_66_genome/TriTrypDB-66_LtropicaL590_Genome.fasta"
    "/home/emartinez/tritryp_66_genome/TriTrypDB-66_LturanicaLEM423_Genome.fasta"
)
RFAM_MODELS="/opt/tools/structRNAfinder-master/Rfam/Rfam.cm"
STRUCTRNAFINDER="/opt/tools/structRNAfinder-master/bin/structRNAfinder"
OUTPUT_DIR="/home/emartinez/struct_search"
THREADS=64

# make output directory 
mkdir -p "$OUTPUT_DIR"

# Iterate over the FASTA files

for FASTA_FILE in "${FASTA_FILES[@]}"; do
    # Extract the base name of the FASTA file (between underscores)
    BASE_NAME=$(basename "$FASTA_FILE" .fasta | awk -F"_" '{print $2}')

    # Create a subdirectory for the current file
    SUBDIR="$OUTPUT_DIR/$BASE_NAME"
    mkdir -p "$SUBDIR"

    # Define output paths for the parameters -t and -o
    TABLE_OUTPUT="$SUBDIR/${BASE_NAME}.tab"
    INFERNAL_OUTPUT="$SUBDIR/${BASE_NAME}"

    # move to the subdirectory
    cd "$SUBDIR"

    # Execute structRNAfinder
    "$STRUCTRNAFINDER" \
        -i "$FASTA_FILE" \
        -d "$RFAM_MODELS" \
        -m cmscan \
        -r \
        -t "$TABLE_OUTPUT" \
        -o "$INFERNAL_OUTPUT" \
        -c "$THREADS"

done

# Return to the original directory
cd "$OUTPUT_DIR"

echo "ncRNA prediction with StructRNAfinder completed."