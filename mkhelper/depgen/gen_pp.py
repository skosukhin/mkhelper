class PpGenerator:
    def __init__(self, preprocessor):
        self._preprocessor = preprocessor

    def parse(self):
        while self._preprocessor.readline():
            pass

    def gen_dep_rules(self, compile_target, dep_file_target, src_file_prereq,
                      extra_normal_prereqs=None,
                      extra_order_prereqs=None):

        result = [compile_target,
                  ' ',
                  (dep_file_target if dep_file_target else ''),
                  ': ',
                  src_file_prereq]

        if self._preprocessor.included_files:
            result.append(' ' + ' '.join(self._preprocessor.included_files))

        if extra_normal_prereqs:
            result.append('\n' + compile_target + ': ' +
                          ' '.join(extra_normal_prereqs))

        if extra_order_prereqs:
            result.append('\n' + compile_target + ':| ' +
                          ' '.join(extra_order_prereqs))

        result.append('\n')

        return result

    def print_debug(self, stream):
        self._preprocessor.print_debug(stream)
        stream.writelines(['\n# Simple dependency generator:\n'
                           '#   nothing to report\n'])
