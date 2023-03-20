#!/bin/bash

# Function to convert one-letter residue code to three-letter code
function one_to_three_letter {
    case "$1" in
        A) echo ALA ;;
        C) echo CYS ;;
        D) echo ASP ;;
        E) echo GLU ;;
        F) echo PHE ;;
        G) echo GLY ;;
        H) echo HIS ;;
        I) echo ILE ;;
        K) echo LYS ;;
        L) echo LEU ;;
        M) echo MET ;;
        N) echo ASN ;;
        P) echo PRO ;;
        Q) echo GLN ;;
        R) echo ARG ;;
        S) echo SER ;;
        T) echo THR ;;
        V) echo VAL ;;
        W) echo TRP ;;
        Y) echo TYR ;;
        *) echo "Unknown residue code: $1" ; exit 4 ;;
    esac
}

# Function to return common atoms between two residues
function common_atoms {
    residue1="$1"
    residue2="$2"
    residue_atoms=(N CA C O)
    case "$residue1" in
        ARG|GLN|LYS) residue1_atoms=(CB CG CD CE) ;;
        ASN|ASP) residue1_atoms=(CB CG) ;;
        CYS) residue1_atoms=(CB) ;;
        GLU) residue1_atoms=(CB CG CD) ;;
        HIS|PHE|TRP|TYR) residue1_atoms=(CB CG CD CE) ;;
        ILE|LEU) residue1_atoms=(CB CG CD) ;;
        MET) residue1_atoms=(CB CG SD CE) ;;
        PRO) residue1_atoms=(CB CG CD) ;;
        SER|THR) residue1_atoms=(CB OG1) ;;
        VAL) residue1_atoms=(CB CG1) ;;
    esac
    case "$residue2" in
        ARG|GLN|LYS) residue2_atoms=(CB CG CD CE) ;;
        ASN|ASP) residue2_atoms=(CB CG) ;;
        CYS) residue2_atoms=(CB) ;;
        GLU) residue2_atoms=(CB CG CD) ;;
        HIS|PHE|TRP|TYR) residue2_atoms=(CB CG CD CE) ;;
        ILE|LEU) residue2_atoms=(CB CG CD) ;;
        MET) residue2_atoms=(CB CG SD CE) ;;
        PRO) residue2_atoms=(CB CG CD) ;;
        SER|THR) residue2_atoms=(CB OG1) ;;
        VAL) residue2_atoms=(CB CG1) ;;
    esac
    common_atoms_list=("${residue_atoms[@]}" "${residue1_atoms[@]}" "${residue2_atoms[@]}")
    printf '%s\n' "${common_atoms_list[@]}" | sort -u
}

# Check if the required arguments are provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <input_pdb_file> <output_pdb_file> <mutation_code>"
    exit 1
fi

input_pdb_file="$1"
output_pdb_file="$2"
mutation_code="$3"

# Check if the input PDB file exists
if [ ! -f "$input_pdb_file" ]; then
    echo "File not found: $input_pdb_file"
    exit 2
fi

# Extract the mutation information
original_residue=$(one_to_three_letter "${mutation_code:0:1}")
target_residue=$(one_to_three_letter "${mutation_code: -1}")
residue_position="${mutation_code:1:-1}"

# Check if the mutation code is valid
if [[ ! $original_residue ]] || [[ ! $target_residue ]] || [[ ! $residue_position =~ ^[0-9]+$ ]]; then
echo "Invalid mutation code: $mutation_code. Please use the format 'H161A'."
exit 3
fi

# Find common atoms between original and target residues
common_atoms_list=$(common_atoms "$original_residue" "$target_residue")

# Perform the mutation and create the output PDB file
awk -v orig_res="$original_residue" -v target_res="$target_residue" -v pos="$residue_position" -v common_atoms="$common_atoms_list" '
BEGIN {
# Convert common_atoms list to an array
split(common_atoms, common_atoms_array, "\n");
}
/^ATOM/ {
if ($4 == orig_res && $6 == pos) {
# Check if the atom is common between the original and target residues
found = 0;
for (i in common_atoms_array) {
if ($3 == common_atoms_array[i]) {
found = 1;
break;
}
}
if (found) {
# If the atom is common, apply the mutation
gsub(orig_res, target_res);
print;
} else {
# If the atom is not common, skip this line and do not print it
next;
}
} else {
print;
}
}
!/^ATOM/ {
print;
}
' "$input_pdb_file" > "$output_pdb_file"

echo "Mutation $mutation_code applied to $input_pdb_file and saved as $output_pdb_file."
