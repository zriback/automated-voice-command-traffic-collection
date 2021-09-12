#!/bin/bash

# For ALL command directories in current_dataset
# Migrate all cmuXXX WAV files to full_dataset

for dir in $(ls -d */); do
  mv -n -v ${dir}cmu*.wav ~/full_dataset/$dir
done
