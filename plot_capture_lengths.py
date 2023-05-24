#!/usr/bin/python

import os
import numpy as np
import matplotlib.pyplot as plt
from scapy.all import *
import pickle

# Get input from the user
def get_input():
    # Get input from the user for the data directory
    while not os.path.isdir(data_dir := input("Enter the directory for the capture output data [./capture_output]: ")):
        print("Directory does not exist")
    print("Using", data_dir, "\n")
    return data_dir

# Gather data on capture lenghts and return in 1D np array for each capture in the data directory
def analyze(data_dir):
    lengths = []
    for question_dir in os.listdir(data_dir):
        print(f'Analyzing {question_dir}...')
        for pcap in [i for i in os.listdir(os.path.join(data_dir, question_dir)) if i.endswith('.pcap')]:
            pcap_path = os.path.join(data_dir, question_dir, pcap)
            lengths.append(len(rdpcap(pcap_path)))
    
    lengths = np.array(lengths)
    return lengths

# Uses MatPlotLib to plot list of data into a histogram
def plot(arr):
    plt.hist(arr, bins=15)
    plt.show()


def main():
    data_dir = get_input()

    lengths = analyze(data_dir)

    # Save the numpy array to obj file via pickling for further analysis if need be
    filename = 'pickle_output/lengths.obj'
    with open(filename, 'wb') as f:
        pickle.dump(lengths, f)

    plot(lengths)


if __name__ == '__main__':
    main()

