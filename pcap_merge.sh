#!/bin/bash

# For ALL command directories in current_dataset
# Migrate all cmuXXX PCAP files to full_dataset

for dir in $(ls -d */); do
  mv -n -v ${dir}cmu*.pcap ~/full_dataset/$dir
done
