import re

from depgen.include_reader import IncludeReader


class FortranGenerator:
    _re_include = re.compile(r'^\s*include\s+(\'|")(.*?)\1', re.I)
    _re_line_continue_start = re.compile(r'^(.*)&\s*$')
    _re_line_continue_end = re.compile(r'^\s*&')
    _re_line_split = re.compile(
        r'^((?:[^\'";]|(?:\'(?:\\\'|[^\'\\])*\')|(?:"(?:\\"|[^"\\])*"))*);'
        r'(.*)$')
    _re_module_provide = re.compile(r'^\s*module\s+(?!procedure\s)(\w+)', re.I)
    _re_module_require = re.compile(
        r'^\s*use(?:\s+(?:::)?|\s*(?:,\s*\w+\s*)?::)\s*(\w+)', re.I)

    def __init__(self, preprocessor, **kwargs):
        self._preprocessor = preprocessor
        self._include_reader = IncludeReader(self._preprocessor)
        self._include_reader.include_root = kwargs.get('include_root', None)
        self._include_reader.include_dirs = kwargs.get('include_dirs', None)
        self._include_reader.include_order = kwargs.get('include_order', None)
        self._mods_to_ignore = kwargs.get('mods_to_ignore', set())
        self._mod_file_dir = kwargs.get('mod_file_dir', None)
        self._mod_file_ext = kwargs.get('mod_file_ext', None)
        self._mod_file_upper = kwargs.get('mod_file_upper', False)
        self._enable_debug = kwargs.get('debug', False)

        self._provided_mods = set()
        self._required_mods = set()

        self._line_buf = None

        self._ignored_mods = [] if self._enable_debug else None

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
            match = FortranGenerator._re_line_continue_start.match(line)
            while match:
                next_line = self._next_line()
                if not next_line:
                    break
                line = match.group(1) + re.sub(
                    FortranGenerator._re_line_continue_end, '', next_line)

                match = FortranGenerator._re_line_continue_start.match(line)

            # replace non-quoted semicolons (;) with new lines (\n)
            match = FortranGenerator._re_line_split.match(line)
            if match:
                self._line_buf = match.group(2) + '\n'
                if match.group(1):
                    line = match.group(1) + '\n'
                else:
                    continue

            # module provided
            match = FortranGenerator._re_module_provide.match(line)
            if match:
                module_name = match.group(1).lower()
                if module_name not in self._mods_to_ignore:
                    self._provided_mods.add(module_name)
                elif self._enable_debug:
                    self._ignored_mods.append(module_name)
                continue

            # module required
            match = FortranGenerator._re_module_require.match(line)
            if match:
                module_name = match.group(1).lower()
                if module_name not in self._mods_to_ignore:
                    self._required_mods.add(module_name)
                elif self._enable_debug:
                    self._ignored_mods.append(module_name)
                continue

            # include statement
            match = FortranGenerator._re_include.match(line)
            if match:
                self._include_reader.include(match.group(2))
                continue

    def gen_dep_rules(self, compile_target, dep_file_target, src_file_prereq):
        included_files = self._include_reader.included_files
        pp_included_files = self._preprocessor.included_files
        if pp_included_files:
            included_files |= pp_included_files

        result = [compile_target +
                  (' ' + dep_file_target if dep_file_target else '') +
                  ': ' +
                  src_file_prereq]

        if included_files:
            result.extend([' ', ' '.join(included_files)])

        required_mods = self._required_mods

        if self._provided_mods:
            # Do not depend on the modules that are provided in the same file
            required_mods -= self._provided_mods
            provided_mod_files = ' '.join(
                self._mods_to_file_names(self._provided_mods))
            result.append(
                '\n' + provided_mod_files + ': ' + compile_target)

        if required_mods:
            required_mod_files = ' '.join(
                self._mods_to_file_names(required_mods))
            result.append(
                '\n' + compile_target + ': ' + required_mod_files)

        result.append('\n')

        return result

    def print_debug(self, stream):
        self._preprocessor.print_debug(stream)
        lines = ['\n# Fortran dependency generator:\n',
                 '#   Included files ("include" statement):\n']
        if self._include_reader.included_files:
            lines.extend(['#     ',
                          '\n#     '.join(self._include_reader.included_files),
                          '\n'])
        else:
            lines.append('#     none\n')

        lines.append('#   Detected provided modules:\n')
        if self._provided_mods:
            lines.extend(['#     ',
                          '\n#     '.join(self._provided_mods), '\n'])
        else:
            lines.append('#     none\n')

        lines.append('#   Detected required modules:\n')
        if self._required_mods:
            lines.extend(['#     ',
                          '\n#     '.join(self._required_mods), '\n'])
        else:
            lines.append('#     none\n')

        lines.append('#   Detected but ignored modules:\n')
        if self._enable_debug:
            if self._ignored_mods:
                lines.extend(['#     ',
                              '\n#     '.join(self._ignored_mods), '\n'])
            else:
                lines.append('#     none\n')
        else:
            lines.append('#     debug info disabled')

        stream.writelines(lines)

    def _next_line(self):
        if self._line_buf is None:
            line = self._include_reader.readline()
        else:
            line = self._line_buf
            self._line_buf = None
        return line

    def _mods_to_file_names(self, mods):
        result = mods
        if self._mod_file_upper:
            result = map(lambda s: s.upper(), result)
        if self._mod_file_dir:
            import os
            result = map(lambda s: os.path.join(self._mod_file_dir, s), result)
        if self._mod_file_ext:
            result = map(lambda s: '%s.%s' % (s, self._mod_file_ext), result)
        return result
