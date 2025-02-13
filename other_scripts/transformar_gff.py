import re
import argparse

# Función para transformar el archivo GFF
def transformar_gff(input_file, output_file):
    with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
        for line in infile:
            # Escribe las líneas de encabezado directamente
            if line.startswith('##'):
                outfile.write(line)
                continue

            # Divide la línea en columnas
            columns = line.strip().split('\t')
            if len(columns) < 9:
                outfile.write(line)
                continue

            # Extrae el atributo "Name="
            attributes = columns[8]
            match_name = re.search(r'Name=([^;]+)', attributes)
            if not match_name:
                outfile.write(line)
                continue

            name = match_name.group(1)
            base_name = name.split('_')[0]  # Extrae la base del nombre (antes de "_")

            # Modifica el campo ID y Parent según el tipo de característica
            feature_type = columns[2]
            if feature_type == "gene":
                new_id = f"gene_{base_name}"
                columns[8] = re.sub(r'ID=[^;]+', f'ID={new_id}', attributes)

            elif feature_type == "ncRNA":
                parent_id = f"gene_{base_name}"
                new_id = base_name
                attributes = re.sub(r'ID=[^;]+', f'ID={new_id}', attributes)
                attributes = re.sub(r'Parent=[^;]*', f'Parent={parent_id}', attributes)
                columns[8] = attributes

            elif feature_type == "exon":
                parent_id = base_name  # Parent debe apuntar al ID del ncRNA
                gene_id = f"gene_{base_name}"  # Generar el gene_id correspondiente
                new_id = f"exon_{base_name}"  # Generar el ID del exon

                # Actualiza ID
                attributes = re.sub(r'ID=[^;]+', f'ID={new_id}', attributes)

                # Actualiza Parent
                attributes = re.sub(r'Parent=[^;]*', f'Parent={parent_id}', attributes)

                # Añade gene_id si no está presente
                if not re.search(r'gene_id=', attributes):
                    attributes += f';gene_id={gene_id}'

                # Actualiza los atributos en la columna correspondiente
                columns[8] = attributes
            # Escribe la línea modificada
            outfile.write('\t'.join(columns) + '\n')

# Argumentos de línea de comandos
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Transformar un archivo GFF según reglas específicas.")
    parser.add_argument("input_file", help="Ruta del archivo GFF de entrada.")
    parser.add_argument("output_file", help="Ruta del archivo GFF de salida.")
    args = parser.parse_args()

    # Llamada a la función
    transformar_gff(args.input_file, args.output_file)

    print(f"Archivo transformado guardado en: {args.output_file}")

