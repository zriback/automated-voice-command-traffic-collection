#!/usr/bin/python

from scapy.all import rdpcap
import numpy as np
import os
import pickle

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
    
    while not os.path.isdir(pickle_output := input("Enter the directory for the pickle output [./pickle_output]: ")):
        print("Directory does not exist")
    print("Using", pickle_output, "\n")
    return ip, data, pickle_output


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


# pickle the necessary structures so they can be easily transfered over to where ML/DL is done
# takes pickle_output directory and then X, y, and q to pickle
def do_pickle(out_dir, X, y, q):
    XObj = open(out_dir+"/X.obj", "wb")
    yObj = open(out_dir+"/y.obj", "wb")
    qObj = open(out_dir+"/q.obj", "wb")
    
    pickle.dump(X, XObj)
    pickle.dump(y, yObj)
    pickle.dump(q, qObj)

    XObj.close()
    yObj.close()
    qObj.close()


def main():
    ip, data, pickle_output = get_input()

    X, y, questions = analyze_data(data, ip)
    # print(X)
    # print(y)
    # print(questions)

    do_pickle(pickle_output, X, y, questions)
    

main()


