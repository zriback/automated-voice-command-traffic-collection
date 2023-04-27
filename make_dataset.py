#!/usr/bin/python

from scapy.all import rdpcap
import numpy as np
import os

# Get info from user
def get_input():
    # Get input from user for phone IP address
    ip = input("Enter the IP for the phone [10.163.3.12]: ")
    if ip == "":
        ip = "10.163.3.12"
    print("Using", ip, "\n")

    # Get input from the user for capture_output directory
    while not os.path.isdir(data := input("Enter the directory for the capture output data [./capture_output]: ")):
        print("Directory does not exist")
    print("Using", data, "\n")
    return ip, data


# analyze given pcap file through the ip given
def analyze_pcap(pcap_file, ip):
    # Read in the PCAP file using Scapy
    packets = rdpcap(pcap_file)

    # 2D array for holding packet information by packet
    features = []

    for i in range(len(packets)):
        packet = packets[i]

        # Get the size of the packet
        size = len(packet)

        
        if packet.haslayer("IP") and packet["IP"].src == ip:  # outgoing (1)
            direction = 1
        else:  # incoming (-1)
            direction = -1

        # Get packet times
        if i > 0:
            this_packet_time = packet.time
            last_packet_time = packets[i-1].time
            time_diff = this_packet_time - last_packet_time
            iat = float(time_diff)
        else:
            # put zero for first packet
            iat = 0
        
        features.append([size, iat, direction])
    return features


# analyze data directory
def analyze_data(data, ip):
    all_stats = []
    # store targets
    y = []
    # dict to store questions and id
    questions = {}
    next_target = 0
    for question_dir in os.listdir(data):
        for pcap in os.listdir(os.path.join(data, question_dir)):
            path = os.path.join(data, question_dir, pcap)
            if not path.endswith(".pcap"):
                continue
            
            if questions.get(question_dir) is None:
                questions[question_dir] = next_target
                next_target += 1
            
            features = analyze_pcap(path, ip)
            all_stats.append(features)
            y.append(questions[question_dir])

    return all_stats, y, questions

def main():
    ip, data = get_input()

    all_stats, y, questions = analyze_data(data, ip)
    print(all_stats)
    print(y)
    print(len(all_stats))
    print(len(y))

main()

