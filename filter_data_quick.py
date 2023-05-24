#!/usr/bin/python

import os

def get_input():
    # Get input from the user for capture_output directory
    while not os.path.isdir(data_path := input("Enter the directory for the capture output data: ")):
        print("Directory does not exist")
    print("Using", data_path, "\n")

    start_dir = input(f"Enter directory in {data_path} to start at (empty=start at beginning): ")
    while start_dir != "" and not os.path.isdir(f"{data_path}\\{start_dir}"):
        print("Directory does not exist")
        start_dir = input(f"Enter directory in {data_path} to start at (empty=start at beginning): ")
    if not start_dir:
        print("Starting at beginning of data directory\n")
    else:
        print("Using", start_dir, "\n")

    return data_path, start_dir


def quick_filter(data_path, start_dir):
    question_dirs = os.listdir(data_path)
    if not start_dir:
        start_dir = question_dirs[0]
    for question_dir in question_dirs[question_dirs.index(start_dir):]:
        for wav in [i for i in os.listdir(os.path.join(data_path, question_dir)) if i.endswith('.wav')]:
            wav_path = os.path.join(data_path, question_dir, wav)
            stats = os.stat(wav_path)
            if stats.st_size < 50:  # then get rid of .wav and corresponding .pcap file
                print(f"Removing {os.path.join(question_dir, wav)}")
                os.remove(wav_path)
                os.remove(f"{os.path.splitext(wav_path)[0]}.pcap")


def main():
    data_path, start_dir = get_input()

    quick_filter(data_path, start_dir)


if __name__ == "__main__":
    main()