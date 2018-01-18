#!/usr/bin/python
# -*- coding: utf-8
import argparse

import sys

from __builtin__ import raw_input
from math import sqrt


def isfloat(value):
    try:
        float(value)
        return True
    except ValueError:
        return False


parser = argparse.ArgumentParser(description="Rozwiązanie równiania kwadratowego")
parser.add_argument("-a", dest="a", type=float, help="Współczynnik a równania kwadratowego")
parser.add_argument("-b", type=float, help="Współczynnik b równania kwadratowego")
parser.add_argument("-c", type=float, action="store", help="Współczynnik c równania kwadratowego")
args = parser.parse_args()

while not args.a:
    a = raw_input("Podaj liczbę różną od zera, która będzie współczynnikiem a: ")

    if not isfloat(a):
        sys.stderr.write("niepoprawna liczba!\n")
        continue
    a = float(a)

    if a == 0:
        sys.stderr.write("a nie może być równe 0, nie będzie to równanie kwadratowe\n")
    else:
        args.a = a

while not args.b:
    b = raw_input("Podaj liczbę, która będzie współczynnikiem b: ")

    if not isfloat(b):
        sys.stderr.write("niepoprawna liczba!\n")
        continue
    args.b = float(b)

while not args.c:
    c = raw_input("Podaj liczbę, która będzie współczynnikiem c: ")

    if not isfloat(c):
        sys.stderr.write("niepoprawna liczba!\n")
        continue
    args.c = float(c)

delta = (args.b * args.b) - (4 * args.a * args.c)
if delta < 0:
    print("delta < 0 nie liczę dalej")
    sys.exit(0)

mz_1 = (-args.b - sqrt(delta)) / (2 * args.a)
mz_2 = (-args.b + sqrt(delta)) / (2 * args.a)
print("1 miejsce zerowe: %.2f" % mz_1)
print("2 miejsce zerowe: %.2f" % mz_2)
