import os

from depgen import in_directory, open23


class IncludeReader:
    """Provides a transparent interface for reading a source file that includes
    other files."""

    def __init__(self, src_stream, **kwargs):
        # output properties
        self.included_files = set()

        # private members
        self._include_order = kwargs.get('include_order', None)
        self._include_dirs = kwargs.get('include_dirs', None)
        self._include_root = kwargs.get('include_root', None)
        self._src_stream = src_stream

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
        return self._src_stream.readline()

    def close(self):
        for stream in self._file_stack:
            stream.close()
        self._file_stack[:] = []
        self._src_stream.close()

    @property
    def name(self):
        return self._src_stream.name

    def include(self, filename):
        inc_candidate = None
        if os.path.isabs(filename) and os.path.isfile(filename):
            inc_candidate = filename
        elif self._include_order:
            for inc_id in self._include_order:
                inc_candidate = None

                if inc_id == 'cwd':
                    inc_candidate = filename
                elif inc_id == 'src':
                    inc_candidate = os.path.join(os.path.dirname(
                        self._src_stream.name), filename)
                elif inc_id == 'inc':
                    current_includer = (self._file_stack[-1].name
                                        if self._file_stack
                                        else self._src_stream.name)
                    inc_candidate = os.path.join(os.path.dirname(
                        current_includer), filename)
                elif inc_id == 'flg' and self._include_dirs:
                    for flag_dir in self._include_dirs:
                        flg_inc_candidate = os.path.join(flag_dir, filename)
                        if os.path.isfile(flg_inc_candidate):
                            inc_candidate = flg_inc_candidate
                            break

                if inc_candidate and os.path.isfile(inc_candidate):
                    break

        if not inc_candidate:
            return

        if self._include_root:
            if not (in_directory(inc_candidate, self._include_root) or
                    in_directory(inc_candidate, os.getcwd())):
                return

        self._file_stack.append(open23(inc_candidate, 'r'))
        self.included_files.add(inc_candidate)
