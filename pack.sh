#!/bin/bash

# For ALL command directories in current_dataset
# Pack all directories into compressed zip files

rm *.zip

for dir in $(ls -d */); do
  zip -r $(echo $dir | tr -d '/') "$dir"
done
