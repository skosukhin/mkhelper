import os
import re

import common


class DependencyParser:
    _re_include = re.compile(r'^\s*include\s+(\'|")(.*?)\1', re.I)
    _re_line_continue_start = re.compile(r'^(.*)&\s*$')
    _re_line_continue_end = re.compile(r'^\s*&')
    _re_line_split = re.compile(
        r'^((?:[^\'";]|(?:\'(?:\\\'|[^\'\\])*\')|(?:"(?:\\"|[^"\\])*"))*);'
        r'(.*)$')
    _re_module_provide = re.compile(r'^\s*module\s+(?!procedure\s)(\w+)', re.I)
    _re_module_require = re.compile(
        r'^\s*use(?:\s+(?:::)?|\s*(?:,\s*\w+\s*)?::)\s*(\w+)', re.I)

    def __init__(self, stream, parsed_file_dir):
        # input properties
        self.inc_order = []
        self.inc_root = ''
        self.inc_flag_dirs = []
        self.external_mods = set()

        # output properties
        self.provided_modules = set()
        self.required_modules = set()
        self.included_files = set()

        # private members
        self._parsed_file_dir = parsed_file_dir
        self._include_reader = common.IncludeReader()
        self._include_reader.include(stream)

        self._line_buf = None

    def parse(self):
        while True:
            line = self._next_line()

            if not line:
                break

            # delete comments
            line = re.sub(r'!.*', '', line, 1)
            if line.isspace():
                continue

            # line continuation
            match = DependencyParser._re_line_continue_start.match(line)
            while match:
                next_line = self._next_line()
                if not next_line:
                    break
                line = match.group(1) + re.sub(
                    DependencyParser._re_line_continue_end, '', next_line)

                match = DependencyParser._re_line_continue_start.match(line)

            # replace non-quoted semicolons (;) with new lines (\n)
            match = DependencyParser._re_line_split.match(line)
            if match:
                self._line_buf = match.group(2) + '\n'
                if match.group(1):
                    line = match.group(1) + '\n'
                else:
                    continue

            # module provided
            match = DependencyParser._re_module_provide.match(line)
            if match:
                module_name = match.group(1).lower()
                if module_name not in self.external_mods:
                    self.provided_modules.add(module_name)
                continue

            # module required
            match = DependencyParser._re_module_require.match(line)
            if match:
                module_name = match.group(1).lower()
                if module_name not in self.external_mods:
                    self.required_modules.add(module_name)
                continue

            # include statement
            match = DependencyParser._re_include.match(line)
            if match:
                self._include(match.group(2))
                continue

    def _next_line(self):
        if self._line_buf is None:
            line = self._include_reader.readline()
        else:
            line = self._line_buf
            self._line_buf = None
        return line

    def _include(self, file_path):
        inc_file = common.find_included_file(
            file_path,
            self.inc_order,
            self._parsed_file_dir,
            os.path.dirname(self._include_reader.name),
            self.inc_flag_dirs)

        if inc_file and os.path.abspath(inc_file).startswith(self.inc_root):
            self._include_reader.include(open(inc_file, 'r'))
            self.included_files.add(inc_file)
