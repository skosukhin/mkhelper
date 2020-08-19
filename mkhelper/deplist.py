#!/usr/bin/env python
import os
import re
import sys
import fnmatch

try:
    import argparse
except ImportError:
    import _argparse as argparse

_re_rule = re.compile(
    r'^[ ]*([-+\w./]+(?:[ ]+[-+\w./]+)*)[ ]*'  # targets
    r':(?:[ ]*([-+\w./]+(?:[ ]+[-+\w./]+)*))?[ ]*'  # normal prerequisites
    r'(?:\|[ ]*([-+\w./]+(?:[ ]+[-+\w./]+)*))?')  # order-only prerequisites
_meta_root = 0


def parse_args():
    class ArgumentParser(argparse.ArgumentParser):
        # Allow for comments in the argument file:
        def convert_arg_line_to_args(self, arg_line):
            if arg_line.startswith('#'):
                return []
            return arg_line.split()

    parser = ArgumentParser(
        fromfile_prefix_chars='@',
        description='Reads a set of makefiles and prints a topologically '
                    'sorted list of prerequisites of the TARGET.')

    parser.add_argument(
        '-d', '--debug-file',
        help='dump debug information to DEBUG_FILE')
    parser.add_argument(
        '-t', '--target',
        help='name of the makefile target; if not specified, all targets and '
             'prerequisites found in the makefiles are sent to the output')
    parser.add_argument(
        '--inc-oo', action='store_true',
        help='include order-only dependencies in the dependency graph')
    parser.add_argument(
        '--check-unique', action='append', nargs=2, metavar='PATTERN',
        help='pair of shell-like wildcards; the option enables additional '
             'consistency checks of the dependency graph: each target that '
             'matches the first pattern of the pair is checked whether it has '
             'no more than one immediate prerequisite matching the second '
             'pattern; if the check fails, a warning message is emitted to the '
             'standard error stream')
    parser.add_argument(
        # Unfortunately, we cannot set nargs to 'two or more', therefore we
        # set nargs to 'one or more':
        '--check-exists', action='append', nargs='+', metavar='PATTERN',
        help='list of two or more shell-like wildcards; the option enables '
             'additional consistency checks of the dependency graph: each '
             'target that matches the first pattern of the list is checked '
             'whether it has at least one immediate prerequisite matching any '
             'of the rest of the patterns; if the check fails, a warning '
             'message is emitted to the standard error stream')
    parser.add_argument(
        '--check-cycles', action='store_true',
        help='check whether the dependency graph is acyclic, e.g. there is no '
             'circular dependencies; if a cycle is found, a warning message is '
             'emitted to the standard output')
    parser.add_argument(
        '--check-colour', action='store_true',
        help='colour the message output of the checks using ANSI escape '
             'sequences; the argument is ignored if the standard error stream '
             'is not associated with a terminal device')
    parser.add_argument(
        '-f', '--makefile', nargs='*',
        help='paths to makefiles; a single dash (-) triggers reading from '
             'the standard input stream')

    args = parser.parse_args()

    if args.check_exists:
        for pattern_list in args.check_exists:
            if len(pattern_list) < 2:
                parser.error('argument --check-exists: expected 2 or more '
                             'arguments')

    args.check_colour = args.check_colour and sys.stderr.isatty()

    return args


def read_makefile(makefile, inc_order_only):
    result = dict()

    if makefile == '-':
        stream = sys.stdin
    elif not os.path.isfile(makefile):
        return result
    else:
        stream = open(makefile, 'r')

    it = iter(stream)

    for line in it:
        while line.endswith('\\\n'):
            line = line[:-2]
            try:
                line += next(it)
            except StopIteration:
                break

        match = _re_rule.match(line)
        if match:
            targets = set(match.group(1).split())
            prereqs = []

            if match.group(2):
                prereqs.extend(match.group(2).split())

            if match.group(3) and inc_order_only:
                prereqs.extend(match.group(3).split())

            for target in targets:
                if target not in result:
                    result[target] = []
                result[target].extend(prereqs)

    stream.close()
    return result


def visit_dfs(dep_graph, vertex,
              visited=None,
              start_visit_cb_list=None,
              finish_visit_cb_list=None,
              skip_visit_cb_list=None):
    if visited is None:
        visited = set()

    if vertex in visited:
        if skip_visit_cb_list:
            for skip_visit_cb in skip_visit_cb_list:
                skip_visit_cb(vertex)
        return

    if start_visit_cb_list:
        for start_visit_cb in start_visit_cb_list:
            start_visit_cb(vertex)

    visited.add(vertex)

    if vertex in dep_graph:
        for child in dep_graph[vertex]:
            visit_dfs(dep_graph, child, visited,
                      start_visit_cb_list,
                      finish_visit_cb_list,
                      skip_visit_cb_list)

    if finish_visit_cb_list:
        for finish_visit_cb in finish_visit_cb_list:
            finish_visit_cb(vertex)


