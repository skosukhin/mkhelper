import os
import sys


def open23(name, mode='r'):
    if sys.version_info < (3, 0, 0):
        return open(name, mode)
    else:
        return open(name, mode, encoding='latin-1')


def in_directory(file, directory):
    file = os.path.abspath(file)
    directory = os.path.abspath(directory) + os.path.sep
    return file.startswith(directory)
