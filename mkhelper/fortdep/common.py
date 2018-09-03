import os


class IncludeReader:
    """Provides a transparent interface for reading a source file that includes
    other files."""

    def __init__(self):
        # Stack of file-like objects.
        # File-like objects must implement readline(), close(), and name
        # (a property). The implementations must have the same functionality
        # as the corresponding members of the Python file object.
        self._file_stack = []

    def readline(self):
        while self._file_stack:
            stream = self._file_stack[-1]
            line = stream.readline()
            if line:
                return line
            else:
                self._file_stack.pop().close()
        return ''

    def close(self):
        for stream in self._file_stack:
            stream.close()
        self._file_stack[:] = []

    @property
    def name(self):
        return self._file_stack[-1].name if self._file_stack else None

    def include(self, stream):
        self._file_stack.append(stream)


def find_included_file(filename, inc_order, src_dir, inc_dir, flag_dirs):
    if os.path.isabs(filename):
        if os.path.isfile(filename):
            return os.path.normpath(filename)
    else:
        dir_list = []
        for inc_id in inc_order:
            if inc_id == 'cwd':
                dir_list.append('.')
            elif inc_id == 'flg':
                dir_list.extend(flag_dirs)
            elif inc_id == 'src':
                dir_list.append(src_dir)
            elif inc_id == 'inc':
                dir_list.append(inc_dir)
            else:
                continue

        for d in dir_list:
            result = os.path.join(d, filename)
            if os.path.isfile(result):
                return os.path.normpath(result)
    return None
