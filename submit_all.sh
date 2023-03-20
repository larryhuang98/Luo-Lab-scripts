#!/bin/bash

# Iterate over all subfolders
for folder in */; do
  cd "$folder"
  folder_name="${folder%/}"
  sed -i "s/wt/$folder_name/g" "submit_jobs.sh"
  sh submit_jobs.sh
  cd ../
done

