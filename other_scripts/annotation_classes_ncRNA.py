import pandas as pd
import sys

def load_suffixes(suffix_file):
    """Loads the suffix file into a dictionary."""
    df_suffixes = pd.read_csv(suffix_file, sep='\t', header=0)
    suffix_dict = dict(zip(df_suffixes['old_subfijo'], df_suffixes['new_subfijo']))
    return suffix_dict

def process_bed(bed_file, suffix_dict, output_bed):
    """Processes the BED file, replacing suffixes according to the dictionary."""
    with open(bed_file, 'r') as bed, open(output_bed, 'w') as output:
        for line in bed:
            columns = line.strip().split("\t")
            if len(columns) < 4:
                output.write(line)
                continue
            
            prefix, suffix = columns[3].split("_", 1)  # Split into prefix and suffix
            new_suffix = suffix_dict.get(suffix, suffix)  # Replace if found in the dictionary
            
            columns[3] = f"{prefix}_{new_suffix}"  # Reconstruct the column
            output.write("\t".join(columns) + "\n")

def main():
    if len(sys.argv) != 4:
        print("Usage: python script.py <suffix_file> <bed_file> <output_bed>")
        sys.exit(1)

    suffix_file = sys.argv[1]
    bed_file = sys.argv[2]
    output_bed = sys.argv[3]

    suffix_dict = load_suffixes(suffix_file)
    process_bed(bed_file, suffix_dict, output_bed)
    print(f"Processed file saved in: {output_bed}")

if __name__ == "__main__":
    main()
