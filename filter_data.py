#!/usr/bin/python

import speech_recognition as sr
import os


# Get input from user for the data directory
def get_input():
    # Get input from the user for capture_output directory
    while not os.path.isdir(data_path := input("Enter the directory for the capture output data: ")):
        print("Directory does not exist")
    print("Using", data_path, "\n")

    # TODO system for auto deleting based on text output?
    # # Get value for auto_delete from user
    # while True:
    #     try:
    #         if (auto_delete := input("Enter a value for the auto-deletion mode (1=auto-delete, 0=no auto-delete): ")) == "":
    #             auto_delete = 0
    #         if auto_delete != '0' and auto_delete != '1':
    #             raise ValueError
    #         print("Using", auto_delete, "for auto-deletion mode\n")
    #         break
    #     except ValueError:
    #         print("Invalid input - try again (0 or 1)")

    return data_path


# Filter data by checking if .wav file for corresponding capture indicates the voice assistant correctory understood the question
# automatic_delete_mode set to 1 means it will automatically delete bad pcap files (if set to 0 it will not delete them)
def filter_data(data):
    r = sr.Recognizer()
    
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
            except sr.exceptions.UnknownValueError:
                print(path, "sr.UnknownValueError - bad data")

def main():
    data_path = get_input()

    filter_data(data_path)


if __name__ == '__main__':
    main()