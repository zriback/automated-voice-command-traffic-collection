#!/bin/bash

trap "clean_exit" SIGINT
clean_exit() {
  echo -e "\nStopping capture and exiting safely\n"
  sudo pkill -2 tcpdump
  exit 1
}

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
cap_time=2

# Defines number of times to capture for each command
iterations=2

# for each command for each wav file
for command_dir in $wav_dir/*; do
  command=$(echo $command_dir | cut -d'/' -f 3)
  for ((i=1; i <= $iterations; i++)); do
    # select random file from the command sub dir
    wav_name=$(ls $command_dir | shuf -n 1) 
    wav_file=$command_dir/$wav_name
    # $wav_file now contains the full path to the .wav file
    # $wav_name contains the name of the file without the path
    
    echo -e "Now capturing: $wav_file"
    
    current_out_subdir=$out_dir/$command
    
    # make the directory if it does not exist
    mkdir -p $current_out_subdir 2>/dev/null
    
    sudo tcpdump -U -i $interface -w $current_out_subdir/cap_$i.pcap "host $ip_addr" &
    paplay $wake_word
    paplay $wav_file

    while ! timeout --foreground 60s sox -d $wav_file silence 0.1 5% 1 3.0 5%; do
      # Clean up failed capture
      sudo pkill -2 tcpdump
      sudo rm $current_out_dir/$wav.pcap

      # Start the redo capture
        echo -e "Error...retrying capture"
	sudo tcpdump -U -i $interface -w $current_out_subdir/cap_$i.pcap "host $ip_addr" &
	paplay $wake_word
	paplay $wav_file
    done
    sleep $cap_time
    sudo pkill -2 tcpdump
    echo -e "Saved as $current_out_subdir/cap_$i.pcap"
    echo -e "--------------------------------------------\n"
  done
done


