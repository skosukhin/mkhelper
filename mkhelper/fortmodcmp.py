#!/usr/bin/env python
import sys


def find_magic(stream, string):
    """
    Finds the first occurrence of a sequence of bytes in a binary stream.
    Returns True if the sequence is found and False otherwise, The file's
    current position is set right after the sequence.
    """
    string_size = len(string)
    buf_max_size = string_size * 256
    while 1:
        buf = stream.read(buf_max_size)
        buf_size = len(buf)
        idx = buf.find(string)
        if idx < 0:
            if buf_size < buf_max_size:
                return False
        else:
            stream.seek(idx + string_size - buf_size, 1)
            return True


def mods_differ(filename1, filename2, compiler_name=None):
    """
    Check whether two Fortran module files are essentially different. Some
    compiler-specific logic is required for compilers that generate different
    module files for the same source file (e.g. the module files might contain
    timestamps). This implementation is inspired by CMake.
    """
    with open(filename1, 'rb') as stream1, open(filename2, 'rb') as stream2:
        if compiler_name == "intel":
            # The first byte encodes the version of the module file format,
            # skip it:
            stream1.read(1)
            stream2.read(1)
            magic_sequence = b'\x0A\x00'  # the same as \n\0
            if not (find_magic(stream1, magic_sequence) and
                    find_magic(stream2, magic_sequence)):
                return True
        elif compiler_name == "gnu":
            magic_sequence = b'\x1F\x8b'  # the magic number of gzip
            if stream1.read(2) == magic_sequence:  # gfortran 4.9 or later
                stream1.seek(0)
            else:  # gfortran 4.8 or older
                # Skip the first line in the text file containing a timestamp:
                magic_sequence = b'\x0A'  # the same as \n
                if not (find_magic(stream1, magic_sequence) and
                        find_magic(stream2, magic_sequence)):
                    return True
        # Compare the rest (or everything for unknown compilers):
        buf_max_size = 512
        while 1:
            buf1 = stream1.read(buf_max_size)
            buf2 = stream2.read(buf_max_size)
            if buf1 != buf2:
                return True
            if not buf1:
                return False


# We try to make this as fast as possible, therefore we do not parse arguments
# properly:
exit(mods_differ(sys.argv[1], sys.argv[2],
                 sys.argv[3].lower() if len(sys.argv) > 3 else None))
