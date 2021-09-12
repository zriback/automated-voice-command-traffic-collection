#!/bin/bash

# NOTE: execute this script within your full_dataset directory (PWD=/home/pi/full_dataset)

# For all CHILD directories:
# Rename all cmuXXX PCAP files to outXXXX PCAP files

for dir in $(ls -d */); do
  i=$(ls ${dir}out*.pcap | wc -l)
  for orig in $(ls ${dir}cmu*.pcap); do
    mv -n -v $orig ${dir}out$(printf "%04d" $i).pcap
    ((i++))
  done
done
