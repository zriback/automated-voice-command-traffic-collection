#!/bin/bash

# Prompt for directory containing all capture output
while read -p "Enter the wav directory [./capture_output]: " cap_dir && cap_dir=${cap_dir:-./capture_output} && [ ! -d $cap_dir ]; do
  echo "Directory doesn't exist"
done
echo -e "Using directory $cap_dir\n"


for command_dir in $cap_dir/*; do
  for wav in $command_dir/*.wav; do
    
    echo Fixing $wav
    # Get temporary name for the file. Original name will be returned to later
    temp_name=.$(echo $wav | rev | cut -d'.' -f 2 | rev)_trimmed.wav
    
    # Remove silence from both ends
    sox $wav $temp_name silence 1 0.1 20% reverse silence 1 0.1 20% reverse 
    mv $temp_name $wav

    # Decrease volume of output file
    sox -v 0.3 $wav $temp_name
    mv $temp_name $wav

  done
done

