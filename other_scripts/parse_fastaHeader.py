import sys

def add_species_prefix(fasta_file):
    # Obtener el prefijo de la especie del nombre del archivo
    species_prefix = fasta_file.split('_')[0]
    output_file = f"{species_prefix}.fasta"
    
    with open(fasta_file, 'r') as infile, open(output_file, 'w') as outfile:
        for line in infile:
            if line.startswith('>'):
                # Agregar el prefijo de la especie al encabezado
                new_header = f">{species_prefix}|{line[1:]}"
                outfile.write(new_header)
            else:
                outfile.write(line)
    
    print(f"Archivo procesado. Salida guardada en {output_file}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Uso: python script.py <archivo_fasta>")
        sys.exit(1)
    
    fasta_file = sys.argv[1]
    add_species_prefix(fasta_file)
