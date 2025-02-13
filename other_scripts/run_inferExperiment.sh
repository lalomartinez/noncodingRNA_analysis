#!/bin/bash

# Directorio de archivos BAM
BAM_DIR="/media/eduardo/D1/ncRNAs_Leishmania_spp/RNAseq/Lmajor/analysis/02_mapping"
# Archivo BED de referencia
BED_FILE="/media/eduardo/D1/ncRNAs_Leishmania_spp/genome_info/tritryp_66_gff/bed/LmajorFriedlin.bed"
# Directorio de salida
OUTPUT_DIR="/media/eduardo/D1/ncRNAs_Leishmania_spp/RNAseq/Lmajor/analysis/03_inferExperiment"

# Crear el directorio de salida si no existe
mkdir -p ${OUTPUT_DIR}

# Iterar sobre los archivos BAM en el directorio especificado
for BAM_FILE in ${BAM_DIR}/*.bam; do
    # Extraer el nombre base del archivo BAM (sin extensión)
    BASENAME=$(basename "${BAM_FILE}" .bam)
    
    # Nombre del archivo de salida
    OUTPUT_FILE="${OUTPUT_DIR}/${BASENAME}_InferExperiment.txt"
    
    # Ejecutar infer_experiment.py y redirigir el resultado al archivo de salida
    echo "Procesando ${BAM_FILE}..."
    infer_experiment.py -i "${BAM_FILE}" -r "${BED_FILE}" > "${OUTPUT_FILE}"
    
    echo "Resultado guardado en ${OUTPUT_FILE}"
done

echo "Análisis completado para todos los archivos BAM."
