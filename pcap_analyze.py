#!/usr/bin/python

from scapy.all import rdpcap
import numpy as np

# Get input from user for phone IP address
ip = input("Enter the IP for the phone [10.163.3.12]: ")
if ip == "":
    ip = "10.163.3.12"
print("Using", ip, "\n")

# Path to the PCAP file
pcap_file = "example.pcapng"

# Read in the PCAP file using Scapy
packets = rdpcap(pcap_file)

# Create an empty list to hold the packet sizes
packet_sizes = []

# Create an empty list ot hold packet times
packet_times = []

# Create an empty list to hold IAT times
packet_iats = []

# Create an empty list ot hold packet directions
# 0 is outgoing and 1 is incoming to the phone
packet_directions = []

# Iterate through each packet in the PCAP file
for i in range(len(packets)):
    packet = packets[i]
    # Get the size of the packet
    size = len(packet)
    # Add the packet size to the list
    packet_sizes.append(size)
    
    packet_times.append(float(packet.time))
    
    if packet["IP"].src == ip:  # outgoing (0)
        packet_directions.append(0)
    else:  # incoming (1)
        packet_directions.append(1)

    # Get packet times
    if i < len(packets)-1:
        this_packet_time = packet.time
        next_packet_time = packets[i+1].time
        time_diff = next_packet_time - this_packet_time
        packet_iats.append(float(time_diff))
    else:
        # -1 is a placeholder signifying no next packet
        packet_iats.append(-1)

# Print out lists
print("packet sizes:")
print(packet_sizes)
print("packet iats")
print(packet_iats)
print("packet times")
print(packet_times)
print("packet directions")
print(packet_directions)

# Change lists into numpy arrays for further analysis later
size_array = np.array(packet_sizes)
iat_array = np.array(packet_iats)
time_array = np.array(packet_times)
dir_array = np.array(packet_directions)

stacked_array = np.dstack((time_array, iat_array, size_array, dir_array))

print(stacked_array)
