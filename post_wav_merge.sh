#!/bin/bash

# For ALL command directories in full_dataset
# Rename all cmuXXX WAV files to outXXXX WAV files

for dir in $(ls -d */); do
  i=$(ls ${dir}out*.wav | wc -l)
  for orig in $(ls ${dir}cmu*.wav); do
    mv -n -v $orig ${dir}out$(printf "%04d" $i).wav
    ((i++))
  done
done
