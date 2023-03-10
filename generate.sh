#!/bin/bash

#voices=(cmu_us_aew cmu_us_ahw cmu_us_aup cmu_us_awb cmu_us_axb cmu_us_bdl cmu_us_clb cmu_us_eey cmu_us_fem cmu_us_gka cmu_us_jmk cmu_us_ksp cmu_us_ljm cmu_us_rms cmu_us_rxr cmu_us_slt)
#voices=(cmu_us_aew cmu_us_awb cmu_us_bdl cmu_us_clb cmu_us_fem cmu_us_gka cmu_us_jmk cmu_us_ksp cmu_us_ljm cmu_us_rms cmu_us_rxr cmu_us_slt)
voices=(cmu_us_awb cmu_us_bdl)

output_dir="wav_output"

# Prompt for data directory paths
while read -p "Enter the dataset directory [current_dataset]: " dataset_dir && dataset_dir=${dataset_dir:-current_dataset} && [ ! -d $dataset_dir ]; do
  echo "Directory doesn't exist"
done; echo -e "Using directory $dataset_dir\n"
while read -p "Enter the voice_commands file [$dataset_dir/voice_commands]: " voice_commands && voice_commands=${voice_commands:-$dataset_dir/voice_commands} && [ ! -f $voice_commands ]; do
  echo "File does not exist"
done; echo -e "Using commands file $voice_commands\n"

# Adjust the speed: flite -s duration_stretch=1.5
# Adjust the average pitch: flite -s int_f0_target_mean=145.0
# Adjust the standard deviation of pitch: -s int_f0_target_stddev=25.0

# remove old wav files in $output_dir (if it exists)
rm -r $output_dir/*.wav 2>/dev/null
mkdir $dataset_dir/$output_dir 2>/dev/null

for voice in ${voices[@]}; do
  cat $dataset_dir/$voice_commands | grep -v "^#" | grep . | while read -r command ; do
    # echo $command
    command_subdir=$(echo $command | sed 's/ /-/g')
    mkdir $dataset_dir/$output_dir/$command_subdir 2>/dev/null

    set -x

    flite -voice voices/$voice.flitevox -o $dataset_dir/$output_dir/$command_subdir/${voice}_in001.wav -t "$command" -s "duration_stretch=1.00"

    flite -voice voices/$voice.flitevox -o $dataset_dir/$output_dir/$command_subdir/${voice}_in002.wav -t "$command" -s "duration_stretch=1.25"

    flite -voice voices/$voice.flitevox -o $dataset_dir/$output_dir/$command_subdir/${voice}_in003.wav -t "$command" -s "duration_stretch=1.50"

    flite -voice voices/$voice.flitevox -o $dataset_dir/$output_dir/$command_subdir/${voice}_in004.wav -t "$command" -s "duration_stretch=1.00" -s "int_f0_target_stddev=50.0"

    flite -voice voices/$voice.flitevox -o $dataset_dir/$output_dir/$command_subdir/${voice}_in005.wav -t "$command" -s "duration_stretch=1.00" -s "int_f0_target_stddev=75.0"

    flite -voice voices/$voice.flitevox -o $dataset_dir/$output_dir/$command_subdir/${voice}_in006.wav -t "$command" -s "duration_stretch=1.25" -s "int_f0_target_stddev=50.0"

    flite -voice voices/$voice.flitevox -o $dataset_dir/$output_dir/$command_subdir/${voice}_in007.wav -t "$command" -s "duration_stretch=1.25" -s "int_f0_target_stddev=75.0"

    flite -voice voices/$voice.flitevox -o $dataset_dir/$output_dir/$command_subdir/${voice}_in008.wav -t "$command" -s "duration_stretch=1.50" -s "int_f0_target_stddev=50.0"

    flite -voice voices/$voice.flitevox -o $dataset_dir/$output_dir/$command_subdir/${voice}_in009.wav -t "$command" -s "duration_stretch=1.50" -s "int_f0_target_stddev=75.0"

    set +x
  done
done
