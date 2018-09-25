import sys


def open23(name, mode='r'):
    if sys.version_info < (3, 0, 0):
        return open(name, mode)
    else:
        return open(name, mode, encoding='latin-1')
