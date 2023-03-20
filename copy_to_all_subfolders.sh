#!/bin/bash

# Check if the required arguments are provided
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <file1> [<file2> ... <fileN>]"
    exit 1
fi

# Loop through each file and check if it exists
for file_to_copy in "$@"; do
    if [ ! -f "$file_to_copy" ]; then
        echo "File not found: $file_to_copy"
        exit 2
    fi
done

# Find all directories under the current directory and copy the files to them
for file_to_copy in "$@"; do
    find . -type d -exec cp -v "$file_to_copy" '{}' \;
done

echo "Files copied to all subfolders successfully."
