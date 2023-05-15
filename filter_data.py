#!/usr/bin/python

import speech_recognition as sr
import os

OUT_FILENAME = "filter_data_out.txt"

# Get input from user for the data directory
def get_input():
    # Get input from the user for capture_output directory
    while not os.path.isdir(data_path := input("Enter the directory for the capture output data: ")):
        print("Directory does not exist")
    print("Using", data_path, "\n")

    # Get value for auto_delete from user
    while True:
        try:
            if (auto_delete := input("Enter a value for the auto-deletion mode (1=auto-delete, 0=no auto-delete): ")) == "":
                auto_delete = 0
            if auto_delete != '0' and auto_delete != '1':
                raise ValueError
            print("Using", auto_delete, "for auto-deletion mode\n")
            break
        except ValueError:
            print("Invalid input - try again (0 or 1)")

    return data_path, auto_delete


# Filter data by checking if .wav file for corresponding capture indicates the voice assistant correctory understood the question
# automatic_delete_mode set to 1 means it will automatically delete bad pcap files (if set to 0 it will not delete them)
# put output of text->speech to stdout and txt file
def filter_data(data, auto_delete):
    r = sr.Recognizer()

    out_file = open(OUT_FILENAME, "w")
    
    for question_dir in os.listdir(data):
        print("Analyzing", question_dir)
        for pcap in os.listdir(os.path.join(data, question_dir)):
            path = os.path.join(data, question_dir, pcap)
            if not path.endswith(".wav"):
                continue
            
            try:       
                with sr.AudioFile(path) as f:
                    audio_data = r.record(f)
                    text = r.recognize_google(audio_data)
                    print(path, text)
                    out_file.write(f"{path} {text}\n")
            except sr.exceptions.UnknownValueError:  # Often happens when .wav file is empty
                print(path, "sr.UnknownValueError - bad data")
                out_file.write(f"{path} sr.UnknownValueError - bad data\n")
                if auto_delete:  # delete the .wav and .pcap file
                    os.remove(path)
                    os.remove(f"{os.path.splitext(path)[0]}.pcap")


def main():
    data_path, auto_delete = get_input()

    filter_data(data_path, auto_delete)


if __name__ == '__main__':
    main()