#!/bin/bash

trap "clean_exit" SIGINT
clean_exit() {
  echo -e "\nStopping capture and exiting safely\n"
  sudo pkill -2 tcpdump
  exit 1
}

#voices=(cmu_us_aew cmu_us_ahw cmu_us_aup cmu_us_awb cmu_us_axb cmu_us_bdl cmu_us_clb cmu_us_eey cmu_us_fem cmu_us_gka cmu_us_jmk cmu_us_ksp cmu_us_ljm cmu_us_rms cmu_us_rxr cmu_us_slt)
voices=(cmu_us_aew cmu_us_awb cmu_us_bdl cmu_us_clb cmu_us_fem cmu_us_gka cmu_us_jmk cmu_us_ksp cmu_us_ljm cmu_us_rms cmu_us_rxr cmu_us_slt)
#voices=(cmu_us_awb)

# Prompt for directory containing all wav input
while read -p "Enter the wav directory [./wav_output]: " wav_dir && wav_dir=${wav_dir:-./wav_output} && [ ! -d $wav_dir ]; do
  echo "Directory doesn't exist"
done
echo -e "Using directory $wav_dir\n"

# Prompt for wake word wav file
while read -p "Enter the the wake word wav file [./wake_word.wav]: " wake_word && wake_word=${wake_word:-./wake_word.wav} && [ ! -f $wake_word ]; do
  echo "File does not exist"
done
echo -e "Using file $wake_word\n"

read -p "Enter the IP address of the device [192.168.1.2]: " ip_addr
ip_addr=${ip_addr:-192.168.1.2}
echo -e "Using address $ip_addr\n"


# For each wav variant for each voice variant for each command
for command_dir in $wav_dir/*; do
  for voice_dir in $command_dir/*; do
    for wav_file in $voice_dir/*; do
      echo -e "Now doing: $wav_file"


    done
  done
done



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


