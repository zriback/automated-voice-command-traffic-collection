#!/usr/bin/python

# Script to delete from the data directory bad data as manually marked with a 'd' in filter_data_out.txt
# format is 
# d [path to .wav file] [voice assistant output]
# ^d the d being present, the script will delete that .wav and .pcap file

import os

DEFAULT_FILENAME = 'filter_data_out.txt'

# Get out.txt file
filename = input(f"Enter output text file name to analyze [{DEFAULT_FILENAME}]: ")
if filename == "":
    filename = DEFAULT_FILENAME
print("Using", filename, "\n")

files_removed = 0
with open(filename, 'r') as f:
    for line in f.readlines():
        fields = line.split()
        if fields[0] == 'd':  # then delete the file
            print(f"Removing {os.path.splitext(fields[1])[0]}")
            try:
                os.remove(fields[1])
                os.remove(f"{os.path.splitext(fields[1])[0]}.pcap")
                files_removed += 1
            except OSError:
                print("Coudn't remove file")

print(f"\nDONE! - Filed removed: {files_removed}")

