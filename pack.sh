#!/bin/bash

# NOTE: execute this script within your full_dataset directory (PWD=/home/pi/full_dataset)

# For all CHILD directories:
# Pack all directories into compressed ZIP files

rm *.zip

for dir in $(ls -d */); do
  zip -r $(echo $dir | tr -d '/') "$dir"
done
