#!/usr/bin/python
# -*- coding: utf-8

# Import module support
import argparse
import os
import string
from functools import reduce

import re

import NumberValidator
import sys


class FileStats:
    def __init__(self, name):
        self.name = name
        self.bytes_in_file = 0
        self.lines_in_file = 0
        self.words_in_file = 0
        self.scientific_numbers_in_file = 0
        self.ints_in_file = 0


def print_help():
    print("Program %s [-d][-i][-e][-c][-l][-q] lista plików" % sys.argv[0])
    print("Zmodyfikowany cat")
    print("-d zlicza liczby w formacie wykładniczym")
    print("-i zlicza liczby całkowite")
    print("-e nie sprawdza linijek, które rozpoczynają się od znaku '#'")
    print("-c pokazuje ilość bajtów w pliku")
    print("-l pokazuje ilość linii w pliku")
    print("-w pokazuje ilość słów w pliku")


showScientificNumber = 0
showInt = 0
countWithoutHashCharStartingLine = 0
showBytes = 0
showLines = 0
showWords = 0
no_option_set = 0

file_info_map = {}


fileNames = []
for argument in sys.argv[1:]:
    if argument == "-d":
        showScientificNumber = 1
        continue
    if argument == "-i":
        showInt = 1
        continue
    if argument == "-e":
        countWithoutHashCharStartingLine = 1
        continue
    if argument == "-c":
        showBytes = 1
        continue
    if argument == "-l":
        showLines = 1
        continue
    if argument == "-w":
        showWords = 1
        continue
    if argument == "-h" or argument == "--help":
        print_help()
        sys.exit(1)
    fileNames.append(argument)
if not (showScientificNumber or
        showInt or
        showBytes or
        showLines or
        showWords):
    no_option_set = 1

file_counter = 0
line_counter = 0
file_stats = None
for file in fileNames:
    if not os.path.isfile(file):
        sys.stderr.write("[ERROR] Plik: \"%s\" nie istnieje!\n" % file)
        continue
    file_reader = open(file, "r")
    file_stats = FileStats(file)
    for line in file_reader:
        line_counter += 1
        if countWithoutHashCharStartingLine and NumberValidator.is_hash_line(line):
            print("[INFO] %d: (%s) line starting with '#' skipping" % (line_counter, file))
            continue
        file_stats.lines_in_file += 1
        words = line.split()
        file_stats.bytes_in_file += len(bytearray(line))
        file_stats.words_in_file += len(words)
        for word in words:
            if NumberValidator.is_int(word):
                file_stats.ints_in_file += 1
            if NumberValidator.is_scientific_notation(word):
                file_stats.scientific_numbers_in_file += 1
    key = file + str(file_counter)
    file_info_map[key] = file_stats
    file_counter += 1
    line_counter = 0
total_stats = None
should_count_total = 0
if len(file_info_map) > 1:
    should_count_total = 1
    total_stats = FileStats("Razem")

for key in file_info_map:
    if showScientificNumber:
        print("liczby w notacji wykładniczej: %d, " % file_info_map[key].scientific_numbers_in_file),
    if showInt:
        print("liczby całkowite: %d, " % file_info_map[key].ints_in_file),
    if showLines or no_option_set:
        print("linii: %d," % file_info_map[key].lines_in_file),
    if showWords or no_option_set:
        print("słów: %d, " % file_info_map[key].words_in_file),
    if showBytes or no_option_set:
        print("bajtów: %d, " % file_info_map[key].bytes_in_file),
    print(" %s" % file_info_map[key].name)
    if should_count_total:
        total_stats.scientific_numbers_in_file += file_info_map[key].scientific_numbers_in_file
        total_stats.ints_in_file += file_info_map[key].ints_in_file
        total_stats.lines_in_file += file_info_map[key].lines_in_file
        total_stats.words_in_file += file_info_map[key].words_in_file
        total_stats.bytes_in_file += file_info_map[key].bytes_in_file
if should_count_total:
    print("-----------------")
    print("Razem: "),
    if showScientificNumber:
        print("liczby w notacji wykładniczej: %d, " % total_stats.scientific_numbers_in_file),
    if showInt:
        print("liczby całkowite: %d, " % total_stats.ints_in_file),
    if showLines or no_option_set:
        print("linii: %d," % total_stats.lines_in_file),
    if showWords or no_option_set:
        print("słów: %d, " % total_stats.words_in_file),
    if showBytes or no_option_set:
        print("bajtów: %d, " % total_stats.bytes_in_file),

