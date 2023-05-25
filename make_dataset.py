#!/usr/bin/python

from scapy.all import rdpcap
import numpy as np
import os
import pickle

# Number of questions/directories to process before flushing buffer to X.obj file
QUESTION_BUFFER_SIZE = 1

# Get info from user
def get_input():
    # Get input from user for phone IP address
    ip_input = input("Enter the IP for the phone. If there are multiple, separate them with a space. [10.163.3.12]: ")
    if ip_input == "":
        ip_input = "10.163.3.12"
    ip_list = ip_input.split(" ")
    print("Using", str(ip_list), "\n")

    # Get input from the user for capture_output directory
    while not os.path.isdir(data := input("Enter the directory for the capture output data [./capture_output]: ")):
        print("Directory does not exist")
    print("Using", data, "\n")
    
    while not os.path.isdir(pickle_output := input("Enter the directory for the pickle output [./pickle_output]: ")):
        print("Directory does not exist")
    print("Using", pickle_output, "\n")

    while True:
        try:
            capture_length = input("Enter value for length (number of packets) to force all captures to [3000]: ")
            if not capture_length:
                capture_length = '3000'
            capture_length = int(capture_length)
            break
        except TypeError:
            print("Enter a number")
    print(f'Using {capture_length}\n')

    return ip_list, data, pickle_output, capture_length


# analyze given pcap file through the ip given
def analyze_pcap(pcap_file, ip_list, capture_length):
    # Read in the PCAP file using Scapy
    packets = rdpcap(pcap_file)

    # 2D array for holding packet information by packet
    features = []

    for i in range(min(len(packets), capture_length)):
        packet = packets[i]

        # Get the size of the packet
        size = len(packet)

        if packet.haslayer("IP") and packet["IP"].src in ip_list:  # outgoing (1)
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
    # Pad features to required length before returning
    if len(features) < capture_length:
        for _ in range(capture_length - len(features)):
            features.append([0,0,0])

    return features

# analyze data directory
def analyze_data(data, ip_list, pickle_output, capture_length):
    X = []
    # store targets
    y = []
    # dict to store questions and id
    questions = {}
    next_target = 0

    # no. of questions in the current buffer - flushed to .obj file after QUESTION_BUFFER_SIZE questions are read
    question_buf = 0
    for question_dir in os.listdir(data):
        print("Analyzing", question_dir)
        for pcap in [i for i in os.listdir(os.path.join(data, question_dir)) if i.endswith('.pcap')]:
            path = os.path.join(data, question_dir, pcap)

            if questions.get(question_dir) is None:
                questions[question_dir] = next_target
                next_target += 1
            
            features = analyze_pcap(path, ip_list, capture_length)
            X.append(features)
            y.append(questions[question_dir])
        question_buf += 1
        # After analyzing set number of questions, append to pickled object and clear the buffer
        if question_buf >= QUESTION_BUFFER_SIZE:
            save_X_data(X, pickle_output)
            question_buf = 0
            X = []

    # pickle remaining data in the buffer to the object file
    if question_buf > 0:
        save_X_data(X, pickle_output)

    return X, y, questions

# Format X data into proper nd array and pickle to .obj file
def save_X_data(X, pickle_output):
    X = np.array(X)
    do_pickle(pickle_output, X, None, None)
            

# pickle the necessary structures so they can be easily transfered over to where ML/DL is done
# takes pickle_output directory and then X, y, and q to pickle
# if a value is none, then nothing is done to that Obj file
def do_pickle(out_dir, X=None, y=None, q=None):
    if X is not None:
        with open(out_dir+"/X.obj", "+ab") as XObj:
            pickle.dump(X, XObj)
            XObj.close()

    if y is not None:
        with open(out_dir+"/y.obj", "+ab") as yObj:
            pickle.dump(y, yObj)
            yObj.close()

    if q is not None:
        with open(out_dir+"/q.obj", "+ab") as qObj:
            pickle.dump(q, qObj)
            qObj.close()


def main():
    ip_list, data, pickle_output, capture_length = get_input()

    # analyzes data, and puts into 
    X, y, questions = analyze_data(data, ip_list, pickle_output, capture_length)
    
    y = np.array(y)

    do_pickle(pickle_output, None, y, questions)


if __name__ == "__main__":
    main()

