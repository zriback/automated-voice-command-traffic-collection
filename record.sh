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

# Prompt for the capture output directory
while read -p "Enter the capture output directory [./capture_output]: " out_dir && out_dir=${out_dir:-./capture_output} && [ ! -d $out_dir ]; do
  echo "Directory does not exist"
done
echo -e "Using directory $out_dir\n"

# clear that directory if it exists
rm -rf $out_dir/*

read -p "Enter the IP address of the device [10.163.3.12]: " ip_addr
ip_addr=${ip_addr:-10.163.3.12}
echo -e "Using address $ip_addr\n"

# Define interface to capture on
interface=wlan0

# Defines number of times to capture for each command
iterations=200

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
   
    
    paplay $wake_word
    sleep 1
    sudo tcpdump -U -i $interface -w $current_out_subdir/cap$i.pcap "host $ip_addr" &
    paplay $wav_file
    
    # sudo sox -t alsa hw:1,0 $current_out_subdir/cap_$i.wav &
    # sox -t alsa -d $current_out_subdir/cap$i.wav &
    timeout 25s rec $current_out_subdir/cap$i.wav rate 32k gain -10 silence 2 1 20% 1 1.0 2%

    sudo pkill -2 tcpdump
    echo -e "Saved as $current_out_subdir/cap$i"
    echo -e "--------------------------------------------\n"
  done
done

sudo pkill -2 tcpdump
sudo pkill -2 sox 

exit
