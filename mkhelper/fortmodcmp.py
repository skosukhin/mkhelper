#!/usr/bin/env python
import sys

BUF_MAX_SIZE = 512


def _skip_sequence(stream, sequence):
    """
    Finds the first occurrence of a sequence of bytes in a binary stream and
    sets the streams's current position right after it. Returns True if the
    sequence is found and False otherwise, The length of the sequence must not
    exceed BUF_MAX_SIZE.
    """
    sequence_size = len(sequence)
    while 1:
        buf = stream.read(BUF_MAX_SIZE)
        idx = buf.find(sequence)
        if idx < 0:
            if len(buf) < BUF_MAX_SIZE:
                return False
            else:
                stream.seek(1 - sequence_size, 1)
        else:
            stream.seek(idx + sequence_size - len(buf), 1)
            return True


def _mods_differ_default(stream1, stream2):
    # Simple byte comparison:
    while 1:
        buf1 = stream1.read(BUF_MAX_SIZE)
        buf2 = stream2.read(BUF_MAX_SIZE)
        if buf1 != buf2:
            return True
        if not buf1:
            return False


def _mods_differ_intel(stream1, stream2):
    # The first byte encodes the version of the module file format:
    if stream1.read(1) != stream2.read(1):
        return True
    # The block before the following magic sequence might change from
    # compilation to compilation, probably due to a second resolution timestamp
    # in it:
    magic_sequence = b'\x0A\x00'  # the same as \n\0
    if not (_skip_sequence(stream1, magic_sequence) and
            _skip_sequence(stream2, magic_sequence)):
        return True
    return _mods_differ_default(stream1, stream2)


def _mods_differ_gnu(stream1, stream2):
    # The magic number of gzip to be found in the module files generated by
    # GFortran 4.9 or later:
    magic_sequence = b'\x1F\x8B'
    stream1_sequence = stream1.read(len(magic_sequence))
    stream1.seek(0)
    if stream1_sequence != magic_sequence:
        # Older versions of GFortran generate module files in plain ASCII. Also,
        # up to version 4.6.4, the first line of a module file contains a
        # timestamp, therefore we ignore it.
        stream1.readline()
        stream2.readline()
    return _mods_differ_default(stream1, stream2)


def _mods_differ_portland(stream1, stream2):
    for _ in range(2):  # the first two lines must be identical
        if stream1.readline() != stream2.readline():
            return True
    # The next line is a timestamp followed by the sequence '\nenduse\n':
    magic_sequence = b'\x0A\x65\x6E\x64\x75\x73\x65\x0A'
    if not (_skip_sequence(stream1, magic_sequence) and
            _skip_sequence(stream2, magic_sequence)):
        return True
    return _mods_differ_default(stream1, stream2)


def _mods_differ_amd(stream1, stream2):
    # AOCC is based on the Classic Flang, which has the same format as the PGI
    # compiler
    return _mods_differ_portland(stream1, stream2)


def _mods_differ_flang(stream1, stream2):
    # The header of the module files generated by the new Flang compiler,
    # formerly known as F18:
    magic_sequence = (b'\xEF\xBB\xBF\x21'   # UTF-8 BOM
                      b'\x6D\x6F\x64\x24')  # the same as !mod$
    stream1_sequence = stream1.read(len(magic_sequence))
    stream1.seek(0)
    if stream1_sequence != magic_sequence:
        # The Classic Flang has the same format as the PGI compiler
        return _mods_differ_portland(stream1, stream2)
    return _mods_differ_default(stream1, stream2)


def _mods_differ_omni(stream1, stream2):
    import xml.etree.ElementTree as eT
    # Attributes that either declare or reference the type hashes. Each list
    # contains a group of tags that reference "same things".
    hash_attrs = [["imported_id"],
                  ["type", "ref", "return_type", "extends"]]

    tree1 = eT.parse(stream1)
    tree2 = eT.parse(stream2)

    try:
        it1 = tree1.iter()
        it2 = tree2.iter()
    except AttributeError:
        it1 = iter(tree1.getiterator())
        it2 = iter(tree2.getiterator())

    type_maps1 = [dict() for _ in hash_attrs]
    type_maps2 = [dict() for _ in hash_attrs]

    for node1 in it1:
        try:
            node2 = next(it2)
        except StopIteration:
            # The second file is shorter:
            return True

        if node1.tag != node2.tag:
            # The nodes have different tags:
            return True

        if node1.text != node2.text:
            # The nodes have different texts:
            return True

        for ii, attr_group in enumerate(hash_attrs):
            type_map1 = type_maps1[ii]
            type_map2 = type_maps2[ii]

            for attr in attr_group:
                if (attr in node1.attrib) != (attr in node2.attrib):
                    # One of the files has the attribute and the second one
                    # does not:
                    return True

                hash1 = node1.attrib.pop(attr, None)
                hash2 = node2.attrib.pop(attr, None)

                if hash1 == hash2:
                    # Either the attribute is missing in both nodes or they have
                    # the same value:
                    continue
                elif (hash1 in type_map1) != (hash2 in type_map2):
                    # One of the files has already declared the respective hash
                    # and the second one has not:
                    return True
                elif hash1 in type_map1 and \
                        type_map1[hash1] != type_map2[hash2]:
                    # Both files have declared the respective hashes but they
                    # refer to different types:
                    return True
                else:
                    # Declare the respective hashes for both files:
                    type_value = len(type_map1)
                    type_map1[hash1] = type_value
                    type_map2[hash2] = type_value

        if node1.attrib != node2.attrib:
            # The rest of the attributes have different values:
            return True
    try:
        next(it2)
        # The first file is shorter:
        return True
    except StopIteration:
        return False


def mods_differ(filename1, filename2, compiler_name=None):
    """
    Checks whether two Fortran module files are essentially different. Some
    compiler-specific logic is required for compilers that generate different
    module files for the same source file (e.g. the module files might contain
    timestamps). This implementation is inspired by CMake.
    """
    with open(filename1, 'rb') as stream1:
        with open(filename2, 'rb') as stream2:
            if compiler_name == "intel":
                return _mods_differ_intel(stream1, stream2)
            elif compiler_name == "gnu":
                return _mods_differ_gnu(stream1, stream2)
            elif compiler_name == "portland":
                return _mods_differ_portland(stream1, stream2)
            elif compiler_name == "amd":
                return _mods_differ_amd(stream1, stream2)
            elif compiler_name == "flang":
                return _mods_differ_flang(stream1, stream2)
            elif compiler_name == "omni":
                return _mods_differ_omni(stream1, stream2)
            else:
                return _mods_differ_default(stream1, stream2)


# We try to make this as fast as possible, therefore we do not parse arguments
# properly:
exit(mods_differ(sys.argv[1], sys.argv[2],
                 sys.argv[3].lower() if len(sys.argv) > 3 else None))
