#!/bin/bash

# For ALL command directories in full_dataset
# Rename all cmuXXX PCAP files to outXXXX PCAP files

for dir in $(ls -d */); do
  i=$(ls ${dir}out*.pcap | wc -l)
  for orig in $(ls ${dir}cmu*.pcap); do
    mv -n -v $orig ${dir}out$(printf "%04d" $i).pcap
    ((i++))
  done
done
