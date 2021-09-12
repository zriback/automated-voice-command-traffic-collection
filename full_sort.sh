#!/bin/bash

# NOTE: execute this script within your full_dataset directory (PWD=/home/pi/full_dataset)

# For all CHILD directories:
# Rename all outXXXX PCAP files to numerically-ordered outXXXX PCAP files
# Rename all outXXXX WAV files to numerically-ordered outXXXX WAV files

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