# To make sure that the output is reproducible, we need to work with lists and
# not with sets. This helper function removes duplicates from a list while
# preserving the order.
def remove_duplicates(l):
    seen = set()
    return [x for x in l if not (x in seen or seen.add(x))]


def build_graph(makefiles, inc_oo=False):
    # Read makefiles:
    result = dict()
    for mkf in makefiles:
        mkf_dict = read_makefile(mkf, inc_oo)

        for target, prereqs in mkf_dict.items():
            if target not in result:
                result[target] = []
            result[target].extend(prereqs)

    for target in result.keys():
        result[target] = remove_duplicates(result[target])

    return result


def warn(msg, colour=False):
    sys.stderr.write("%s%s: WARNING: %s%s\n" % ('\033[93m' if colour else '',
                                                os.path.basename(__file__),
                                                msg,
                                                '\033[0m' if colour else ''))


def main():
    args = parse_args()

    if args.debug_file:
        with open(args.debug_file, 'w') as debug_file:
            debug_file.writelines([
                '# Python version: ', sys.version.replace('\n', ' '), '\n',
                '#\n',
                '# Command:\n',
                '#  ', ' '.join(sys.argv), '\n',
                '#\n',
                '# Parsed arguments:\n',
                '#  ', '\n#  '.join(
                    [k + '=' + str(v) for k, v in vars(args).items()]), '\n'])

    if args.makefile is None:
        return

    dep_graph = build_graph(args.makefile, args.inc_oo)

    if not dep_graph:
        return

    # Insert _meta_root, which will be the starting-point for the dependency
    # graph traverse:
    if args.target:
        dep_graph[_meta_root] = \
            [args.target] if args.target in dep_graph else []
    else:
        dep_graph[_meta_root] = sorted(dep_graph.keys())

    # Visitor callbacks:
    start_visit_cb_list = []
    finish_visit_cb_list = []
    skip_visit_cb_list = []

    if args.check_unique:
        def check_unique_start_visit_cb(vertex):
            # Skip if the vertex is _meta_root or does not have descendants:
            if vertex == _meta_root or vertex not in dep_graph:
                return
            for pattern_list in args.check_unique:
                if fnmatch.fnmatch(vertex, pattern_list[0]):
                    vertex_prereqs = dep_graph[vertex]
                    for prereq_pattern in pattern_list[1:]:
                        matching_prereqs = fnmatch.filter(vertex_prereqs,
                                                          prereq_pattern)
                        if len(matching_prereqs) > 1:
                            warn("'%s' has more than one immediate "
                                 "prerequisite matching pattern '%s':\n\t%s"
                                 % (vertex,
                                    prereq_pattern,
                                    "\n\t".join(matching_prereqs)),
                                 args.check_colour)

        start_visit_cb_list.append(check_unique_start_visit_cb)

    if args.check_exists:
        def check_exists_start_visit_cb(vertex):
            # Skip if the vertex is _meta_root:
            if vertex == _meta_root:
                return
            for pattern_list in args.check_exists:
                if fnmatch.fnmatch(vertex, pattern_list[0]):
                    vertex_prereqs = dep_graph.get(vertex, set())
                    prereq_patterns = pattern_list[1:]
                    if not any([fnmatch.filter(vertex_prereqs, prereq_pattern)
                                for prereq_pattern in prereq_patterns]):
                        warn("'%s' does not have an immediate prerequisite "
                             "matching any of the patterns: '%s'"
                             % (vertex,
                                "', '".join(prereq_patterns)),
                             args.check_colour)

        start_visit_cb_list.append(check_exists_start_visit_cb)

    if args.check_cycles:
        path = []

        def check_cycles_start_visit_cb(vertex):
            path.append(vertex)

        def check_cycles_skip_visit_cb(vertex):
            if vertex in path:
                start_cycle_idx = path.index(vertex)

                msg_lines = (path[1:start_cycle_idx] +
                             [path[start_cycle_idx] + ' <- start of cycle'] +
                             path[start_cycle_idx + 1:] +
                             [vertex + ' <- end of cycle'])

                warn('the dependency graph has a cycle:\n\t%s'
                     % '\n\t'.join(msg_lines), args.check_colour)

        def check_cycles_finish_visit_cb(vertex):
            path.pop()

        start_visit_cb_list.append(check_cycles_start_visit_cb)
        skip_visit_cb_list.append(check_cycles_skip_visit_cb)
        finish_visit_cb_list.append(check_cycles_finish_visit_cb)

    toposort = []

    def toposort_finish_visit_cb(vertex):
        toposort.append(vertex)
    finish_visit_cb_list.append(toposort_finish_visit_cb)

    visit_dfs(dep_graph, _meta_root,
              start_visit_cb_list=start_visit_cb_list,
              finish_visit_cb_list=finish_visit_cb_list,
              skip_visit_cb_list=skip_visit_cb_list)

    print('\n'.join(toposort[-2::-1]))


if __name__ == "__main__":
    main()
