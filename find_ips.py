#!/usr/bin/python

import os
from scapy.all import *

# Get input from the user
def get_input(): 
    # Get data directory
    while not os.path.isdir(data_path := input("Enter the directory for the capture output data: ")):
        print("Directory does not exist")
    print("Using", data_path, "\n")
    
    # Get device octets
    ip = input("Enter the first three octets of the voice assistant IP address [10.163.3]: ")
    if not ip:
        ip = '10.163.3'
    print()
    return data_path, ip


# Search through all pcap files find all unique ips
def find_ips(data_path, ip):
    ips = []
    for dir in os.listdir(data_path):
        # just need to look at the first packet in the first capture in each question directory
        capture = [i for i in os.listdir(os.path.join(data_path, dir)) if i.endswith('.pcap')][0]
        path = os.path.join(data_path, dir, capture)

        # Get the first packet in this capture that has an IP layer
        i = 0 
        while not (packet := rdpcap(path)[i]).haslayer("IP"):
            i += 1

        src = packet["IP"].src
        dst = packet["IP"].dst
        if src in ips or dst in ips:  # skip this question if we already have it voice assistant device IP
            continue
        if src[:len(ip)] == ip:
            ips.append(src)
        elif dst[:len(ip)] == ip:
            ips.append(dst)
        else:
            raise ValueError('Proper IP format not found in first packet')
            
    return ips

def main():
    data_path, ip = get_input()

    ips = find_ips(data_path, ip)

    print(f'Found {len(ips)} ips:')
    for ip in ips:
        print(ip)


if __name__ == "__main__":
    main()

