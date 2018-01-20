#!/usr/bin/python
# -*- coding: utf-8

# Import module support
import os
import string
from functools import reduce

import re

import NumberValidator
import sys
n = "-n"
N = "-N"
v = "-v"
f = "-f"
h = "-h"
show_lines_by_file = False
show_lines_for_all = False
show_hash_rows = False
show_not_text_file_error = True


def print_help():
    print("Program %s [-n][-N][-v][-f] lista plików" % sys.argv[0])
    print("Zmodyfikowany cat")
    print("-h pomoc")
    print("-n numeracja linii dla każdego pliku z osobna")
    print("-N numeracja linii jedna dla wszystkich plików")
    print("-v wyświetla linie zaczynające się od '#'")
    print("-f wykrywanie 'nietekstowych' plików")


def is_option(is_option_argument):
    return is_option_argument == n or \
           is_option_argument == N or \
           is_option_argument == v or \
           is_option_argument == f


# funkcja wykonana przez Thomas
# (https://stackoverflow.com/questions/1446549/how-to-identify-binary-and-text-files-using-python)
def is_text(filename):
    s = open(filename).read(512)
    text_characters = "".join(map(chr, range(32, 127)) + list("\n\r\t\b"))
    _null_trans = string.maketrans("", "")
    if not s:
        # Empty files are considered text
        return True
    if "\0" in s:
        # Files with null bytes are likely binary
        return False
    # Get the non-text characters (maps a character to itself then
    # use the 'remove' option to get rid of the text characters.)
    t = s.translate(_null_trans, text_characters)
    # If more than 30% non-text characters, then
    # this is considered a binary file
    if float(len(t))/float(len(s)) > 0.30:
        return False
    return True


# parsowanie
files = []
for argument in sys.argv[1:]:
    if argument == h:
        print_help()
        sys.exit(0)

    if not is_option(argument):
        files.append(argument)
        continue

    if len(files) > 0:
        sys.stderr.write("[ERROR] Opcje muszą wystąpić pierwsze\n")
        print_help()
        sys.exit(2)

    if argument == n:
        show_lines_for_all = False
        show_lines_by_file = True
    if argument == N:
        show_lines_by_file = False
        show_lines_for_all = True
    if argument == v:
        show_hash_rows = True
    if argument == f:
        show_not_text_file_error = False

file_lines_counter = 0
file_all_lines_counter = 0
for file in files:
    if not os.path.isfile(file):
        sys.stderr.write("[ERROR] Plik: \"%s\" nie istnieje!\n" % file)
        continue
    if not is_text(file):
        if show_not_text_file_error:
            sys.stderr.write("[ERROR] Plik: \"%s\" nie jest tekstowy!\n" % file)
        continue
    file_reader = open(file, "r")
    for line in file_reader:
        file_lines_counter += 1
        file_all_lines_counter += 1
        line_to_show = ""
        if show_lines_by_file:
            line_to_show += str(file_lines_counter) + ": "
            # print("%d: " % file_lines_counter),
        if show_lines_for_all:
            line_to_show += str(file_all_lines_counter) + ": "
            # print("%d: " % file_all_lines_counter),
        if re.match("^#.*", line):
            if not show_hash_rows:
                file_lines_counter -= 1
                file_all_lines_counter -= 1
                continue
        line_to_show += line
        print(line_to_show),
    file_lines_counter = 0