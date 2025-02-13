import subprocess
import argparse
import os
import pandas as pd

def merge_bed_files(input_file1, input_file2, input_file3, output_directory):
    try:
        # Obtener el nombre base del primer archivo de entrada
        base_name = os.path.basename(input_file1).split(".")[0]
        base_name_f =  base_name.split("_")[0]
        output_file = os.path.join(output_directory, f"{base_name_f}_merged.bed")

        # Construir el comando para concatenar, ordenar y fusionar archivos BED
        command = (
            f"cat {input_file1} {input_file2} {input_file3}| "
            "sortBed -i - | "
            "mergeBed -i - -s -c 4,5,6 -o collapse,mean,distinct -delim \"|\" > "
            f"{output_file}"
        )

        # Ejecutar el comando en la terminal
        subprocess.run(command, shell=True, check=True)
        print(f"Archivos fusionados correctamente y guardados en: {output_file}")

        return output_file

    except subprocess.CalledProcessError as e:
        print(f"Error al ejecutar el comando: {e}")
        return None

def process_bed(input_file, output_file):
    # Leer el archivo BED con pandas
    bed_columns = ["chrom", "start", "end", "info", "score", "strand"]
    bed_data = pd.read_csv(input_file, sep="\t", header=None, names=bed_columns)

    # Agregar nombres genéricos en la columna 4 con un contador
    bed_data["info"] = [
        f"ncRNA{str(i+1).zfill(5)}_{info}" 
        for i, info in enumerate(bed_data["info"])
    ]

    # Guardar el archivo BED modificado
    bed_data.to_csv(output_file, sep="\t", header=False, index=False)
    print(f"Archivo procesado y guardado en: {output_file}")

def main():
    # Crear el parser de argumentos
    parser = argparse.ArgumentParser(description="Flujo de trabajo para fusionar y procesar archivos BED.")
    parser.add_argument("input_file1", help="Ruta del primer archivo BED de entrada.")
    parser.add_argument("input_file2", help="Ruta del segundo archivo BED de entrada.")
    parser.add_argument("input_file3", help="Ruta del tercer archivo BED de entrada.")
    parser.add_argument("output_directory", help="Directorio donde se guardará el archivo fusionado y procesado.")

    # Parsear los argumentos
    args = parser.parse_args()

    # Fusionar los archivos BED
    merged_file = merge_bed_files(args.input_file1, args.input_file2,  args.input_file3, args.output_directory)

    if merged_file:
        # Procesar el archivo fusionado
        base_name = os.path.basename(merged_file).split(".")[0]
        processed_file = os.path.join(args.output_directory, f"{base_name}_processed.bed")
        process_bed(merged_file, processed_file)

if __name__ == "__main__":
    main()
