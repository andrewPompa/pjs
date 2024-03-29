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

from GrepModule import PatternOccurrences, calculate_occurrences

program_name = sys.argv[0]


class Dir:
    def __init__(self, path):
        self.path = path
        self.phrases = []


def print_help():
    print("Przeszukiwacz kartotek %s -d katalog frazy" % program_name)
    print("przykład: %s -d ~/lib -d ~/scripts pier -d ~/bin dru" % program_name)
    print("frazy - frazy do wyszukania")


def print_error(message):
    sys.stderr.write("[ERROR] %s\n" % message)
    print_help()
    sys.exit(2)


def append_directories_to_search(paths_, phrases_, directories_to_search_):
    if paths_ and not phrases_:
        print_error("Nie ma fraz dla katalogów do wszukania")
    for path_to_search in paths_:
        dir_to_search = Dir(path_to_search)
        for phrase in phrases_:
            dir_to_search.phrases.append(phrase)
        directories_to_search_.append(dir_to_search)


if len(sys.argv) == 1:
    print_error("Błąd składni")

if sys.argv[1] != "-d":
    print_error("Oczekiwano katalogu")

directories_to_search = []
paths = []
phrases = []
sys.argv.pop(0)
while sys.argv:
    argument = sys.argv.pop(0)
    if argument == "-d" and len(phrases) != 0:
        append_directories_to_search(paths, phrases, directories_to_search)
        paths = []
        phrases = []
    if argument == "-d":
        if sys.argv:
            argument = sys.argv.pop(0)
        else:
            print_error("Oczekiwano wartości")
        paths.append(argument)
        continue
    phrases.append(argument)
append_directories_to_search(paths, phrases, directories_to_search)

# for directory in directories_to_search:
#     print(directory.path),
#     print(directory.phrases)
patterns = {}
for pattern_id, phrase in enumerate(phrases):
    patterns[phrase + str(pattern_id)] = PatternOccurrences(phrase)
for directory in directories_to_search:
    # print("searching in %s" % directory.path)
    for root, dirs, files in os.walk(directory.path):
        for file_name in files:
            # print("File: %s" % file_name)
            calculate_occurrences(root + '/' + file_name, patterns)
for key in patterns:
    print("%s wystąpił %d razy" % (patterns[key].pattern, patterns[key].occurrences))
