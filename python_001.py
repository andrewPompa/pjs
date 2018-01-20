#!/usr/bin/python
# -*- coding: utf-8
import argparse

import sys

parser = argparse.ArgumentParser(description="Wypisuje tabliczkę mnożenia od 0 do wybranej liczby")
parser.add_argument("end", help="ostatnia liczba do której wyświetli się tabliczka mnożenia", type=int)
args = parser.parse_args()
if args.end <= 0:
    sys.stderr.write("[ERROR] wprowadzona liczba musi być większa od 0!\n")
    sys.exit(2)
for i in range(0, args.end + 1):
    print("%d|" % i),
    for j in range(0, args.end + 1):
        print("%d " % (i * j)),
    print("\n")
