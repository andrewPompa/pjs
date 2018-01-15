import re


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
