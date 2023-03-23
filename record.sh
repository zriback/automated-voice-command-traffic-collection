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

out_dir="./capture_output"
echo -e "Using output directory $out_dir\n"

# clear that directory if it exists
if [ -d $out_dir ]; then
  rm -rf $out_dir
fi
mkdir $out_dir

read -p "Enter the IP address of the device [192.168.1.2]: " ip_addr
ip_addr=${ip_addr:-192.168.1.2}
echo -e "Using address $ip_addr\n"

# Define interface to capture on
interface=eth0

# Define time to capture for each individual command
cap_time=10


# For each wav variant for each voice variant for each command
for command_dir in $wav_dir/*; do
  command=$(echo $command_dir | cut -d'/' -f 3)
  for voice_dir in $command_dir/*; do
    voice=$(echo $voice_dir | cut -d'/' -f 4)
    for wav_file in $voice_dir/*; do
      wav=$(echo $wav_file | cut -d'/' -f 5 | cut -d'.' -f 1)
      # $wav_file now contains the full path to the .wav file
      echo -e "Now capturing: $wav_file"
      
      current_out_subdir=$out_dir/$command/$voice
      mkdir -p $current_out_subdir 2>/dev/null
      sudo tcpdump -U -i $interface -w $current_out_subdir/$wav.pcap "host $ip_addr" &
      paplay $wake_word
      paplay $wav_file

      while ! timeout --foreground 60s sox -d $wav_file silence 0.1 5% 1 3.0 5%; do
        # Clean up failed capture
	sudo pkill -2 tcpdump
	sudo rm $current_out_dir/$wav.pcap
	
	# Start the redo capture
	echo -e "Error...retrying capture"
	sudo tcpdump -U -i $interface -w $current_out_subdir/$wav.pcap "host $ip_addr" &
        paplay $wake_word
        paplay $wav_file
      done

      sleep $cap_time
      sudo pkill -2 tcpdump
      echo -e "--------------------------------------------\n"
    done
  done
done


