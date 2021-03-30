#!/bin/bash

trap "{ exit 1; }" SIGINT

voices=(cmu_us_aew cmu_us_ahw cmu_us_aup cmu_us_awb cmu_us_axb cmu_us_bdl cmu_us_clb cmu_us_eey cmu_us_fem cmu_us_gka cmu_us_jmk cmu_us_ksp cmu_us_ljm cmu_us_rms cmu_us_rxr cmu_us_slt)

# Prompt for directory paths
while read -p "Enter the dataset directory [dataset]: " dataset_dir && dataset_dir=${dataset_dir:-"dataset"} && [ ! -d "$dataset_dir" ]; do
  echo "Directory doesn't exist"
done
echo -e "Using directory \"$dataset_dir\"\n"
while read -p "Enter the command directory [$dataset_dir/commands]: " command_dir && command_dir=${command_dir:-"$dataset_dir/commands"} && [ ! -d "$command_dir" ]; do
  echo "Directory doesn't exist"
done
echo -e "Using directory \"$command_dir\"\n"
while read -p "Enter the wake word directory [$dataset_dir/wake_words]: " wake_word_dir && wake_word_dir=${wake_word_dir:-"$dataset_dir/wake_words"} && [ ! -d "$wake_word_dir" ]; do
  echo "Directory doesn't exist"
done
echo -e "Using directory \"$wake_word_dir\"\n"

PS3="Select the command subdirectory to use: "
select command_subdirs in "$command_dir/"* "ALL"; do
  case $command_subdirs in
  ALL)
    command_subdirs=${command_dir/*/}
    echo -e "Using ALL directories\n"
    break
    ;;
  *)
    echo -e "Using directory \"$command_subdirs\"\n"
    break
    ;;
  esac
done

PS3="Select the wake word file to use: "
select wake_word_file in "$wake_word_dir/"*; do
  case $wake_word_file in
  *)
    echo -e "Using file \"$wake_word_file\"\n"
    break
    ;;
  esac
done

read -p "Enter the IP address of the device [192.168.1.2]: " ip_addr
ip_addr=${ip_addr:-"192.168.1.2"}
echo -e "Using address \"$ip_addr\"\n"

for voice in ${voices[@]}; do
  for command_subdir in $command_subdirs; do
    rm -f "$command_subdir/"*"out"*
    i=1
    for command_file in $command_subdir/${voice}_*.wav; do
      sudo tcpdump -U -i wlan0 -w $command_subdir/${voice}_out$(printf "%03d" $i).pcap "host $ip_addr" &
      paplay $wake_word_file
      paplay $command_file
      sox -d $command_subdir/${voice}_out$(printf "%03d" $i).wav silence 1 0.1 5% 1 3.0 5%
      sleep 2
      sudo pkill -2 tcpdump
      ((i++))
    done
    sudo chown $USER:$USER "$command_subdir/"*
  done
done
