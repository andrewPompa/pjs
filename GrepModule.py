import re


class PatternOccurrences:
    def __init__(self, pattern):
        self.pattern = pattern
        self.occurrences = 0


def calculate_occurrences(file_path, patterns):
        file = open(file_path, "r")
        for line in file:
            for key in patterns:
                patterns[key].occurrences += \
                    len(re.findall(patterns[key].pattern, line))


class PatternOccurrencesInFile:
    def __init__(self, file, patterns):
        self.file = file
        self.patterns = {}
        for pattern_id, pattern in patterns:
            self.patterns[pattern + "_" + str(pattern_id)] = PatternOccurrences(pattern)

    def grep(self):
        for file_name in self.file:
            file = open(file_name, "r")
            for line in file:
                for key in self.patterns:
                    self.patterns[key].occurrences += \
                        len(re.findall(self.patterns[key].pattern, line))
        return self.patterns

# def grep_file(file, patterns):
