#!/usr/bin/python

# Import module support
import os
from functools import reduce

import NumberValidator
import sys


class Student:
    def __init__(self, student_name, student_surname):
        self.name = student_name
        self.surname = student_surname
        self.marks = []


# Now you can call defined function that module as follows
for fileName in sys.argv[1:]:
    if not os.path.isfile(fileName):
        sys.stderr.write("[ERROR] Plik: \"%s\" nie istnieje!\n" % fileName)
        continue
    file = open(fileName, "r")
    counter = 0
    file_info_map = {}
    for line in file:
        counter += 1
        if not NumberValidator.is_valid_mark_row(line):
            sys.stderr.write("[ERROR] Plik: %s linia: %d niepoprawna!\n" % (fileName, counter))
            continue
        words = line.split()
        surname = words[1].title()
        name = words[0].title()
        hash_value = (surname + '_' + name)
        mark = NumberValidator.convert_mark_to_number(words[2])

        if hash_value not in file_info_map:
            file_info_map[hash_value] = Student(name, surname)
        file_info_map[hash_value].marks.append(mark)
    print("---> Plik: %s" % fileName)
    for key in sorted(file_info_map):
        avg = reduce(lambda x, y: x + y, file_info_map[key].marks) / len(file_info_map[key].marks)
        marks = ["%.2f" % x for x in file_info_map[key].marks]
        print("%s %s: %s: %.2f" % (file_info_map[key].name,
                                   file_info_map[key].surname,
                                   marks,
                                   avg
                                   ))
