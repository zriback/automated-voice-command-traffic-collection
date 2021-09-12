#!/bin/bash

# NOTE: execute this script within your current_dataset directory (PWD=/home/pi/current_dataset)

# For all CHILD directories:
# Move all cmuXXX WAV files into each ~/full_dataset/<child_directory>

for dir in $(ls -d */); do
  mv -n -v ${dir}cmu*.wav ~/full_dataset/$dir
done
