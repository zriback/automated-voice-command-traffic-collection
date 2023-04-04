# Automated-Voice-Command-Traffic-Collection

This project encompasses all the code neccessary to generate .wav files with voice command, voice styles, play those sound files for a voice assistant, and then capture that network traffic. The traffic can then be analyzed later.

Forked from github.com/jock0rama/automated-voice-command-traffic-collection

## Parts

### init.sh

Script to initialize and prepare the system. Installs required packages and voice .flitevox files from [here](http://www.festvox.org/flite/packed/flite-2.0/voices/).

Also sets up hostapd to allow a raspberry pi to act as a wireless access point for the phone/other device. This is so the pi can intercept and capture appropriate network traffic.

### generate.sh

Generates one .wav sound file for each combonation of voice, voice command, and variant.

Variants are coded in this script and vary the speed and standard deviation of the pitch of the voice command.

Working directory is provided by the user. 

File containing the voice commands is also provided by the user. An example voice_commands file can be found in this repository.

### record.sh

Plays a .wav sound file a set amount of times for each command (amount of times is defined in the script as $iterations) and records tcp traffic for a set amount of time to give the voice command time to process by the voice assistant. Specific file (combination of voice and variant) is selected at random for each iteration.

Directory containing .wav files generated using generate.sh is provided by the user.

.wav file containing the wake phrase for the voice assistant is provided by the user. This repository contains an example one that says "Hey Google".

IP address of the phone is provided by the user. This is so the script can only capture traffic to do with the target device

Output directory is 'capture_output' and has similar structure as wav_output but with corresponding pcap files.
