#!/bin/bash

# NOTE: execute this script within your full_dataset directory (PWD=/home/pi/full_dataset)

# For all CHILD directories:
# Rename all cmuXXX WAV files to outXXXX WAV files

for dir in $(ls -d */); do
  i=$(ls ${dir}out*.wav | wc -l)
  for orig in $(ls ${dir}cmu*.wav); do
    mv -n -v $orig ${dir}out$(printf "%04d" $i).wav
    ((i++))
  done
done
