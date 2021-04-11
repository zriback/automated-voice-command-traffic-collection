#!/bin/bash

trap "clean_exit" SIGINT
clean_exit() {
  echo -e "\nStopping capture and exiting safely\n"
  sudo pkill -2 tcpdump
  exit 1
}

#voices=(cmu_us_aew cmu_us_ahw cmu_us_aup cmu_us_awb cmu_us_axb cmu_us_bdl cmu_us_clb cmu_us_eey cmu_us_fem cmu_us_gka cmu_us_jmk cmu_us_ksp cmu_us_ljm cmu_us_rms cmu_us_rxr cmu_us_slt)
voices=(cmu_us_aew cmu_us_ahw cmu_us_awb cmu_us_bdl cmu_us_clb cmu_us_fem cmu_us_gka cmu_us_jmk cmu_us_ksp cmu_us_ljm cmu_us_rms cmu_us_rxr cmu_us_slt)
#voices=(cmu_us_awb)

# Prompt for data directory paths
while read -p "Enter the dataset directory [current_dataset]: " dataset_dir && dataset_dir=${dataset_dir:-current_dataset} && [ ! -d $dataset_dir ]; do
  echo "Directory doesn't exist"
done
echo -e "Using directory $dataset_dir\n"
while read -p "Enter the command directory [$dataset_dir/commands]: " command_dir && command_dir=${command_dir:-$dataset_dir/commands} && [ ! -d $command_dir ]; do
  echo "Directory doesn't exist"
done
echo -e "Using directory $command_dir\n"
while read -p "Enter the wake word directory [$dataset_dir/wake_words]: " wake_word_dir && wake_word_dir=${wake_word_dir:-$dataset_dir/wake_words} && [ ! -d $wake_word_dir ]; do
  echo "Directory doesn't exist"
done
echo -e "Using directory $wake_word_dir\n"

# Prompt for command subdirectory
PS3="Select the command subdirectory to use: "
select command_subdirs in $command_dir/* "ALL"; do
  case $command_subdirs in
  ALL)
    command_subdirs=$command_dir/*
    echo -e "Using ALL subdirectories\n"
    break
    ;;
  *)
    echo -e "Using subdirectory $command_subdirs\n"
    break
    ;;
  esac
done

# Prompt for wake word file
PS3="Select the wake word file to use: "
select wake_word_file in $wake_word_dir/*; do
  case $wake_word_file in
  *)
    echo -e "Using file $wake_word_file\n"
    break
    ;;
  esac
done

read -p "Enter the IP address of the device [192.168.1.2]: " ip_addr
ip_addr=${ip_addr:-192.168.1.2}
echo -e "Using address $ip_addr\n"

# For each voice
for voice in ${voices[@]}; do
  # For each command subdirectory
  for command_subdir in ${command_subdirs[@]}; do
    sudo rm "$command_subdir/${voice}_out"* # Delete stale output files of current voice in current command subdirectory
    variant=1 # Reset voice variant counter of current voice

    # For each variant file of current voice in current command subdirectory
    for variant_file in $command_subdir/${voice}_in*; do
      # Start the capture
      echo -e "\nCapturing $command_subdir/${voice}_out$(printf '%03d' $variant).pcap\n"
      sudo tcpdump -U -i wlan0 -w $command_subdir/${voice}_out$(printf "%03d" $variant).pcap "host $ip_addr" &
      paplay $wake_word_file
      paplay $variant_file

      # If the capture times out (no response heard after 60 seconds), then redo the capture
      while ! timeout --foreground 60s sox -d $command_subdir/${voice}_out$(printf "%03d" $variant).wav silence 1 0.1 5% 1 3.0 5%; do
        # Clean up from failed capture
        sudo pkill -2 tcpdump
        sudo rm "$command_subdir/${voice}_out$(printf "%03d" $variant)"*

        # Start the redo capture
        echo -e "\nCapturing $command_subdir/${voice}_out$(printf '%03d' $variant).pcap\n"
        sudo tcpdump -U -i wlan0 -w $command_subdir/${voice}_out$(printf "%03d" $variant).pcap "host $ip_addr" &
        paplay $wake_word_file
        paplay $variant_file
      done

      sleep 2
      sudo pkill -2 tcpdump
      ((variant++))
    done

    sudo chown $USER:$USER "$command_subdir/"* # Fix ownership of files
  done
done
