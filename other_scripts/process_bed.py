import pandas as pd
import argparse

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
    print(f"File processed and saved in: {output_file}")

def main():
    # Crear el parser de argumentos
    parser = argparse.ArgumentParser(description="Script for processing BED file.")
    parser.add_argument("-i", "--input", required=True, help="input BED")
    parser.add_argument("-o", "--output", required=True, help="output BED")

    # Parsear los argumentos
    args = parser.parse_args()

    # Llamar a la función de procesamiento
    process_bed(args.input, args.output)

if __name__ == "__main__":
    main()
