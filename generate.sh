#!/bin/bash

#voices=(cmu_us_aew cmu_us_ahw cmu_us_aup cmu_us_awb cmu_us_axb cmu_us_bdl cmu_us_clb cmu_us_eey cmu_us_fem cmu_us_gka cmu_us_jmk cmu_us_ksp cmu_us_ljm cmu_us_rms cmu_us_rxr cmu_us_slt)
voices=(cmu_us_aew cmu_us_ahw cmu_us_awb cmu_us_bdl cmu_us_clb cmu_us_fem cmu_us_gka cmu_us_jmk cmu_us_ksp cmu_us_ljm cmu_us_rms cmu_us_rxr cmu_us_slt)
#voices=(cmu_us_awb)

# Prompt for data directory paths
while read -p "Enter the dataset directory [current_dataset]: " dataset_dir && dataset_dir=${dataset_dir:-current_dataset} && [ ! -d $dataset_dir ]; do
  echo "Directory doesn't exist"
done; echo -e "Using directory $dataset_dir\n"
while read -p "Enter the command directory [$dataset_dir/commands]: " command_dir && command_dir=${command_dir:-$dataset_dir/commands} && [ ! -d $command_dir ]; do
  echo "Directory doesn't exist"
done; echo -e "Using directory $command_dir\n"

# Adjust the speed: flite -s duration_stretch=1.5
# Adjust the average pitch: flite -s int_f0_target_mean=145.0
# Adjust the standard deviation of pitch: -s int_f0_target_stddev=25.0

for voice in ${voices[@]}; do
  for command_subdir in $command_dir/*; do
    command=$(echo $command_subdir | rev | cut -f 1 -d "/" | rev | sed 's/_/ /g')

    set -x

    find $command_subdir -type f -name ${voice}_in001.wav -exec rm -f {} \; # Clears ONLY the file(s) corresponding to the selected voice
    flite -voice voices/$voice.flitevox -o $command_subdir/${voice}_in001.wav -t "$command" -s "duration_stretch=1.00"

    find $command_subdir -type f -name ${voice}_in002.wav -exec rm -f {} \; # Clears ONLY the file(s) corresponding to the selected voice
    flite -voice voices/$voice.flitevox -o $command_subdir/${voice}_in002.wav -t "$command" -s "duration_stretch=1.25"

    find $command_subdir -type f -name ${voice}_in003.wav -exec rm -f {} \; # Clears ONLY the file(s) corresponding to the selected voice
    flite -voice voices/$voice.flitevox -o $command_subdir/${voice}_in003.wav -t "$command" -s "duration_stretch=1.50"

    find $command_subdir -type f -name ${voice}_in004.wav -exec rm -f {} \; # Clears ONLY the file(s) corresponding to the selected voice
    flite -voice voices/$voice.flitevox -o $command_subdir/${voice}_in004.wav -t "$command" -s "duration_stretch=1.00" -s "int_f0_target_stddev=50.0"

    find $command_subdir -type f -name ${voice}_in005.wav -exec rm -f {} \; # Clears ONLY the file(s) corresponding to the selected voice
    flite -voice voices/$voice.flitevox -o $command_subdir/${voice}_in005.wav -t "$command" -s "duration_stretch=1.00" -s "int_f0_target_stddev=75.0"

    find $command_subdir -type f -name ${voice}_in006.wav -exec rm -f {} \; # Clears ONLY the file(s) corresponding to the selected voice
    flite -voice voices/$voice.flitevox -o $command_subdir/${voice}_in006.wav -t "$command" -s "duration_stretch=1.25" -s "int_f0_target_stddev=50.0"

    find $command_subdir -type f -name ${voice}_in007.wav -exec rm -f {} \; # Clears ONLY the file(s) corresponding to the selected voice
    flite -voice voices/$voice.flitevox -o $command_subdir/${voice}_in007.wav -t "$command" -s "duration_stretch=1.25" -s "int_f0_target_stddev=75.0"

    find $command_subdir -type f -name ${voice}_in008.wav -exec rm -f {} \; # Clears ONLY the file(s) corresponding to the selected voice
    flite -voice voices/$voice.flitevox -o $command_subdir/${voice}_in008.wav -t "$command" -s "duration_stretch=1.50" -s "int_f0_target_stddev=50.0"

    find $command_subdir -type f -name ${voice}_in009.wav -exec rm -f {} \; # Clears ONLY the file(s) corresponding to the selected voice
    flite -voice voices/$voice.flitevox -o $command_subdir/${voice}_in009.wav -t "$command" -s "duration_stretch=1.50" -s "int_f0_target_stddev=75.0"

    set +x
  done
done
