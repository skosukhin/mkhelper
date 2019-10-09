import re

from depgen import IncludeFinder, IncludeStack, file_in_dir, open23


class FortranParser:
    _re_include = re.compile(r'^\s*include\s+(\'|")(.*?)\1', re.I)
    _re_line_continue_start = re.compile(r'^(.*)&\s*$')
    _re_line_continue_end = re.compile(r'^\s*&')
    _re_line_split = re.compile(
        r'^((?:[^\'";]|(?:\'(?:\\\'|[^\'\\])*\')|(?:"(?:\\"|[^"\\])*"))*);'
        r'(.*)$')
    _re_module_provide = re.compile(r'^\s*module\s+(?!procedure\s)(\w+)', re.I)
    _re_module_require = re.compile(
        r'^\s*use(?:\s+|(?:\s*,\s*((?:non_)?intrinsic))?\s*::\s*)(\w+)', re.I)

    def __init__(self, stream,
                 include_order=None,
                 include_dirs=None,
                 include_roots=None,
                 intrinsic_mods=None,
                 external_mods=None):
        self.include_roots = include_roots

        if intrinsic_mods:
            self.intrinsic_mods = set(intrinsic_mods)
        else:
            self.intrinsic_mods = set()

        if external_mods:
            self.external_mods = set(external_mods)
        else:
            self.external_mods = set()

        # Callbacks:
        self.include_callback = None
        self.module_callback = None
        self.use_module_callback = None
        self.debug_callback = None

        self._include_finder = IncludeFinder(include_order, include_dirs)
        self._include_stack = IncludeStack(stream)

    def parse(self):
        while True:
            line = self._include_stack.readline()
            if not line:
                break

            # delete comments
            line = re.sub(r'!.*', '', line, 1)
            if line.isspace():
                continue

            # line continuation
            match = FortranParser._re_line_continue_start.match(line)
            while match:
                next_line = self._include_stack.readline()
                if not next_line:
                    break
                line = match.group(1) + re.sub(
                    FortranParser._re_line_continue_end, '', next_line)

                match = FortranParser._re_line_continue_start.match(line)

            for line in FortranParser._split_semicolons(line):
                # module provided
                match = FortranParser._re_module_provide.match(line)
                if match:
                    module_name = match.group(1).lower()
                    if self.module_callback:
                        self.module_callback(module_name)
                    if self.debug_callback:
                        self.debug_callback(
                            line, 'declared module \'%s\'' % module_name)
                    continue

                # module required
                match = FortranParser._re_module_require.match(line)
                if match:
                    module_nature = match.group(1).lower() \
                        if match.group(1) is not None else ''
                    module_name = match.group(2).lower()
                    if module_nature == 'intrinsic':
                        if self.debug_callback:
                            self.debug_callback(
                                line, 'ignored module usage (\'%s\' '
                                      'is explicitly intrinsic)' % module_name)
                    elif (module_name in self.intrinsic_mods and
                          module_nature != 'non_intrinsic'):
                        if self.debug_callback:
                            self.debug_callback(
                                line, 'ignored module usage (\'%s\' '
                                      'is implicitly intrinsic)' % module_name)
                    elif module_name in self.external_mods:
                        if self.debug_callback:
                            self.debug_callback(
                                line, 'ignored module usage (\'%s\' '
                                      'is external)' % module_name)
                    else:
                        if self.use_module_callback:
                            self.use_module_callback(module_name)
                        if self.debug_callback:
                            self.debug_callback(
                                line, 'used module \'%s\'' % module_name)
                    continue

                # include statement
                match = FortranParser._re_include.match(line)
                if match:
                    filename = match.group(2)
                    filepath = self._include_finder.find(
                        filename,
                        self._include_stack.root_name,
                        self._include_stack.current_name)
                    if filepath:
                        if not self.include_roots or any(
                                [file_in_dir(filepath, d)
                                 for d in self.include_roots]):
                            self._include_stack.include(open23(filepath, 'r'))
                            if self.include_callback:
                                self.include_callback(filepath)
                            if self.debug_callback:
                                self.debug_callback(
                                    line, 'included file \'%s\'' % filepath)
                        elif self.debug_callback:
                            self.debug_callback(
                                line,
                                'ignored (file \'%s\' '
                                'is not in the source roots)' % filepath)
                    elif self.debug_callback:
                        self.debug_callback(line, 'ignored (file not found)')
                    continue

    @staticmethod
    def _split_semicolons(line):
        result = []
        match = FortranParser._re_line_split.match(line)
        while match:
            result.append(match.group(1) + '\n')
            line = match.group(2) + '\n'
            match = FortranParser._re_line_split.match(line)
        else:
            result.append(line)
        return result

