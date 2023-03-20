#!/bin/bash

# Name of the mutation script
mutation_script="./make_mutation.sh"

# Check if the mutation script exists and is executable
if [ ! -x "$mutation_script" ]; then
  echo "Error: The mutation script '$mutation_script' is not found or not executable."
  exit 1
fi

# Iterate over all subfolders
for folder in */; do
  # Check if the folder name matches the mutation code pattern (e.g., D196E)
  if [[ $folder =~ ^([A-Za-z])([0-9]+)([A-Za-z])/$ ]]; then
    # Extract the original residue, position, and target residue from the folder name
    original_residue="${BASH_REMATCH[1]}"
    residue_position="${BASH_REMATCH[2]}"
    target_residue="${BASH_REMATCH[3]}"

    # Adjust the residue position by subtracting 10
    adjusted_position=$((residue_position - 10))

    # Create the adjusted mutation code
    adjusted_code="${original_residue}${adjusted_position}${target_residue}"

    # Define the input and output file names
    input_file="${folder}wt_noH.pdb"
    output_file="${folder}${folder%/}_noH.pdb"

    # Run the mutation script with the adjusted mutation code
    "$mutation_script" "$input_file" "$output_file" "$adjusted_code"
  else
    echo "Warning: Skipping folder '$folder' as it does not match the mutation code pattern."
  fi
done

