# Automated-Voice-Command-Traffic-Collection

This project encompasses all the code neccessary to generate .wav files with voice command, voice styles, play those sound files for a voice assistant, and then capture that network traffic. The traffic can then be analyzed later.

Much of the deep learning and model code for this project is [here](https://colab.research.google.com/drive/1T2jnIBsDoDryjvjdFRN2PRoTMaYdJHZl?usp=sharing).

Forked from github.com/jock0rama/automated-voice-command-traffic-collection

## Parts

### init.sh

Script to initialize and prepare the system. Installs required packages and voice .flitevox files from [here](http://www.festvox.org/flite/packed/flite-2.0/voices/).

Also sets up hostapd to allow a Raspberry Pi to act as a wireless access point for the voice assistant device. This is so the Pi can intercept and capture appropriate network traffic.

### generate.sh

* Generates one .wav sound file for each combination of voice, voice command, and variant.
* Variants are coded in this script and vary the speed and standard deviation of the pitch of the voice command.
* Working directory is provided by the user. 
* File containing the voice commands is also provided by the user. An example voice_commands file can be found in this repository.

### record.sh

Plays a .wav sound file a set amount of times for each command (amount of times is defined in the script as $iterations) and records network traffic to and from the voice assistant device until the voice assistant is finished responding to the command. Specific file (combination of voice and variant) is selected at random for each iteration. Network traffic and voice response output are saved as capX.pcap and capX.wav in that commands directory where X is the iteration number for that sample.

* Directory containing .wav files generated using generate.sh is provided by the user.
* .wav file containing the wake phrase for the voice assistant is provided by the user. This repository contains an example one that says "Hey Google".
* IP address of the phone is provided by the user. This is so the script can only capture traffic to do with the target device.
* Output directory is 'capture_output' and has similar structure as wav_output but with corresponding pcap files.

### fix_wav.sh

Goes through every output .wav file in the given directory (./capture_output) and fixes the file. This includes lowering the volume a bit, and removing silence from the beginning and end of the recording. This may be used if the audio capture from the voice assistant device is noisy, too loud, or low quality.

### filter_data.py

Python script for taking captured output and filtering it based on contents of .wav files. Wav files without any data indicate bad data that can be removed.

Voice-to-text output for each wav is written to file for manual review, and files that are automatically deleted are logged in the same place.

### filter_data_quick.py

Python script for taking captured output and quickly filtering through it by simply deleting .wav files without any data and their corresponding .pcap data. No output log is produced and not text-to-speech is performed. This is a decent alternative to `filter_data.py` which can take a long time for large datasets.

### delete_marked_data.py

Python script for assisting in manual review of log file generated from `filter_data.py`

Prepend 'd ' (d and then a space) to the start of a line corresponding to a wav file in the log file, then run this script to automatically delete that .wav and .pcap file. Decisions on what to delete can be based on the text-to-speech output of the associated .wav file.

### make_dataset.py

Python script for taking filtered data and creating X and y numpy arrays for use in deep learning models. X and y are pickled as X.obj and y.obj to be transfered and unpickled where the deep learning model is fit.

Also creates q.obj, a dictionary relating targets in y to the original question asked to the voice assistant.

* Takes IP address for the voice assistant device (multiple supported), data directory, and pickle output location.
