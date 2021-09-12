#!/bin/bash

# For ALL command directories in full_dataset
# Rename all outXXXX PCAP files to outXXXX PCAP files
# Rename all outXXXX WAV files to outXXXX WAV files

for dir in $(ls -d */); do
  i=0
  for orig in $(ls ${dir}out*.pcap); do
    mv -n -v $orig ${dir}out$(printf "%04d" $i).pcap
    ((i++))
  done

  i=0
  for orig in $(ls ${dir}out*.wav); do
    mv -n -v $orig ${dir}out$(printf "%04d" $i).wav
    ((i++))
  done
done
