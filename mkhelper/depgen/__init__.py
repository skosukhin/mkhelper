import os
import sys


def open23(name, mode='r'):
    if sys.version_info < (3, 0, 0):
        return open(name, mode)
    else:
        return open(name, mode, encoding='latin-1')


def file_in_dir(file, directory):
    if directory:
        file = os.path.abspath(file)
        directory = os.path.abspath(directory) + os.path.sep
        return file.startswith(directory)
    else:
        return True


class IncludeFinder:
    def __init__(self, include_order=None, include_dirs=None):
        self.include_order = include_order
        self.include_dirs = include_dirs

    def find(self, filename, root_includer=None, current_includer=None):
        if os.path.isabs(filename) and os.path.isfile(filename):
            return filename
        elif self.include_order:
            for inc_type in self.include_order:
                if inc_type == 'cwd' and os.path.isfile(filename):
                    return filename
                elif inc_type == 'src' and root_includer:
                    candidate = os.path.join(os.path.dirname(root_includer),
                                             filename)
                    if os.path.isfile(candidate):
                        return candidate
                elif inc_type == 'inc' and current_includer:
                    candidate = os.path.join(os.path.dirname(current_includer),
                                             filename)
                    if os.path.isfile(candidate):
                        return candidate
                elif inc_type == 'flg' and self.include_dirs:
                    for d in self.include_dirs:
                        candidate = os.path.join(d, filename)
                        if os.path.isfile(candidate):
                            return candidate
        return None


class IncludeStack:
    def __init__(self, stream):
        # Stack of file-like objects (i.e. objects implementing methods
        # readline, close, and a property name:
        self._stack = [stream]

    def include(self, stream):
        self._stack.append(stream)

    @property
    def root_name(self):
        return self._stack[0].name if self._stack else None

    @property
    def current_name(self):
        return self._stack[-1].name if self._stack else None

    def readline(self):
        while self._stack:
            line = self._stack[-1].readline()
            if line:
                return line
            else:
                self._stack.pop().close()
        return ''

    def close(self):
        while self._stack:
            self._stack.pop().close()


class StreamWrapper:
    def __init__(self, stream, name=None):
        self._stream = stream
        self.name = stream.name if name is None else name

    def readline(self):
        return self._stream.readline()

    def close(self):
        self._stream.close()

