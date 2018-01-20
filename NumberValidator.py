import re


def is_hash_line(line):
    return re.match("^#.*", line)


def is_valid_mark_row(line):
    pattern = re.compile("^(\w+\s){2}(:?[-+]?\d\.\d+|[-+]?\d|\d\.\d+[-+]?|\d[-+]?)$")
    return pattern.match(line)


def convert_mark_to_number(mark):
    value_to_set = 0
    if re.match("-", mark):
        value_to_set = -0.25
    if re.match("\+", mark):
        value_to_set = 0.25
    if re.match("\d+[-+]", mark):
        mark = mark[:-1]
    mark = abs(float(mark))
    mark += value_to_set
    return mark


def is_int(line):
    return re.match("^\d+$", line)


def is_scientific_notation(line):
    return re.match("^(:?[-+]?\.\d+|[-+]?\d+\.?\d*)(:?[eEdDQ^][-+]?\d+)?$", line)
