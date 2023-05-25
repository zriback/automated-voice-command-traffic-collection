#!/usr/bin/python

# TODO
# Now add ability to specify specific capture number that should be touched first in the previously specified directory

import speech_recognition as sr
import os

OUT_FILENAME = "filter_data_out.txt"

# Get input from user for the data directory
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

    if start_dir:  # if a start_dir was defined, take a start capture, too
        while True:
            try:
                start_num = input(f"Enter capture number to start at (empty=start at beginning): ")
                if start_num == "":
                    start_num = '1'
                if not os.path.isfile(f"{data_path}\\{start_dir}\\cap{start_num}.wav"):
                    raise ValueError
                print(f"Starting at cap{start_num}.wav\n")
                break
            except ValueError:
                print(f"cap{start_num}.wav does not exist in")
    else:
        start_num = "1"
        
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

    return data_path, start_dir, start_num, auto_delete


# Filter data by checking if .wav file for corresponding capture indicates the voice assistant correctory understood the question
# automatic_delete_mode set to 1 means it will automatically delete bad pcap files (if set to 0 it will not delete them)
# put output of text->speech to stdout and txt file
def filter_data(data, start_dir, start_num, auto_delete):
    r = sr.Recognizer()

    # Always open in append mode
    out_file = open(OUT_FILENAME, "a")
    
    question_dirs = os.listdir(data)
    if start_dir == "":  # need to set it to the first one
        start_dir = question_dirs[0]
    first_question = True
    for question_dir in question_dirs[question_dirs.index(start_dir):]:
        print("Analyzing", question_dir)
        wavs = [i for i in os.listdir(os.path.join(data, question_dir)) if i.endswith('.wav')]
        if first_question:  # only the first time start at special capture number
            wavs = wavs[wavs.index(f"cap{start_num}.wav"):]
            first_question = False
        for wav in wavs:
            path = os.path.join(data, question_dir, wav) 

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
        out_file.flush()

    out_file.close()


def main():
    data_path, start_dir, start_num, auto_delete = get_input()

    filter_data(data_path, start_dir, start_num, auto_delete)


if __name__ == '__main__':
    main()