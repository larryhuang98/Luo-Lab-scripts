#!/bin/bash

# Name of the file to copy
source_file="tleap.sh"

# Check if the source file exists and is readable
if [ ! -r "$source_file" ]; then
  echo "Error: The source file '$source_file' is not found or not readable."
  exit 1
fi

# Iterate over all subfolders
for folder in */; do
  # Check if the folder is a directory
  if [ -d "$folder" ]; then
    # Remove the trailing slash from the folder name
    folder_name="${folder%/}"

    # Define the destination file name
    destination_file="${folder}tleap.sh"

    # Copy the source file to the destination file
    cp "$source_file" "$destination_file"

    # Replace 'wt' with the folder name in the destination file
    sed -i "s/wt/$folder_name/g" "$destination_file"

    # Change to the subfolder
    cd "$folder"

    # Make the tleap.sh script executable
    chmod +x tleap.sh

    # Run the tleap.sh script with nohup and send it to the background
    nohup ./tleap.sh &

    # Return to the parent directory
    cd ..

  else
    echo "Warning: Skipping '$folder' as it is not a directory."
  fi
done

